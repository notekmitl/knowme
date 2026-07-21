/// Canonical Fusion theme categories (KNOWME MASTER CONTEXT Section 50.3).
enum ThemeCategory {
  coreSelf,
  thinkingStyle,
  emotionalWorld,
  relationships,
  workAndAmbition,
  strengths,
  growthAreas,
  growthPath,
}

extension ThemeCategoryLabels on ThemeCategory {
  String get id {
    switch (this) {
      case ThemeCategory.coreSelf:
        return 'core_self';
      case ThemeCategory.thinkingStyle:
        return 'thinking_style';
      case ThemeCategory.emotionalWorld:
        return 'emotional_world';
      case ThemeCategory.relationships:
        return 'relationships';
      case ThemeCategory.workAndAmbition:
        return 'work_and_ambition';
      case ThemeCategory.strengths:
        return 'strengths';
      case ThemeCategory.growthAreas:
        return 'growth_areas';
      case ThemeCategory.growthPath:
        return 'growth_path';
    }
  }

  String get displayName {
    switch (this) {
      case ThemeCategory.coreSelf:
        return 'Core Self';
      case ThemeCategory.thinkingStyle:
        return 'Thinking Style';
      case ThemeCategory.emotionalWorld:
        return 'Emotional World';
      case ThemeCategory.relationships:
        return 'Relationships';
      case ThemeCategory.workAndAmbition:
        return 'Work & Ambition';
      case ThemeCategory.strengths:
        return 'Strengths';
      case ThemeCategory.growthAreas:
        return 'Growth Areas';
      case ThemeCategory.growthPath:
        return 'Growth Path';
    }
  }

}

ThemeCategory? parseThemeCategory(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final category in ThemeCategory.values) {
    if (category.id == normalized) return category;
  }
  return null;
}
