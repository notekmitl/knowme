import '../domain/fusion_constants.dart';
import '../domain/fusion_models.dart';

/// Active theme with score from merged signals (V1, no ontology).
class FusionThemeActivation {
  const FusionThemeActivation({
    required this.themeId,
    required this.score,
    required this.signals,
  });

  final String themeId;
  final int score;
  final List<MergedFusionSignal> signals;
}

abstract final class FusionThemeDetection {
  static const _themeSignals = <String, List<String>>{
    FusionThemeIds.exploration: [
      FusionSignalIds.openness,
      FusionSignalIds.exploration,
      FusionSignalIds.curiosity,
    ],
    FusionThemeIds.thinkingStyle: [
      FusionSignalIds.logicOrientation,
      FusionSignalIds.reflection,
      FusionSignalIds.intuition,
      FusionSignalIds.structure,
    ],
    FusionThemeIds.emotion: [
      FusionSignalIds.emotionalProcessing,
      FusionSignalIds.emotionalSensitivity,
    ],
    FusionThemeIds.socialExpression: [
      FusionSignalIds.socialExpression,
    ],
  };

  static List<FusionThemeActivation> detect(List<MergedFusionSignal> merged) {
    final activations = <FusionThemeActivation>[];

    for (final entry in _themeSignals.entries) {
      final matched = <MergedFusionSignal>[];
      var score = 0;
      for (final signal in merged) {
        if (!entry.value.contains(signal.id)) continue;
        matched.add(signal);
        score += _strengthRank(signal.strength);
      }
      if (score <= 0) continue;
      activations.add(
        FusionThemeActivation(
          themeId: entry.key,
          score: score,
          signals: matched,
        ),
      );
    }

    activations.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.themeId.compareTo(b.themeId);
    });

    return activations;
  }

  static int _strengthRank(FusionSignalStrength strength) => switch (strength) {
        FusionSignalStrength.low => 1,
        FusionSignalStrength.medium => 2,
        FusionSignalStrength.high => 3,
      };
}
