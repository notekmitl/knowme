import 'package:knowme/features/personality_mirror/application/adapters/big_five_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/eq_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/mbti_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_depth_tier.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_trait_id.dart';
import 'package:knowme/features/tests/eq/domain/eq_models.dart';
import 'package:knowme/features/tests/eq/domain/eq_test_type.dart';
import 'package:knowme/features/tests/mbti/application/mbti_scorer.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';

import '../models/real_user_export_record.dart';

/// Maps exported Firestore personality results through production adapters.
abstract final class RealUserLensLoader {
  static PersonalityLensLoadResult load(RealUserExportRecord user) {
    final snapshots = <PersonalityLensId, PersonalityLensSnapshot>{};

    final mbtiSummary = _loadMbti(user);
    if (mbtiSummary != null) {
      snapshots[PersonalityLensId.mbti] =
          MbtiPersonalityLensAdapter.map(mbtiSummary);
    }

    final bigFiveSummary = _loadBigFive(user);
    if (bigFiveSummary != null) {
      snapshots[PersonalityLensId.bigFive] =
          BigFivePersonalityLensAdapter.map(bigFiveSummary);
    }

    for (final lensId in PersonalityLensId.eqLenses) {
      final testType = EqPersonalityLensAdapter.eqTestTypeForLensId(lensId);
      if (testType == null) continue;
      final result = _loadEq(user, testType);
      snapshots[lensId] = EqPersonalityLensAdapter.map(
        lensId: lensId,
        result: result,
      );
    }

    return PersonalityLensLoadResult(
      snapshots: snapshots,
      coverage: _coverage(snapshots),
    );
  }

  static MbtiResultSummary? _loadMbti(RealUserExportRecord user) {
    final data = user.results['mbti_mini'] ??
        user.results['mbti_accurate'] ??
        user.results['mbti_cognitive'];
    if (data == null) return null;

    final dimensions = {
      for (final key in ['E', 'I', 'S', 'N', 'T', 'F', 'J', 'P'])
        key: (data[key] as num?)?.toDouble() ?? 0,
    };

    final storedType = data['type'] as String?;
    final type = storedType ?? MbtiScorer.typeFromDimensions(dimensions);

    return MbtiResultSummary(
      testId: (data['testId'] as String?) ?? mbtiMiniTestId,
      type: type,
      dimensions: dimensions,
      scoredAt: _parseDate(data['createdAt']) ??
          _parseDate(data['scoredAt']) ??
          DateTime.utc(2025, 1, 1),
      scoringVersion:
          (data['scoringVersion'] as num?)?.toInt() ?? mbtiMiniScoringVersion,
      scoredQuestionCount: (data['scoredQuestionCount'] as num?)?.toInt() ??
          MbtiScorer.inferScoredQuestionCountFromDimensions(dimensions),
    );
  }

  static BigFiveResultSummary? _loadBigFive(RealUserExportRecord user) {
    final data = user.results['big_five'] ?? user.results['bigfive'];
    if (data == null) return null;

    final scoreFields = <String, double>{};
    final bandFields = <String, String>{};
    for (final trait in BigFiveTraitId.all) {
      final scoreKey = BigFiveTraitId.scoreField(trait);
      final bandKey = BigFiveTraitId.bandField(trait);
      scoreFields[scoreKey] =
          (data[scoreKey] as num?)?.toDouble() ??
          (data[trait] as num?)?.toDouble() ??
          0;
      bandFields[bandKey] =
          (data[bandKey] as String?) ??
          (data['${trait}Band'] as String?) ??
          BigFiveBandId.moderate;
    }

    final scoredQuestionCount =
        (data['scoredQuestionCount'] as num?)?.toInt() ?? bigFiveQuickCheckpoint;
    final depthTier = BigFiveDepthTier.fromStorageKey(
          data['depthTier'] as String?,
        ) ??
        BigFiveDepthTier.forScoredQuestionCount(scoredQuestionCount);

    return BigFiveResultSummary(
      testId: (data['testId'] as String?) ?? bigFiveTestId,
      traitScoreFields: normalizeTraitScoreFields(scoreFields),
      traitBandFields: normalizeTraitBandFields(bandFields),
      depthTier: depthTier,
      scoredQuestionCount: scoredQuestionCount,
      scoredAt: _parseDate(data['completedAt']) ?? DateTime.utc(2025, 1, 1),
      scoringVersion:
          (data['scoringVersion'] as num?)?.toInt() ?? bigFiveScoringVersion,
    );
  }

  static EqResultSummary? _loadEq(
    RealUserExportRecord user,
    EqTestType testType,
  ) {
    final data = user.results[testType.testId] ??
        (testType == EqTestType.awareness ? user.results['eq'] : null);
    if (data == null) return null;

    return EqResultSummary(
      testId: (data['testId'] as String?) ?? testType.testId,
      averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0,
      level: (data['level'] as String?) ?? EqLevelIds.moderate,
      scoredQuestionCount: (data['scoredQuestionCount'] as num?)?.toInt() ?? 0,
      scoringVersion:
          (data['scoringVersion'] as num?)?.toInt() ?? eqScoringVersion,
      completedAt: _parseDate(data['completedAt']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static PersonalityCoverage _coverage(
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
