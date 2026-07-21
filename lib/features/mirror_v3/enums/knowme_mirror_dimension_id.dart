/// Shared human dimensions — system-independent (MV0 frozen).
enum KnowMeMirrorDimensionId {
  identity,
  expression,
  relationships,
  resources,
  action,
  growth,
  visibility,
  transformation,
  beliefs,
  innerWorld,
  lifeDirection,
}

extension KnowMeMirrorDimensionIdLabels on KnowMeMirrorDimensionId {
  String get id {
    return switch (this) {
      KnowMeMirrorDimensionId.identity => 'identity',
      KnowMeMirrorDimensionId.expression => 'expression',
      KnowMeMirrorDimensionId.relationships => 'relationships',
      KnowMeMirrorDimensionId.resources => 'resources',
      KnowMeMirrorDimensionId.action => 'action',
      KnowMeMirrorDimensionId.growth => 'growth',
      KnowMeMirrorDimensionId.visibility => 'visibility',
      KnowMeMirrorDimensionId.transformation => 'transformation',
      KnowMeMirrorDimensionId.beliefs => 'beliefs',
      KnowMeMirrorDimensionId.innerWorld => 'inner_world',
      KnowMeMirrorDimensionId.lifeDirection => 'life_direction',
    };
  }
}

KnowMeMirrorDimensionId? parseKnowMeMirrorDimensionId(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final dimension in KnowMeMirrorDimensionId.values) {
    if (dimension.id == normalized) {
      return dimension;
    }
  }
  return null;
}
