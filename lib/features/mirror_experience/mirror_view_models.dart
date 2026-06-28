// P3 — the plain-language view models the experience renders.
//
// These are built by `MirrorExperienceService` from the Fusion Runtime's
// structured result. They speak about life, not astrology: no planet, no engine,
// no system terminology. The numeric detail (`strength`, `clarity`) is kept for
// the expandable "evidence" sections; the surface copy stays emotional.

/// How a life area feels right now.
enum MirrorTone {
  /// A clear source of momentum.
  strong,

  /// Holding steady, no big swings.
  steady,

  /// Asking for more care.
  tender,
}

/// The gentle direction a decision leans.
enum MirrorLean {
  goFor,
  prepare,
  wait,
}

/// One life area surfaced from the fused result.
class MirrorLifeArea {
  const MirrorLifeArea({
    required this.key,
    required this.title,
    required this.tone,
    required this.strength,
    required this.summary,
    required this.highlighted,
  });

  /// The underlying domain key (kept for the technical/expandable view only).
  final String key;
  final String title;
  final MirrorTone tone;

  /// Absolute strength of the signal (technical detail).
  final int strength;
  final String summary;

  /// Whether this is a headline area (top priority / cross-signal agreement).
  final bool highlighted;
}

/// How clear the overall read is.
class MirrorClarity {
  const MirrorClarity({required this.value, required this.label});

  final int value;
  final String label;
}

/// "Your current life" — the opening read.
class MirrorInsight {
  const MirrorInsight({
    required this.headline,
    required this.body,
    required this.areas,
    required this.clarity,
  });

  final String headline;
  final String body;
  final List<MirrorLifeArea> areas;
  final MirrorClarity clarity;
}

/// The forward-looking read.
class MirrorPrediction {
  const MirrorPrediction({
    required this.headline,
    required this.body,
    required this.areas,
    required this.clarity,
  });

  final String headline;
  final String body;
  final List<MirrorLifeArea> areas;
  final MirrorClarity clarity;
}

/// The gentle, life-oriented decision read.
class MirrorDecision {
  const MirrorDecision({
    required this.headline,
    required this.body,
    required this.focus,
    required this.lean,
    required this.clarity,
  });

  final String headline;
  final String body;
  final MirrorLifeArea focus;
  final MirrorLean lean;
  final MirrorClarity clarity;
}

/// The closing reflection.
class MirrorReflectionData {
  const MirrorReflectionData({
    required this.headline,
    required this.body,
    required this.keyAreas,
    required this.prompt,
  });

  final String headline;
  final String body;
  final List<MirrorLifeArea> keyAreas;
  final String prompt;
}
