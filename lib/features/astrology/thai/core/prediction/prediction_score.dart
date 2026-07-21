/// V10 — a prediction's quantitative signal. Evidence only, fully deterministic.
///
/// [strength] is *how active/favourable* the category is in the window (0–100).
/// [confidence] is *how well-supported* that read is (0–100) — driven by data
/// availability (lagna known), corroborating signals, period length and window
/// proximity. The two are intentionally separate so downstream consumers can
/// rank by either, or by [weighted].
class PredictionScore {
  const PredictionScore({
    required this.strength,
    required this.confidence,
  });

  final int strength;
  final int confidence;

  /// Confidence-weighted strength (0–100), handy for ranking predictions.
  int get weighted => (strength * confidence) ~/ 100;

  /// Coarse strength band (engine-side; the label mapping stays in copy land).
  PredictionStrengthBand get band {
    if (strength >= 67) return PredictionStrengthBand.high;
    if (strength >= 34) return PredictionStrengthBand.moderate;
    return PredictionStrengthBand.low;
  }

  PredictionScore copyWith({int? strength, int? confidence}) => PredictionScore(
        strength: strength ?? this.strength,
        confidence: confidence ?? this.confidence,
      );

  static int clamp(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);
}

enum PredictionStrengthBand { low, moderate, high }
