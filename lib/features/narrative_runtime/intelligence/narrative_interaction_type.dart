/// How multiple pattern activations combine into one narrative insight.
enum NarrativeInteractionType {
  single,
  agreement,
  tension,
  growthEdge,
  blindSpot,
  compressed,
}

extension NarrativeInteractionTypeLabels on NarrativeInteractionType {
  String get key {
    return switch (this) {
      NarrativeInteractionType.single => 'single',
      NarrativeInteractionType.agreement => 'agreement',
      NarrativeInteractionType.tension => 'tension',
      NarrativeInteractionType.growthEdge => 'growth_edge',
      NarrativeInteractionType.blindSpot => 'blind_spot',
      NarrativeInteractionType.compressed => 'compressed',
    };
  }
}
