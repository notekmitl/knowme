/// Self-understanding dimension for [ThaiMirrorDimension].
enum ThaiMirrorDimensionId {
  prominentStrengths,
  thinkingPattern,
  emotionalPattern,
  relationshipPattern,
  growthFocus,
}

extension ThaiMirrorDimensionIdLabels on ThaiMirrorDimensionId {
  String get id {
    return switch (this) {
      ThaiMirrorDimensionId.prominentStrengths => 'prominent_strengths',
      ThaiMirrorDimensionId.thinkingPattern => 'thinking_pattern',
      ThaiMirrorDimensionId.emotionalPattern => 'emotional_pattern',
      ThaiMirrorDimensionId.relationshipPattern => 'relationship_pattern',
      ThaiMirrorDimensionId.growthFocus => 'growth_focus',
    };
  }
}

ThaiMirrorDimensionId? parseThaiMirrorDimensionId(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final dimension in ThaiMirrorDimensionId.values) {
    if (dimension.id == normalized) {
      return dimension;
    }
  }
  return null;
}
