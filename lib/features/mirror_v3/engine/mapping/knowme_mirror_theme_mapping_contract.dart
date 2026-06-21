import '../../enums/knowme_mirror_dimension_id.dart';
import '../../registry/knowme_mirror_registry_v0_1.dart';

/// Maps source categories and theme ids to frozen mirror registry keys.
abstract final class KnowMeMirrorThemeMappingContract {
  static const personalityThemeOverrides = <String, String>{
    'expressive': 'MIRROR_SELF_EXPRESSION',
    'reserved': 'MIRROR_SELF_IDENTITY',
    'adaptable': 'MIRROR_SELF_IDENTITY',
    'grounded': 'MIRROR_SELF_IDENTITY',
    'structured': 'MIRROR_THINKING_PATTERN',
    'intuitive': 'MIRROR_THINKING_PATTERN',
    'analytical': 'MIRROR_THINKING_PATTERN',
    'flexible': 'MIRROR_THINKING_PATTERN',
    'responsive': 'MIRROR_EMOTIONAL_PATTERN',
    'calm': 'MIRROR_EMOTIONAL_PATTERN',
    'supportive': 'MIRROR_SUPPORT_PATTERN',
    'diplomatic': 'MIRROR_RELATIONAL_PATTERN',
    'responsible': 'MIRROR_ACTION_STYLE',
    'reliable': 'MIRROR_STRUCTURE_PATTERN',
    'creative': 'MIRROR_SELF_EXPRESSION',
  };

  static const astrologyCategoryDefaults = <String, String>{
    'core_self': 'MIRROR_SELF_IDENTITY',
    'thinking_style': 'MIRROR_THINKING_PATTERN',
    'emotional_world': 'MIRROR_EMOTIONAL_PATTERN',
    'relationships': 'MIRROR_RELATIONAL_PATTERN',
    'work_ambition': 'MIRROR_ACTION_STYLE',
    'strengths': 'MIRROR_GROWTH_ORIENTATION',
    'growth_areas': 'MIRROR_GROWTH_ORIENTATION',
    'growth_path': 'MIRROR_LIFE_DIRECTION',
  };

  static String? mirrorKeyForPersonalityTheme({
    required String themeId,
    required String categoryId,
  }) {
    final normalizedTheme = themeId.trim().toLowerCase();
    final override = personalityThemeOverrides[normalizedTheme];
    if (override != null) return override;

    return mirrorKeyForCategoryId(categoryId);
  }

  static String? mirrorKeyForAstrologyTheme({
    required String themeId,
    required String categoryId,
  }) {
    final normalizedTheme = themeId.trim().toLowerCase();
    final override = personalityThemeOverrides[normalizedTheme];
    if (override != null) return override;

    return mirrorKeyForCategoryId(categoryId);
  }

  static String? mirrorKeyForCategoryId(String categoryId) {
    final normalized = categoryId.trim().toLowerCase();
    return astrologyCategoryDefaults[normalized];
  }

  static KnowMeMirrorDimensionId? dimensionForMirrorKey(String mirrorKey) {
    return KnowMeMirrorRegistryV01.get(mirrorKey)?.mirrorDimension;
  }

  static String? patternFamilyForMirrorKey(String mirrorKey) {
    return KnowMeMirrorRegistryV01.get(mirrorKey)?.patternFamily;
  }
}
