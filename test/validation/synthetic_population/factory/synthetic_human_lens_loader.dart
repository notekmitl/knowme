import 'package:knowme/features/personality_mirror/application/adapters/big_five_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/eq_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/mbti_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_depth_tier.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_trait_id.dart';
import 'package:knowme/features/tests/eq/domain/eq_models.dart';
import 'package:knowme/features/tests/eq/domain/eq_test_type.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';

import '../models/synthetic_human_profile.dart';

/// Maps synthetic profiles through production personality lens adapters.
abstract final class SyntheticHumanLensLoader {
  static PersonalityLensLoadResult load(SyntheticHumanProfile profile) {
    final snapshots = <PersonalityLensId, PersonalityLensSnapshot>{
      PersonalityLensId.mbti: MbtiPersonalityLensAdapter.map(
        MbtiResultSummary(
          testId: 'mbti_accurate',
          type: profile.mbtiType,
          dimensions: profile.mbtiDimensions.map(
            (key, value) => MapEntry(key, value.toDouble()),
          ),
          scoredAt: DateTime.utc(2025, 3, 15, 10, 30),
          scoringVersion: mbtiMiniScoringVersion,
          scoredQuestionCount: mbtiAccurateCheckpoint,
        ),
      ),
      PersonalityLensId.bigFive: BigFivePersonalityLensAdapter.map(
        BigFiveResultSummary(
          testId: bigFiveTestId,
          traitScoreFields: {
            for (final trait in BigFiveTraitId.all)
              BigFiveTraitId.scoreField(trait):
                  (profile.bigFiveScores[trait] ?? 50).toDouble(),
          },
          traitBandFields: {
            for (final trait in BigFiveTraitId.all)
              BigFiveTraitId.bandField(trait):
                  profile.bigFiveBands[trait] ?? BigFiveBandId.moderate,
          },
          depthTier: BigFiveDepthTier.standard,
          scoredQuestionCount: 44,
          scoredAt: DateTime.utc(2025, 4, 2, 14, 0),
        ),
      ),
    };

    for (final lensId in PersonalityLensId.eqLenses) {
      final testType = EqPersonalityLensAdapter.eqTestTypeForLensId(lensId);
      EqResultSummary? result;
      if (testType == EqTestType.awareness) {
        result = EqResultSummary(
          testId: EqTestType.awareness.testId,
          averageScore: _eqAverage(profile.eqAwarenessLevel),
          level: profile.eqAwarenessLevel,
          scoredQuestionCount: eqAwarenessQuestionCount,
          completedAt: DateTime.utc(2025, 4, 10, 9, 15),
        );
      } else if (testType == EqTestType.regulation) {
        result = EqResultSummary(
          testId: EqTestType.regulation.testId,
          averageScore: _eqAverage(profile.eqRegulationLevel),
          level: profile.eqRegulationLevel,
          scoredQuestionCount: 20,
          completedAt: DateTime.utc(2025, 4, 11, 11, 0),
        );
      }
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

  static double _eqAverage(String level) {
    return switch (level) {
      EqLevelIds.emerging => 2.1,
      EqLevelIds.strong => 4.2,
      _ => 3.2,
    };
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
