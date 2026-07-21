/// Canonical human dimensions — discipline-neutral (HM2).
enum HumanDimensionId {
  identity,
  motivation,
  thinking,
  emotion,
  relationship,
  action,
  growth,
  meaning,
}

extension HumanDimensionIdLabels on HumanDimensionId {
  String get key {
    return switch (this) {
      HumanDimensionId.identity => 'identity',
      HumanDimensionId.motivation => 'motivation',
      HumanDimensionId.thinking => 'thinking',
      HumanDimensionId.emotion => 'emotion',
      HumanDimensionId.relationship => 'relationship',
      HumanDimensionId.action => 'action',
      HumanDimensionId.growth => 'growth',
      HumanDimensionId.meaning => 'meaning',
    };
  }

  String get label {
    return switch (this) {
      HumanDimensionId.identity => 'Identity',
      HumanDimensionId.motivation => 'Motivation',
      HumanDimensionId.thinking => 'Thinking',
      HumanDimensionId.emotion => 'Emotion',
      HumanDimensionId.relationship => 'Relationship',
      HumanDimensionId.action => 'Action',
      HumanDimensionId.growth => 'Growth',
      HumanDimensionId.meaning => 'Meaning',
    };
  }
}

HumanDimensionId? parseHumanDimensionId(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final dimension in HumanDimensionId.values) {
    if (dimension.key == normalized) return dimension;
  }
  return null;
}
