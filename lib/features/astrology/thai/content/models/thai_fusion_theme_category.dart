/// Fusion Theme categories aligned with KNOWME MASTER CONTEXT Section 50.3.
enum ThaiFusionThemeCategory {
  coreSelf,
  thinkingStyle,
  emotionalWorld,
  relationships,
  workAndAmbition,
  strengths,
  growthAreas,
  growthPath,
}

extension ThaiFusionThemeCategoryLabels on ThaiFusionThemeCategory {
  String get id {
    switch (this) {
      case ThaiFusionThemeCategory.coreSelf:
        return 'core_self';
      case ThaiFusionThemeCategory.thinkingStyle:
        return 'thinking_style';
      case ThaiFusionThemeCategory.emotionalWorld:
        return 'emotional_world';
      case ThaiFusionThemeCategory.relationships:
        return 'relationships';
      case ThaiFusionThemeCategory.workAndAmbition:
        return 'work_and_ambition';
      case ThaiFusionThemeCategory.strengths:
        return 'strengths';
      case ThaiFusionThemeCategory.growthAreas:
        return 'growth_areas';
      case ThaiFusionThemeCategory.growthPath:
        return 'growth_path';
    }
  }

  String labelTh() {
    switch (this) {
      case ThaiFusionThemeCategory.coreSelf:
        return 'แก่นตัวตน';
      case ThaiFusionThemeCategory.thinkingStyle:
        return 'รูปแบบการคิด';
      case ThaiFusionThemeCategory.emotionalWorld:
        return 'โลกอารมณ์';
      case ThaiFusionThemeCategory.relationships:
        return 'ความสัมพันธ์';
      case ThaiFusionThemeCategory.workAndAmbition:
        return 'งานและความทะเยอทะยาน';
      case ThaiFusionThemeCategory.strengths:
        return 'จุดแข็ง';
      case ThaiFusionThemeCategory.growthAreas:
        return 'พื้นที่เติบโต';
      case ThaiFusionThemeCategory.growthPath:
        return 'เส้นทางเติบโต';
    }
  }

}

ThaiFusionThemeCategory? parseThaiFusionThemeCategory(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final category in ThaiFusionThemeCategory.values) {
    if (category.id == normalized) return category;
  }
  return null;
}
