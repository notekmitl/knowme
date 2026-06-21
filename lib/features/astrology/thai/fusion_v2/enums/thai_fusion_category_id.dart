/// Fusion category aligned with frozen [ThaiThemeCategory] ids.
enum ThaiFusionCategoryId {
  coreSelf,
  thinkingStyle,
  emotionalWorld,
  relationships,
  workAmbition,
  strengths,
  growthAreas,
  growthPath,
}

extension ThaiFusionCategoryIdLabels on ThaiFusionCategoryId {
  String get id {
    return switch (this) {
      ThaiFusionCategoryId.coreSelf => 'core_self',
      ThaiFusionCategoryId.thinkingStyle => 'thinking_style',
      ThaiFusionCategoryId.emotionalWorld => 'emotional_world',
      ThaiFusionCategoryId.relationships => 'relationships',
      ThaiFusionCategoryId.workAmbition => 'work_ambition',
      ThaiFusionCategoryId.strengths => 'strengths',
      ThaiFusionCategoryId.growthAreas => 'growth_areas',
      ThaiFusionCategoryId.growthPath => 'growth_path',
    };
  }
}

ThaiFusionCategoryId? parseThaiFusionCategoryId(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final category in ThaiFusionCategoryId.values) {
    if (category.id == normalized) {
      return category;
    }
  }
  return null;
}
