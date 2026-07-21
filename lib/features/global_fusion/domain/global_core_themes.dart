import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

import 'global_theme_contract.dart';

/// Global Theme Contract v1 — stable human-meaning layer (GF-F1.5).
abstract final class GlobalThemeIds {
  static const reflection = 'reflection';
  static const structure = 'structure';
  static const adaptability = 'adaptability';
  static const relationships = 'relationships';
  static const expression = 'expression';
  static const autonomy = 'autonomy';
  static const growth = 'growth';

  /// Canonical v1 theme list — source of truth for GF-F2+.
  static const v1Themes = <String>[
    reflection,
    structure,
    adaptability,
    relationships,
    expression,
    autonomy,
    growth,
  ];

  @Deprecated('Use v1Themes — GF-F1.5 stabilized theme space')
  static const foundationSubset = v1Themes;
}

/// Canonical global theme entry with explicit human intent.
class GlobalTheme {
  const GlobalTheme({
    required this.id,
    required this.label,
    required this.category,
    required this.primaryFamily,
    required this.intent,
    required this.description,
  });

  final String id;
  final String label;
  final FusionCategory category;
  final ThemeFamily primaryFamily;
  final String intent;
  final String description;

  @override
  bool operator ==(Object other) {
    return other is GlobalTheme && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

abstract final class GlobalThemeRegistry {
  static const Map<String, GlobalTheme> byId = {
    GlobalThemeIds.reflection: GlobalTheme(
      id: GlobalThemeIds.reflection,
      label: 'Reflection',
      category: FusionCategory.coreSelf,
      primaryFamily: ThemeFamily.reflection,
      intent:
          'Preference for inner processing, contemplation, analytical depth, '
          'and thoughtful pause before action.',
      description: 'Inner processing, contemplation, and thoughtful depth.',
    ),
    GlobalThemeIds.structure: GlobalTheme(
      id: GlobalThemeIds.structure,
      label: 'Structure',
      category: FusionCategory.thinkingStyle,
      primaryFamily: ThemeFamily.structure,
      intent:
          'Preference for clarity, planning, stability, predictability, '
          'and organized follow-through.',
      description: 'Order, reliability, and organized approach.',
    ),
    GlobalThemeIds.adaptability: GlobalTheme(
      id: GlobalThemeIds.adaptability,
      label: 'Adaptability',
      category: FusionCategory.coreSelf,
      primaryFamily: ThemeFamily.adaptation,
      intent:
          'Preference for flexibility, responsive adjustment, openness to '
          'changing conditions, and practical recalibration.',
      description: 'Flexibility and responsive adjustment to change.',
    ),
    GlobalThemeIds.relationships: GlobalTheme(
      id: GlobalThemeIds.relationships,
      label: 'Relationships',
      category: FusionCategory.relationships,
      primaryFamily: ThemeFamily.connection,
      intent:
          'Preference for connection, mutual support, interpersonal attunement, '
          'and relational steadiness.',
      description: 'Connection, support, and interpersonal awareness.',
    ),
    GlobalThemeIds.expression: GlobalTheme(
      id: GlobalThemeIds.expression,
      label: 'Expression',
      category: FusionCategory.emotionalWorld,
      primaryFamily: ThemeFamily.expression,
      intent:
          'Preference for visible self-presentation, emotional responsiveness, '
          'creative outward expression, and open communication of inner state.',
      description: 'Outward emotional and creative expression.',
    ),
    GlobalThemeIds.autonomy: GlobalTheme(
      id: GlobalThemeIds.autonomy,
      label: 'Autonomy',
      category: FusionCategory.coreSelf,
      primaryFamily: ThemeFamily.autonomy,
      intent:
          'Preference for self-direction, independence, personal agency, '
          'and defining one\'s own path without excessive external constraint.',
      description: 'Self-direction and independent orientation.',
    ),
    GlobalThemeIds.growth: GlobalTheme(
      id: GlobalThemeIds.growth,
      label: 'Growth',
      category: FusionCategory.growthPath,
      primaryFamily: ThemeFamily.adaptation,
      intent:
          'Preference for development, learning, forward movement, '
          'transformation, and long-term personal expansion.',
      description: 'Development, expansion, and forward movement.',
    ),
  };

  static bool contains(String themeId) =>
      byId.containsKey(themeId.trim().toLowerCase());

  static GlobalTheme? get(String themeId) =>
      byId[themeId.trim().toLowerCase()];

  static List<GlobalTheme> get allV1 =>
      GlobalThemeIds.v1Themes.map((id) => byId[id]!).toList(growable: false);
}
