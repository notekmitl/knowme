/// Mirror-level exploration identifiers (EO-F0).
enum ExplorationMirrorId {
  astrologyMirror,
  personalityMirror;

  String get id => switch (this) {
        ExplorationMirrorId.astrologyMirror => 'astrology_mirror',
        ExplorationMirrorId.personalityMirror => 'personality_mirror',
      };

  static const all = <ExplorationMirrorId>[
    ExplorationMirrorId.astrologyMirror,
    ExplorationMirrorId.personalityMirror,
  ];
}
