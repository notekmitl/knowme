/// Theme category for a [ThaiThemeScore].
enum ThaiThemeCategory {
  coreSelf,
  thinkingStyle,
  emotionalWorld,
  relationships,
  workAmbition,
  strengths,
  growthAreas,
  growthPath,
}

extension ThaiThemeCategoryLabels on ThaiThemeCategory {
  String get id {
    return switch (this) {
      ThaiThemeCategory.coreSelf => 'core_self',
      ThaiThemeCategory.thinkingStyle => 'thinking_style',
      ThaiThemeCategory.emotionalWorld => 'emotional_world',
      ThaiThemeCategory.relationships => 'relationships',
      ThaiThemeCategory.workAmbition => 'work_ambition',
      ThaiThemeCategory.strengths => 'strengths',
      ThaiThemeCategory.growthAreas => 'growth_areas',
      ThaiThemeCategory.growthPath => 'growth_path',
    };
  }
}

ThaiThemeCategory? parseThaiThemeCategory(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final category in ThaiThemeCategory.values) {
    if (category.id == normalized) {
      return category;
    }
  }
  return null;
}
