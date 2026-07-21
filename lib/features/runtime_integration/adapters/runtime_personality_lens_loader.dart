import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_snapshot.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_depth_tier.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_trait_id.dart';
import 'package:knowme/features/tests/eq/domain/eq_models.dart';
import 'package:knowme/features/tests/eq/domain/eq_test_type.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';

import 'package:knowme/features/personality_mirror/application/adapters/big_five_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/eq_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/mbti_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';

/// RT2 — real-shaped lens result documents (not synthetic mirror fixtures).
abstract final class RuntimeRealLensProfiles {
  static MbtiResultSummary qaMbtiProfile() {
    return MbtiResultSummary(
      testId: 'mbti_accurate',
      type: 'INTJ',
      dimensions: const {
        'E': 24,
        'I': 76,
        'S': 31,
        'N': 69,
        'T': 74,
        'F': 26,
        'J': 67,
        'P': 33,
      },
      scoredAt: DateTime.utc(2025, 3, 15, 10, 30),
      scoringVersion: mbtiMiniScoringVersion,
      scoredQuestionCount: mbtiAccurateCheckpoint,
    );
  }

  static BigFiveResultSummary qaBigFiveProfile() {
    return BigFiveResultSummary(
      testId: bigFiveTestId,
      traitScoreFields: {
        BigFiveTraitId.scoreField(BigFiveTraitId.openness): 72,
        BigFiveTraitId.scoreField(BigFiveTraitId.conscientiousness): 81,
        BigFiveTraitId.scoreField(BigFiveTraitId.extraversion): 38,
        BigFiveTraitId.scoreField(BigFiveTraitId.agreeableness): 55,
        BigFiveTraitId.scoreField(BigFiveTraitId.neuroticism): 42,
      },
      traitBandFields: {
        BigFiveTraitId.bandField(BigFiveTraitId.openness): BigFiveBandId.strong,
        BigFiveTraitId.bandField(BigFiveTraitId.conscientiousness):
            BigFiveBandId.strong,
        BigFiveTraitId.bandField(BigFiveTraitId.extraversion):
            BigFiveBandId.emerging,
        BigFiveTraitId.bandField(BigFiveTraitId.agreeableness):
            BigFiveBandId.moderate,
        BigFiveTraitId.bandField(BigFiveTraitId.neuroticism):
            BigFiveBandId.moderate,
      },
      depthTier: BigFiveDepthTier.standard,
      scoredQuestionCount: 44,
      scoredAt: DateTime.utc(2025, 4, 2, 14, 0),
    );
  }

  static EqResultSummary qaEqAwarenessProfile() {
    return EqResultSummary(
      testId: EqTestType.awareness.testId,
      averageScore: 3.8,
      level: EqLevelIds.strong,
      scoredQuestionCount: eqAwarenessQuestionCount,
      completedAt: DateTime.utc(2025, 4, 10, 9, 15),
    );
  }

  static EqResultSummary qaEqRegulationProfile() {
    return EqResultSummary(
      testId: EqTestType.regulation.testId,
      averageScore: 3.2,
      level: EqLevelIds.moderate,
      scoredQuestionCount: 20,
      completedAt: DateTime.utc(2025, 4, 11, 11, 0),
    );
  }
}

/// RT2 — maps real lens summaries through existing personality adapters.
abstract final class RuntimePersonalityLensLoader {
  static PersonalityLensLoadResult loadQaProfile() {
    final snapshots = <PersonalityLensId, PersonalityLensSnapshot>{
      PersonalityLensId.mbti:
          MbtiPersonalityLensAdapter.map(RuntimeRealLensProfiles.qaMbtiProfile()),
      PersonalityLensId.bigFive: BigFivePersonalityLensAdapter.map(
        RuntimeRealLensProfiles.qaBigFiveProfile(),
      ),
    };

    for (final lensId in PersonalityLensId.eqLenses) {
      final testType = EqPersonalityLensAdapter.eqTestTypeForLensId(lensId);
      EqResultSummary? result;
      if (testType == EqTestType.awareness) {
        result = RuntimeRealLensProfiles.qaEqAwarenessProfile();
      } else if (testType == EqTestType.regulation) {
        result = RuntimeRealLensProfiles.qaEqRegulationProfile();
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
