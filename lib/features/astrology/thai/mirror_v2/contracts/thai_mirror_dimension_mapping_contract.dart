import '../../theme_v2/enums/thai_theme_category.dart';
import '../enums/thai_mirror_dimension_id.dart';

/// Frozen mapping from [ThaiThemeCategory] to mirror dimensions.
abstract final class ThaiMirrorDimensionMappingContract {
  /// Categories that contribute to cross-dimension insights only (M0).
  static const insightOnlyCategoryIds = <String>[
    'core_self',
    'work_ambition',
  ];

  static const mappedCategoryIds = <String>[
    'strengths',
    'thinking_style',
    'emotional_world',
    'relationships',
    'growth_areas',
    'growth_path',
  ];

  static ThaiMirrorDimensionId? dimensionForCategory(ThaiThemeCategory category) {
    return switch (category) {
      ThaiThemeCategory.strengths => ThaiMirrorDimensionId.prominentStrengths,
      ThaiThemeCategory.thinkingStyle => ThaiMirrorDimensionId.thinkingPattern,
      ThaiThemeCategory.emotionalWorld => ThaiMirrorDimensionId.emotionalPattern,
      ThaiThemeCategory.relationships => ThaiMirrorDimensionId.relationshipPattern,
      ThaiThemeCategory.growthAreas => ThaiMirrorDimensionId.growthFocus,
      ThaiThemeCategory.growthPath => ThaiMirrorDimensionId.growthFocus,
      ThaiThemeCategory.coreSelf => null,
      ThaiThemeCategory.workAmbition => null,
    };
  }

  static bool isInsightOnlyCategory(ThaiThemeCategory category) {
    return dimensionForCategory(category) == null;
  }
}
