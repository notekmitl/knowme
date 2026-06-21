import '../domain/entities/fusion_category.dart';
import '../domain/entities/fusion_theme.dart';
import '../domain/entities/theme_family.dart';

/// Immutable canonical theme dictionary for Astrology Fusion V1 (29 themes).
abstract final class FusionThemeRegistry {
  static const String version = 'v1';

  static const List<FusionTheme> all = [
    // --- Core Self (5) ---
    FusionTheme(
      id: 'independent',
      name: 'Independent',
      category: FusionCategory.coreSelf,
      family: ThemeFamily.autonomy,
      description: 'Tends to value autonomy and self-direction.',
    ),
    FusionTheme(
      id: 'adaptable',
      name: 'Adaptable',
      category: FusionCategory.coreSelf,
      family: ThemeFamily.adaptation,
      description: 'Tends to adjust approach when circumstances shift.',
    ),
    FusionTheme(
      id: 'grounded',
      name: 'Grounded',
      category: FusionCategory.coreSelf,
      family: ThemeFamily.structure,
      description: 'Tends to seek stability and a steady sense of footing.',
    ),
    FusionTheme(
      id: 'expressive',
      name: 'Expressive',
      category: FusionCategory.coreSelf,
      family: ThemeFamily.expression,
      description: 'Tends to show inner orientation openly when safe.',
    ),
    FusionTheme(
      id: 'reserved',
      name: 'Reserved',
      category: FusionCategory.coreSelf,
      family: ThemeFamily.reflection,
      description: 'Tends to keep inner orientation private until trust builds.',
    ),

    // --- Thinking Style (4) ---
    FusionTheme(
      id: 'analytical',
      name: 'Analytical',
      category: FusionCategory.thinkingStyle,
      family: ThemeFamily.reflection,
      description: 'Tends to break problems into parts before deciding.',
    ),
    FusionTheme(
      id: 'structured',
      name: 'Structured',
      category: FusionCategory.thinkingStyle,
      family: ThemeFamily.structure,
      description: 'Tends to organize thought into ordered steps or frameworks.',
    ),
    FusionTheme(
      id: 'intuitive',
      name: 'Intuitive',
      category: FusionCategory.thinkingStyle,
      family: ThemeFamily.reflection,
      description: 'Tends to sense patterns before full analysis is complete.',
    ),
    FusionTheme(
      id: 'flexible',
      name: 'Flexible',
      category: FusionCategory.thinkingStyle,
      family: ThemeFamily.adaptation,
      description: 'Tends to shift mental approach when new information appears.',
    ),

    // --- Emotional World (3) ---
    FusionTheme(
      id: 'responsive',
      name: 'Responsive',
      category: FusionCategory.emotionalWorld,
      family: ThemeFamily.expression,
      description: 'Tends to react to emotional cues with attentiveness.',
    ),
    FusionTheme(
      id: 'calm',
      name: 'Calm',
      category: FusionCategory.emotionalWorld,
      family: ThemeFamily.reflection,
      description: 'Tends to maintain emotional steadiness under pressure.',
    ),
    FusionTheme(
      id: 'passionate',
      name: 'Passionate',
      category: FusionCategory.emotionalWorld,
      family: ThemeFamily.expression,
      description: 'Tends to experience feelings with depth and intensity.',
    ),

    // --- Relationships (4) ---
    FusionTheme(
      id: 'supportive',
      name: 'Supportive',
      category: FusionCategory.relationships,
      family: ThemeFamily.connection,
      description: 'Tends to offer care and encouragement to others.',
    ),
    FusionTheme(
      id: 'diplomatic',
      name: 'Diplomatic',
      category: FusionCategory.relationships,
      family: ThemeFamily.connection,
      description: 'Tends to navigate differences with tact and balance.',
    ),
    FusionTheme(
      id: 'loyal',
      name: 'Loyal',
      category: FusionCategory.relationships,
      family: ThemeFamily.connection,
      description: 'Tends to stay committed once trust is established.',
    ),
    FusionTheme(
      id: 'independent_connection',
      name: 'IndependentConnection',
      category: FusionCategory.relationships,
      family: ThemeFamily.connection,
      description: 'Tends to value personal space within close bonds.',
    ),

    // --- Work & Ambition (4) ---
    FusionTheme(
      id: 'driven',
      name: 'Driven',
      category: FusionCategory.workAndAmbition,
      family: ThemeFamily.autonomy,
      description: 'Tends to pursue goals with forward momentum.',
    ),
    FusionTheme(
      id: 'responsible',
      name: 'Responsible',
      category: FusionCategory.workAndAmbition,
      family: ThemeFamily.structure,
      description: 'Tends to honor commitments and follow through reliably.',
    ),
    FusionTheme(
      id: 'leadership',
      name: 'Leadership',
      category: FusionCategory.workAndAmbition,
      family: ThemeFamily.autonomy,
      description: 'Tends to guide direction and coordinate effort.',
    ),
    FusionTheme(
      id: 'growth_focused',
      name: 'GrowthFocused',
      category: FusionCategory.workAndAmbition,
      family: ThemeFamily.adaptation,
      description: 'Tends to orient work toward learning and development.',
    ),

    // --- Strengths (3) ---
    FusionTheme(
      id: 'reliable',
      name: 'Reliable',
      category: FusionCategory.strengths,
      family: ThemeFamily.structure,
      description: 'Tends to follow through on commitments consistently.',
    ),
    FusionTheme(
      id: 'persistent',
      name: 'Persistent',
      category: FusionCategory.strengths,
      family: ThemeFamily.structure,
      description: 'Tends to keep going despite obstacles or slow progress.',
    ),
    FusionTheme(
      id: 'creative',
      name: 'Creative',
      category: FusionCategory.strengths,
      family: ThemeFamily.expression,
      description: 'Tends to generate fresh ideas and novel solutions.',
    ),

    // --- Growth Areas (3) ---
    FusionTheme(
      id: 'overthinking',
      name: 'Overthinking',
      category: FusionCategory.growthAreas,
      family: ThemeFamily.reflection,
      description: 'May loop on analysis instead of moving forward.',
    ),
    FusionTheme(
      id: 'rigidity',
      name: 'Rigidity',
      category: FusionCategory.growthAreas,
      family: ThemeFamily.structure,
      description: 'May hold too tightly to plans when flexibility would help.',
    ),
    FusionTheme(
      id: 'impatience',
      name: 'Impatience',
      category: FusionCategory.growthAreas,
      family: ThemeFamily.expression,
      description: 'May act quickly before fully weighing consequences.',
    ),

    // --- Growth Path (3) ---
    FusionTheme(
      id: 'balance',
      name: 'Balance',
      category: FusionCategory.growthPath,
      family: ThemeFamily.adaptation,
      description: 'Growth may come from blending opposing tendencies.',
    ),
    FusionTheme(
      id: 'reflection',
      name: 'Reflection',
      category: FusionCategory.growthPath,
      family: ThemeFamily.reflection,
      description: 'Growth may come from pausing to consider meaning and direction.',
    ),
    FusionTheme(
      id: 'openness',
      name: 'Openness',
      category: FusionCategory.growthPath,
      family: ThemeFamily.adaptation,
      description: 'Growth may come from welcoming new perspectives and experiences.',
    ),
  ];

  static final Map<String, FusionTheme> _byId = {
    for (final theme in all) theme.id: theme,
  };

  static final Map<FusionCategory, List<FusionTheme>> _byCategory = {
    for (final category in FusionCategory.values)
      category: all.where((theme) => theme.category == category).toList(),
  };

  static List<FusionTheme> getAll() {
    return List<FusionTheme>.unmodifiable(all);
  }

  static FusionTheme? getById(String id) {
    return _byId[id.trim().toLowerCase()];
  }

  static List<FusionTheme> getByCategory(FusionCategory category) {
    return List<FusionTheme>.unmodifiable(_byCategory[category] ?? const []);
  }

  static bool contains(String id) => _byId.containsKey(id.trim().toLowerCase());

  static int get count => all.length;
}
