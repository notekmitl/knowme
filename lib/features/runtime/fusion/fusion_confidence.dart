import 'fusion_rule.dart';

enum FusionConfidenceBand { low, moderate, high }

/// P2 — the fused overall confidence.
///
/// [value] (0–100) is the provider-confidence average adjusted for agreements
/// (boost) and conflicts (penalty); [band] is the value banded via [FusionRule];
/// [providerCount] records how many providers contributed (1 ⇒ single-provider
/// mode).
class FusionConfidence {
  const FusionConfidence({
    required this.value,
    required this.band,
    required this.providerCount,
  });

  factory FusionConfidence.fromValue(
    int value, {
    required int providerCount,
    required FusionRule rule,
  }) {
    final band = value < rule.lowBand
        ? FusionConfidenceBand.low
        : value < rule.highBand
            ? FusionConfidenceBand.moderate
            : FusionConfidenceBand.high;
    return FusionConfidence(
      value: value,
      band: band,
      providerCount: providerCount,
    );
  }

  final int value;
  final FusionConfidenceBand band;
  final int providerCount;
}
