import 'package:knowme/features/tests/big_five/data/big_five_firestore_repository.dart';
import 'package:knowme/features/tests/eq/data/eq_firestore_repository.dart';
import 'package:knowme/features/tests/eq/domain/eq_models.dart';
import 'package:knowme/features/tests/mbti/data/mbti_firestore_repository.dart';

import '../domain/personality_coverage.dart';
import '../domain/personality_lens_id.dart';
import '../domain/personality_lens_snapshot.dart';
import '../domain/personality_mirror_constants.dart';
import 'adapters/big_five_personality_lens_adapter.dart';
import 'adapters/eq_personality_lens_adapter.dart';
import 'adapters/mbti_personality_lens_adapter.dart';
import 'personality_lens_load_result.dart';

/// Read-only loader: Firestore results → [PersonalityLensSnapshot] per lens.
class PersonalityLensLoader {
  PersonalityLensLoader({
    MbtiFirestoreRepository? mbtiRepository,
    EqFirestoreRepository? eqRepository,
    BigFiveFirestoreRepository? bigFiveRepository,
  })  : _mbtiRepository = mbtiRepository ?? MbtiFirestoreRepositoryImpl(),
        _eqRepository = eqRepository ?? EqFirestoreRepositoryImpl(),
        _bigFiveRepository =
            bigFiveRepository ?? BigFiveFirestoreRepositoryImpl();

  final MbtiFirestoreRepository _mbtiRepository;
  final EqFirestoreRepository _eqRepository;
  final BigFiveFirestoreRepository _bigFiveRepository;

  Future<PersonalityLensLoadResult> loadAll(String uid) async {
    final mbtiResult = await _mbtiRepository.loadLatestResult(uid);
    final bigFiveResult = await _bigFiveRepository.loadLatestResult(uid);

    final eqResults = <PersonalityLensId, EqResultSummary?>{};
    for (final lensId in PersonalityLensId.eqLenses) {
      final testType = EqPersonalityLensAdapter.eqTestTypeForLensId(lensId);
      if (testType == null) continue;
      eqResults[lensId] =
          await _eqRepository.loadLatestResult(uid, testType.testId);
    }

    final snapshots = <PersonalityLensId, PersonalityLensSnapshot>{
      PersonalityLensId.mbti: MbtiPersonalityLensAdapter.map(mbtiResult),
      PersonalityLensId.bigFive:
          BigFivePersonalityLensAdapter.map(bigFiveResult),
    };

    for (final lensId in PersonalityLensId.eqLenses) {
      snapshots[lensId] = EqPersonalityLensAdapter.map(
        lensId: lensId,
        result: eqResults[lensId],
      );
    }

    return PersonalityLensLoadResult(
      snapshots: snapshots,
      coverage: _buildCoverage(snapshots),
    );
  }

  Future<PersonalityLensSnapshot> loadLens(
    String uid,
    PersonalityLensId lensId,
  ) async {
    final all = await loadAll(uid);
    return all.snapshots[lensId] ??
        PersonalityLensSnapshot.unavailable(lensId);
  }

  PersonalityCoverage _buildCoverage(
    Map<PersonalityLensId, PersonalityLensSnapshot> snapshots,
  ) {
    final available = <PersonalityLensId>[];
    final missing = <PersonalityLensId>[];

    for (final lensId in PersonalityLensId.all) {
      final snapshot = snapshots[lensId];
      if (snapshot != null && snapshot.available) {
        available.add(lensId);
      } else {
        missing.add(lensId);
      }
    }

    final eqCompleted = PersonalityLensId.eqLenses
        .where((id) => available.contains(id))
        .length;

    var weighted = 0.0;
    if (available.contains(PersonalityLensId.mbti)) {
      weighted += PersonalityMirrorWeights.mbti;
    }
    if (available.contains(PersonalityLensId.bigFive)) {
      weighted += PersonalityMirrorWeights.bigFive;
    }
    weighted += eqCompleted * PersonalityMirrorWeights.eqModuleShare;

    return PersonalityCoverage(
      availableLensIds: available,
      missingLensIds: missing,
      eqModulesCompleted: eqCompleted,
      eqModulesExpected: PersonalityLensId.eqLenses.length,
      weightedCoverage: weighted,
    );
  }
}
