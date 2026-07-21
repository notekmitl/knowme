/// Coarse confidence band for a decision recommendation.
enum DecisionConfidenceBand { low, moderate, high }

/// V11 — how well-supported a [DecisionAction] is (0–100). Evidence only.
///
/// It blends the decisive window's prediction confidence with how decisively
/// the favourability thresholds were crossed (margin) and how much the evidence
/// pulls both ways (conflict). Separate from favourability so a consumer can
/// surface "fairly sure to wait" vs "barely favourable to act".
class DecisionConfidence {
  const DecisionConfidence({required this.value});

  /// 0–100 confidence in the recommendation.
  final int value;

  DecisionConfidenceBand get band {
    if (value >= 67) return DecisionConfidenceBand.high;
    if (value >= 40) return DecisionConfidenceBand.moderate;
    return DecisionConfidenceBand.low;
  }

  static int clamp(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);
}
