/// Mirror-level lens identifiers for Global Fusion (not raw system IDs).
enum GlobalLensId {
  astrologyMirror,
  personalityMirror,
}

extension GlobalLensIdIds on GlobalLensId {
  String get id {
    return switch (this) {
      GlobalLensId.astrologyMirror => 'astrology_mirror',
      GlobalLensId.personalityMirror => 'personality_mirror',
    };
  }
}
