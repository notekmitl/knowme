/// FCR3 — recovery risk classification for supplemental findings.
enum FusionRecoveryRiskLevel {
  low,
  medium,
  high;

  String get key => name;
}

/// V2 compression rule identifiers (FCR2).
enum FusionCompressionRule {
  crossMirrorAgreementRequiresTwoRoles,
  reinforcementRequiresCrossMirrorAgreement,
  tensionRequiresCrossRolePolarity,
  blindSpotRequiresCrossMirrorReflection,
  singleMirrorAgreementExcluded,
  singleMirrorReinforcementExcluded;

  String get key => name;
}

/// FCR1 — mirror finding disposition in V1 fusion pipeline.
enum MirrorFindingDisposition {
  fused,
  filtered,
  missing;

  String get key => name;
}

/// FCR2 — compression classification.
enum CompressionClassification {
  expectedCompression,
  overCompression;

  String get key => name;
}
