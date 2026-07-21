/// MV2 validation version contract.
abstract final class MirrorValidationVersionContract {
  static const validationVersion = 'v0.1.0';
}

/// Population anomaly thresholds for MV2.1.
abstract final class MirrorPopulationThresholds {
  static const maxAgreementRate = 0.95;
  static const maxTensionRate = 0.85;
  static const minReinforcementOccurrenceRate = 0.05;
  static const maxBlindSpotMeanPerCase = 11.0;
  static const maxBlindSpotRate = 1.0;
}

/// Blind spot distribution thresholds for MV2.4.
abstract final class MirrorBlindSpotThresholds {
  static const maxBlindSpotExplosionRate = 0.99;
  static const minNoBlindSpotCaseRate = 0.0;
}

/// Consistency run count for MV2.2.
abstract final class MirrorConsistencyRules {
  static const repeatRuns = 5;
}
