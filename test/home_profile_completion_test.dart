import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/home_cohesion/domain/home_profile_completion.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v3_copy.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';

void main() {
  group('HomeProfileCompletion UX Conversion Sprint', () {
    test('astrology-only user shows MBTI as current step at 35%', () {
      final completion = HomeProfileCompletion.fromCoverage(
        astrologyComplete: true,
        coverage: null,
        narrativeUnlocked: false,
      );

      expect(completion.progressPercent, 35);
      expect(completion.showUnlockHero, isTrue);
      expect(completion.showRecoveryBanner, isTrue);
      expect(
        completion.progressSubtitle,
        HomeV3Copy.progressSubtitleAstrologyOnly,
      );

      final mbtiStep = completion.steps.firstWhere((s) => s.id == 'mbti');
      expect(mbtiStep.isCurrent, isTrue);
      expect(mbtiStep.label, HomeV3Copy.stepMbti);
    });

    test('MBTI complete user highlights Big Five next', () {
      final completion = HomeProfileCompletion.fromCoverage(
        astrologyComplete: true,
        coverage: const PersonalityCoverage(
          availableLensIds: [PersonalityLensId.mbti],
          missingLensIds: [PersonalityLensId.bigFive],
          eqModulesCompleted: 0,
          eqModulesExpected: 6,
          weightedCoverage: 0.3,
        ),
        narrativeUnlocked: false,
      );

      expect(completion.progressPercent, 52);
      expect(completion.showUnlockHero, isFalse);
      expect(completion.progressSubtitle, HomeV3Copy.progressSubtitleAfterMbti);

      final bigFiveStep =
          completion.steps.firstWhere((s) => s.id == 'big_five');
      expect(bigFiveStep.isCurrent, isTrue);
    });

    test('final step uses Thai deep profile label', () {
      final completion = HomeProfileCompletion.fromCoverage(
        astrologyComplete: true,
        coverage: const PersonalityCoverage(
          availableLensIds: [
            PersonalityLensId.mbti,
            PersonalityLensId.bigFive,
          ],
          missingLensIds: [],
          eqModulesCompleted: 6,
          eqModulesExpected: 6,
          weightedCoverage: 1,
        ),
        narrativeUnlocked: true,
      );

      expect(completion.progressPercent, 100);
      final narrativeStep =
          completion.steps.firstWhere((s) => s.id == 'narrative');
      expect(narrativeStep.label, HomeV3Copy.deepProfileLabel);
      expect(narrativeStep.status, HomeCompletionStepStatus.complete);
    });
  });
}
