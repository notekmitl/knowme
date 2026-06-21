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
  });

  final String id;
  final String label;
  final HomeCompletionStepStatus status;
}

class HomeProfileCompletion {
  const HomeProfileCompletion({
    required this.progressPercent,
    required this.steps,
    required this.astrologyComplete,
    required this.narrativeUnlocked,
    required this.showUnlockHero,
    required this.showRecoveryBanner,
  });

  final int progressPercent;
  final List<HomeCompletionStep> steps;
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

    final steps = [
      HomeCompletionStep(
        id: 'astrology',
        label: 'Astrology',
        status: astrologyComplete
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.pending,
      ),
      HomeCompletionStep(
        id: 'mbti',
        label: 'MBTI',
        status: hasMbti
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.pending,
      ),
      HomeCompletionStep(
        id: 'big_five',
        label: 'Big Five',
        status: hasBigFive
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.pending,
      ),
      HomeCompletionStep(
        id: 'eq',
        label: 'EQ',
        status: hasEq
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.pending,
      ),
      HomeCompletionStep(
        id: 'narrative',
        label: 'Narrative',
        status: narrativeUnlocked
            ? HomeCompletionStepStatus.complete
            : HomeCompletionStepStatus.locked,
      ),
    ];

    return HomeProfileCompletion(
      progressPercent: progress,
      steps: steps,
      astrologyComplete: astrologyComplete,
      narrativeUnlocked: narrativeUnlocked,
      showUnlockHero: astrologyComplete && !hasMbti,
      showRecoveryBanner: astrologyComplete && !hasAnyPersonality,
    );
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
