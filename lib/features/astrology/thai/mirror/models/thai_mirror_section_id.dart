import '../../../../../core/themes/theme_category.dart';
import '../../content/models/thai_fusion_theme_category.dart';

/// Canonical section ids for [ThaiMirrorResult].
///
/// Aligns with KNOWME Fusion categories plus a cross-cutting [topThemes] view.
enum ThaiMirrorSectionId {
  topThemes,
  coreSelf,
  thinkingStyle,
  emotionalWorld,
  relationships,
  workAndAmbition,
  strengths,
  growthAreas,
  growthPath,
}

extension ThaiMirrorSectionIdLabels on ThaiMirrorSectionId {
  String get id {
    return switch (this) {
      ThaiMirrorSectionId.topThemes => 'top_themes',
      ThaiMirrorSectionId.coreSelf => 'core_self',
      ThaiMirrorSectionId.thinkingStyle => 'thinking_style',
      ThaiMirrorSectionId.emotionalWorld => 'emotional_world',
      ThaiMirrorSectionId.relationships => 'relationships',
      ThaiMirrorSectionId.workAndAmbition => 'work_and_ambition',
      ThaiMirrorSectionId.strengths => 'strengths',
      ThaiMirrorSectionId.growthAreas => 'growth_areas',
      ThaiMirrorSectionId.growthPath => 'growth_path',
    };
  }

  String get titleEn {
    return switch (this) {
      ThaiMirrorSectionId.topThemes => 'Top Themes',
      ThaiMirrorSectionId.coreSelf => 'Core Self',
      ThaiMirrorSectionId.thinkingStyle => 'Thinking Style',
      ThaiMirrorSectionId.emotionalWorld => 'Emotional World',
      ThaiMirrorSectionId.relationships => 'Relationships',
      ThaiMirrorSectionId.workAndAmbition => 'Work & Ambition',
      ThaiMirrorSectionId.strengths => 'Strengths',
      ThaiMirrorSectionId.growthAreas => 'Growth Areas',
      ThaiMirrorSectionId.growthPath => 'Growth Path',
    };
  }

  String get titleTh {
    return switch (this) {
      ThaiMirrorSectionId.topThemes => 'ธีมเด่น',
      ThaiMirrorSectionId.coreSelf => 'แก่นตัวตน',
      ThaiMirrorSectionId.thinkingStyle => 'รูปแบบการคิด',
      ThaiMirrorSectionId.emotionalWorld => 'โลกอารมณ์',
      ThaiMirrorSectionId.relationships => 'ความสัมพันธ์',
      ThaiMirrorSectionId.workAndAmbition => 'งานและความทะเยอทะยาน',
      ThaiMirrorSectionId.strengths => 'จุดแข็ง',
      ThaiMirrorSectionId.growthAreas => 'พื้นที่เติบโต',
      ThaiMirrorSectionId.growthPath => 'เส้นทางเติบโต',
    };
  }

  /// Fusion-facing sections only (excludes [topThemes]).
  bool get isFusionSection => this != ThaiMirrorSectionId.topThemes;

  ThemeCategory? get themeCategory {
    return switch (this) {
      ThaiMirrorSectionId.topThemes => null,
      ThaiMirrorSectionId.coreSelf => ThemeCategory.coreSelf,
      ThaiMirrorSectionId.thinkingStyle => ThemeCategory.thinkingStyle,
      ThaiMirrorSectionId.emotionalWorld => ThemeCategory.emotionalWorld,
      ThaiMirrorSectionId.relationships => ThemeCategory.relationships,
      ThaiMirrorSectionId.workAndAmbition => ThemeCategory.workAndAmbition,
      ThaiMirrorSectionId.strengths => ThemeCategory.strengths,
      ThaiMirrorSectionId.growthAreas => ThemeCategory.growthAreas,
      ThaiMirrorSectionId.growthPath => ThemeCategory.growthPath,
    };
  }

  ThaiFusionThemeCategory? get fusionCategory {
    return switch (this) {
      ThaiMirrorSectionId.topThemes => null,
      ThaiMirrorSectionId.coreSelf => ThaiFusionThemeCategory.coreSelf,
      ThaiMirrorSectionId.thinkingStyle =>
        ThaiFusionThemeCategory.thinkingStyle,
      ThaiMirrorSectionId.emotionalWorld =>
        ThaiFusionThemeCategory.emotionalWorld,
      ThaiMirrorSectionId.relationships => ThaiFusionThemeCategory.relationships,
      ThaiMirrorSectionId.workAndAmbition =>
        ThaiFusionThemeCategory.workAndAmbition,
      ThaiMirrorSectionId.strengths => ThaiFusionThemeCategory.strengths,
      ThaiMirrorSectionId.growthAreas => ThaiFusionThemeCategory.growthAreas,
      ThaiMirrorSectionId.growthPath => ThaiFusionThemeCategory.growthPath,
    };
  }
}

ThaiMirrorSectionId? parseThaiMirrorSectionId(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final section in ThaiMirrorSectionId.values) {
    if (section.id == normalized) return section;
  }
  return null;
}
