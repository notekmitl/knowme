import '../domain/narrative_mode.dart';
import 'narrative_interaction_type.dart';

/// Deterministic pattern interaction rules for narrative synthesis.
class NarrativeInteractionRule {
  const NarrativeInteractionRule({
    required this.mode,
    required this.type,
    required this.themeKey,
    required this.patternIds,
    required this.minStrength,
  });

  final NarrativeMode mode;
  final NarrativeInteractionType type;
  final String themeKey;
  final List<String> patternIds;
  final double minStrength;
}

abstract final class NarrativePatternInteractionCatalog {
  static const _rules = <NarrativeInteractionRule>[
    NarrativeInteractionRule(
      mode: NarrativeMode.decision,
      type: NarrativeInteractionType.agreement,
      themeKey: 'consistency_theme',
      patternIds: ['structured_operator', 'accountable_operator'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.decision,
      type: NarrativeInteractionType.tension,
      themeKey: 'autonomy_vs_harmony',
      patternIds: ['independent_decision_maker', 'relationship_stabilizer'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.decision,
      type: NarrativeInteractionType.tension,
      themeKey: 'analysis_vs_action',
      patternIds: ['analytical_thinker', 'decisive_actor'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.relationship,
      type: NarrativeInteractionType.agreement,
      themeKey: 'relational_stability',
      patternIds: ['supportive_connector', 'relationship_stabilizer'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.relationship,
      type: NarrativeInteractionType.tension,
      themeKey: 'autonomy_vs_harmony',
      patternIds: ['independent_decision_maker', 'relationship_stabilizer'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.identity,
      type: NarrativeInteractionType.agreement,
      themeKey: 'autonomy_theme',
      patternIds: ['self_directed_identity', 'independent_decision_maker'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.growth,
      type: NarrativeInteractionType.agreement,
      themeKey: 'building_theme',
      patternIds: ['constructive_builder', 'progressive_builder'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.growth,
      type: NarrativeInteractionType.growthEdge,
      themeKey: 'action_vs_reflection',
      patternIds: ['growth_edge_builder', 'analytical_thinker'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.growth,
      type: NarrativeInteractionType.growthEdge,
      themeKey: 'growth_through_structure',
      patternIds: ['growth_edge_from_tension', 'structured_operator'],
      minStrength: 0.25,
    ),
    NarrativeInteractionRule(
      mode: NarrativeMode.decision,
      type: NarrativeInteractionType.growthEdge,
      themeKey: 'action_vs_reflection',
      patternIds: ['growth_edge_builder', 'analytical_thinker'],
      minStrength: 0.25,
    ),
  ];

  static List<NarrativeInteractionRule> rulesForMode(NarrativeMode mode) {
    return _rules.where((rule) => rule.mode == mode).toList(growable: false);
  }
}

abstract final class NarrativeFamilyCompressionCatalog {
  static const minClusterSize = 3;

  static const familyLabels = <String, String>{
    'identity_style': 'ตัวตน',
    'thinking_style': 'การคิด',
    'relationship_style': 'ความสัมพันธ์',
    'decision_style': 'การตัดสินใจ',
    'growth_style': 'การเติบโต',
    'theme_coverage_pattern': 'การมองเห็นตัวเอง',
  };
}
