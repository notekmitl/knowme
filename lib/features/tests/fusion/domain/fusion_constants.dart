/// Firestore result document ids under `users/{uid}/results/`.
/// Fusion reads this collection only — never `tests/*` or `astrology/*`.
abstract final class FusionResultDocIds {
  static const astrology = 'astrology';
  static const mbtiMini = 'mbti_mini';
  static const mbtiCognitive = 'mbti_cognitive';
}

/// Locked V1 signal taxonomy — do not extend without a version bump.
abstract final class FusionSignalIds {
  static const openness = 'openness';
  static const exploration = 'exploration';
  static const structure = 'structure';
  static const reflection = 'reflection';
  static const socialExpression = 'social_expression';
  static const logicOrientation = 'logic_orientation';
  static const intuition = 'intuition';
  static const emotionalProcessing = 'emotional_processing';
  static const emotionalSensitivity = 'emotional_sensitivity';
  static const curiosity = 'curiosity';

  static const all = <String>[
    openness,
    exploration,
    structure,
    reflection,
    socialExpression,
    logicOrientation,
    intuition,
    emotionalProcessing,
    emotionalSensitivity,
    curiosity,
  ];
}

/// Confidence tiers aligned with V1 (16 / 40 / 80).
abstract final class FusionSignalConfidence {
  static const low = 16;
  static const medium = 40;
  static const high = 80;
}

/// Locked V1 theme ids for synthesis (max 4 themes).
abstract final class FusionThemeIds {
  static const exploration = 'exploration';
  static const thinkingStyle = 'thinking_style';
  static const emotion = 'emotion';
  static const socialExpression = 'social_expression';
}
