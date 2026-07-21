/// Priority tier for activated patterns within a narrative mode.
enum NarrativePatternTier {
  dominant,
  supporting,
  background,
}

extension NarrativePatternTierLabels on NarrativePatternTier {
  String get key {
    return switch (this) {
      NarrativePatternTier.dominant => 'dominant',
      NarrativePatternTier.supporting => 'supporting',
      NarrativePatternTier.background => 'background',
    };
  }
}
