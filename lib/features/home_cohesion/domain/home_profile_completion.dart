import 'package:knowme/features/home_cohesion/presentation/home_v3_copy.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';

/// KnowMe-wide profile completion for funnel recovery (Home V2).
enum HomeCompletionStepStatus {
  complete,
  pending,
  locked,
}

class HomeCompletionStep {
  const HomeCompletionStep({
    required this.id,
    required this.label,
    required this.status,
    required this.stepNumber,
    this.isCurrent = false,
  });

  final String id;
  final String label;
  final HomeCompletionStepStatus status;
  final int stepNumber;
  final bool isCurrent;
}

class HomeProfileCompletion {
  const HomeProfileCompletion({
    required this.progressPercent,
    required this.steps,
    required this.progressSubtitle,
    required this.astrologyComplete,
    required this.narrativeUnlocked,
    required this.showUnlockHero,
    required this.showRecoveryBanner,
  });

  final int progressPercent;
  final List<HomeCompletionStep> steps;
  final String progressSubtitle;
  final bool astrologyComplete;
  final bool narrativeUnlocked;
  final bool showUnlockHero;
  final bool showRecoveryBanner;

  static HomeProfileCompletion fromCoverage({
    required bool astrologyComplete,
    required PersonalityCoverage? coverage,
    required bool narrativeUnlocked,
  }) {
    final c = coverage;
    final hasMbti = c?.hasMbti ?? false;
    final hasBigFive = c?.hasBigFive ?? false;
    final hasEq = c?.hasAnyEq ?? false;
    final hasAnyPersonality = hasMbti || hasBigFive || hasEq;

    final progress = _progressPercent(
      astrologyComplete: astrologyComplete,
      hasMbti: hasMbti,
      hasBigFive: hasBigFive,
      hasEq: hasEq,
      narrativeUnlocked: narrativeUnlocked,
    );

    final currentStepId = _currentStepId(
      astrologyComplete: astrologyComplete,
      hasMbti: hasMbti,
      hasBigFive: hasBigFive,
      hasEq: hasEq,
      narrativeUnlocked: narrativeUnlocked,
    );

    final steps = [
      HomeCompletionStep(
        id: 'astrology',
        label: HomeV3Copy.stepAstrology,
        status: astrologyComplete
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.pending,
        stepNumber: 1,
        isCurrent: currentStepId == 'astrology',
      ),
      HomeCompletionStep(
        id: 'mbti',
        label: HomeV3Copy.stepMbti,
        status: hasMbti
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.pending,
        stepNumber: 2,
        isCurrent: currentStepId == 'mbti',
      ),
      HomeCompletionStep(
        id: 'big_five',
        label: HomeV3Copy.stepBigFive,
        status: hasBigFive
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.pending,
        stepNumber: 3,
        isCurrent: currentStepId == 'big_five',
      ),
      HomeCompletionStep(
        id: 'eq',
        label: HomeV3Copy.stepEq,
        status: hasEq
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.pending,
        stepNumber: 4,
        isCurrent: currentStepId == 'eq',
      ),
      HomeCompletionStep(
        id: 'narrative',
        label: HomeV3Copy.deepProfileLabel,
        status: narrativeUnlocked
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.locked,
        stepNumber: 5,
        isCurrent: currentStepId == 'narrative',
      ),
    ];

    return HomeProfileCompletion(
      progressPercent: progress,
      steps: steps,
      progressSubtitle: _progressSubtitle(
        astrologyComplete: astrologyComplete,
        hasMbti: hasMbti,
        hasBigFive: hasBigFive,
        hasEq: hasEq,
        narrativeUnlocked: narrativeUnlocked,
      ),
      astrologyComplete: astrologyComplete,
      narrativeUnlocked: narrativeUnlocked,
      showUnlockHero: astrologyComplete && !hasMbti,
      showRecoveryBanner: astrologyComplete && !hasAnyPersonality,
    );
  }

  static String _currentStepId({
    required bool astrologyComplete,
    required bool hasMbti,
    required bool hasBigFive,
    required bool hasEq,
    required bool narrativeUnlocked,
  }) {
    if (narrativeUnlocked) return 'narrative';
    if (!astrologyComplete) return 'astrology';
    if (!hasMbti) return 'mbti';
    if (!hasBigFive) return 'big_five';
    if (!hasEq) return 'eq';
    return 'narrative';
  }

  static String _progressSubtitle({
    required bool astrologyComplete,
    required bool hasMbti,
    required bool hasBigFive,
    required bool hasEq,
    required bool narrativeUnlocked,
  }) {
    if (narrativeUnlocked) return HomeV3Copy.progressSubtitleComplete;
    if (!astrologyComplete) return HomeV3Copy.progressSubtitleEmpty;
    if (!hasMbti) return HomeV3Copy.progressSubtitleAstrologyOnly;
    if (!hasBigFive) return HomeV3Copy.progressSubtitleAfterMbti;
    if (!hasEq) return HomeV3Copy.progressSubtitleAfterBigFive;
    if (hasMbti && hasBigFive && hasEq) {
      return HomeV3Copy.progressSubtitleAlmostDone;
    }
    return HomeV3Copy.progressSubtitleAfterEq;
  }

  static int _progressPercent({
    required bool astrologyComplete,
    required bool hasMbti,
    required bool hasBigFive,
    required bool hasEq,
    required bool narrativeUnlocked,
  }) {
    if (narrativeUnlocked) return 100;
    if (!astrologyComplete) return 0;
    var progress = 35;
    if (hasMbti) progress = 52;
    if (hasBigFive || (hasEq && hasMbti)) progress = 78;
    if (hasMbti && hasBigFive && hasEq) progress = 88;
    return progress;
  }
}
