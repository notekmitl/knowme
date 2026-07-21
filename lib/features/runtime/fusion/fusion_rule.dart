/// P2 — the deterministic configuration that governs fusion.
///
/// All fusion arithmetic (confidence adjustment, priority boosting, confidence
/// banding) reads its thresholds from here, so fusion stays pure and tunable
/// without code changes. No copy, no behaviour — values only.
class FusionRule {
  const FusionRule({
    this.agreementBonus = 5,
    this.conflictPenalty = 8,
    this.agreementPriorityBoost = 10,
    this.lowBand = 40,
    this.highBand = 70,
  });

  /// Confidence added per cross-provider agreement.
  final int agreementBonus;

  /// Confidence removed per cross-provider conflict.
  final int conflictPenalty;

  /// Priority score added to a domain that providers agree on.
  final int agreementPriorityBoost;

  /// Below this fused-confidence value the band is `low`.
  final int lowBand;

  /// At/above this fused-confidence value the band is `high`.
  final int highBand;
}
