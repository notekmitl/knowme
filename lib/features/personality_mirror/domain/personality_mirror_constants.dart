/// Composite weights for future mirror confidence (PF-3).
abstract final class PersonalityMirrorWeights {
  static const mbti = 0.45;
  static const bigFive = 0.40;
  static const eq = 0.15;

  static const eqModuleShare = eq / 6;
}

/// Minimum axis dominance ratio before MBTI emits a pole theme.
abstract final class PersonalityMirrorThresholds {
  static const mbtiAxisDominanceMin = 0.55;
}

/// Confidence composition rules (approved design).
abstract final class PersonalityMirrorConfidenceRules {
  static const exactBoostPerExtraLens = 0.15;
  static const exactBoostCap = 0.25;
  static const familyBoost = 0.10;
  static const categoryBoost = 0.08;
  static const maxContradictionPenalty = 0.15;
  static const penaltyPerTension = 0.05;
}

