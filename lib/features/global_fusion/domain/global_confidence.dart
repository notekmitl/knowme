import 'global_confidence_band.dart';

/// Global Fusion confidence contract (GF-F2 v1).
class GlobalConfidence {
  const GlobalConfidence({
    required this.formulaVersion,
    required this.composite,
    required this.band,
    required this.coverageScore,
    required this.coverageContribution,
    required this.agreementBonus,
    required this.tensionPenalty,
  });

  static const String v1FormulaVersion = 'global_confidence.v1';

  @Deprecated('Use v1FormulaVersion')
  static const String foundationFormulaVersion = 'global_confidence.v0_placeholder';

  /// Composite score 0.0–1.0 — measures cross-mirror support, not truth.
  final double composite;

  final GlobalConfidenceBand band;

  /// Mirror availability tier: 0.0 / 0.5 / 1.0 (no / one / both mirrors).
  final double coverageScore;

  /// Base contribution applied before agreement bonus and tension penalty.
  final double coverageContribution;

  final double agreementBonus;
  final double tensionPenalty;

  final String formulaVersion;

  bool get isPlaceholder => formulaVersion != v1FormulaVersion;
}

abstract final class GlobalConfidenceBands {
  static const lowMax = 0.39;
  static const mediumMin = 0.40;
  static const mediumMax = 0.69;
  static const highMin = 0.70;

  static GlobalConfidenceBand bandFor(double composite) {
    if (composite <= lowMax) return GlobalConfidenceBand.low;
    if (composite <= mediumMax) return GlobalConfidenceBand.medium;
    return GlobalConfidenceBand.high;
  }

  static double clamp(double value) => value.clamp(0.0, 1.0);
}

/// Explainable breakdown produced by [GlobalConfidenceComposer].
class GlobalConfidenceBreakdown {
  const GlobalConfidenceBreakdown({
    required this.coverageScore,
    required this.coverageContribution,
    required this.agreementBonus,
    required this.tensionPenalty,
    required this.composite,
    required this.band,
  });

  final double coverageScore;
  final double coverageContribution;
  final double agreementBonus;
  final double tensionPenalty;
  final double composite;
  final GlobalConfidenceBand band;

  GlobalConfidence toConfidence() {
    return GlobalConfidence(
      formulaVersion: GlobalConfidence.v1FormulaVersion,
      composite: composite,
      band: band,
      coverageScore: coverageScore,
      coverageContribution: coverageContribution,
      agreementBonus: agreementBonus,
      tensionPenalty: tensionPenalty,
    );
  }
}
