import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

/// PF-2 core theme subset (15) — not the full 29-theme astrology registry.
abstract final class PersonalityCoreThemeIds {
  static const expressive = 'expressive';
  static const reserved = 'reserved';
  static const structured = 'structured';
  static const intuitive = 'intuitive';
  static const analytical = 'analytical';
  static const flexible = 'flexible';
  static const responsive = 'responsive';
  static const calm = 'calm';
  static const supportive = 'supportive';
  static const diplomatic = 'diplomatic';
  static const responsible = 'responsible';
  static const reliable = 'reliable';
  static const adaptable = 'adaptable';
  static const grounded = 'grounded';
  static const creative = 'creative';

  static const all = <String>[
    expressive,
    reserved,
    structured,
    intuitive,
    analytical,
    flexible,
    responsive,
    calm,
    supportive,
    diplomatic,
    responsible,
    reliable,
    adaptable,
    grounded,
    creative,
  ];
}

class PersonalityCoreTheme {
  const PersonalityCoreTheme({
    required this.id,
    required this.category,
    required this.family,
  });

  final String id;
  final FusionCategory category;
  final ThemeFamily family;
}

abstract final class PersonalityCoreThemeRegistry {
  static const Map<String, PersonalityCoreTheme> byId = {
    PersonalityCoreThemeIds.expressive: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.expressive,
      category: FusionCategory.coreSelf,
      family: ThemeFamily.expression,
    ),
    PersonalityCoreThemeIds.reserved: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.reserved,
      category: FusionCategory.coreSelf,
      family: ThemeFamily.reflection,
    ),
    PersonalityCoreThemeIds.structured: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.structured,
      category: FusionCategory.thinkingStyle,
      family: ThemeFamily.structure,
    ),
    PersonalityCoreThemeIds.intuitive: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.intuitive,
      category: FusionCategory.thinkingStyle,
      family: ThemeFamily.reflection,
    ),
    PersonalityCoreThemeIds.analytical: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.analytical,
      category: FusionCategory.thinkingStyle,
      family: ThemeFamily.reflection,
    ),
    PersonalityCoreThemeIds.flexible: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.flexible,
      category: FusionCategory.thinkingStyle,
      family: ThemeFamily.adaptation,
    ),
    PersonalityCoreThemeIds.responsive: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.responsive,
      category: FusionCategory.emotionalWorld,
      family: ThemeFamily.expression,
    ),
    PersonalityCoreThemeIds.calm: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.calm,
      category: FusionCategory.emotionalWorld,
      family: ThemeFamily.reflection,
    ),
    PersonalityCoreThemeIds.supportive: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.supportive,
      category: FusionCategory.relationships,
      family: ThemeFamily.connection,
    ),
    PersonalityCoreThemeIds.diplomatic: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.diplomatic,
      category: FusionCategory.relationships,
      family: ThemeFamily.connection,
    ),
    PersonalityCoreThemeIds.responsible: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.responsible,
      category: FusionCategory.workAndAmbition,
      family: ThemeFamily.structure,
    ),
    PersonalityCoreThemeIds.reliable: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.reliable,
      category: FusionCategory.strengths,
      family: ThemeFamily.structure,
    ),
    PersonalityCoreThemeIds.adaptable: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.adaptable,
      category: FusionCategory.coreSelf,
      family: ThemeFamily.adaptation,
    ),
    PersonalityCoreThemeIds.grounded: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.grounded,
      category: FusionCategory.coreSelf,
      family: ThemeFamily.structure,
    ),
    PersonalityCoreThemeIds.creative: PersonalityCoreTheme(
      id: PersonalityCoreThemeIds.creative,
      category: FusionCategory.strengths,
      family: ThemeFamily.expression,
    ),
  };

  static bool contains(String themeId) =>
      byId.containsKey(themeId.trim().toLowerCase());

  static PersonalityCoreTheme? get(String themeId) =>
      byId[themeId.trim().toLowerCase()];
}
