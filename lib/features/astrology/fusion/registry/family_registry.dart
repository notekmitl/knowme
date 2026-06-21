import '../domain/entities/fusion_theme.dart';
import '../domain/entities/theme_family.dart';
import 'theme_registry.dart';

/// Maps semantic [ThemeFamily] values to canonical theme ids.
abstract final class FusionFamilyRegistry {
  static const Map<ThemeFamily, List<String>> familyToThemeIds = {
    ThemeFamily.autonomy: [
      'independent',
      'leadership',
      'driven',
    ],
    ThemeFamily.structure: [
      'structured',
      'responsible',
      'reliable',
      'persistent',
    ],
    ThemeFamily.adaptation: [
      'adaptable',
      'flexible',
      'openness',
    ],
    ThemeFamily.reflection: [
      'analytical',
      'reflection',
      'overthinking',
    ],
    ThemeFamily.connection: [
      'supportive',
      'diplomatic',
      'loyal',
      'independent_connection',
    ],
    ThemeFamily.expression: [
      'expressive',
      'responsive',
      'passionate',
      'creative',
    ],
  };

  static List<String> getThemeIds(ThemeFamily family) {
    return List<String>.unmodifiable(familyToThemeIds[family] ?? const []);
  }

  static List<FusionTheme> getThemes(ThemeFamily family) {
    return getThemeIds(family)
        .map(FusionThemeRegistry.getById)
        .whereType<FusionTheme>()
        .toList();
  }

  static ThemeFamily? familyForThemeId(String themeId) {
    final normalized = themeId.trim().toLowerCase();
    for (final entry in familyToThemeIds.entries) {
      if (entry.value.contains(normalized)) return entry.key;
    }
    return FusionThemeRegistry.getById(normalized)?.family;
  }
}
