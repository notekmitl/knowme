import 'package:knowme/features/human_model/domain/human_dimension.dart';

import '../constants/human_pattern_system_version.dart';
import 'human_pattern_activation_rule.dart';

/// Canonical registry entry (HP2).
class CanonicalHumanPatternEntry {
  const CanonicalHumanPatternEntry({
    required this.patternId,
    required this.label,
    required this.dimension,
    required this.description,
    required this.patternFamilyId,
    required this.activationRule,
  });

  final String patternId;
  final String label;
  final HumanDimensionId dimension;
  final String description;
  final String patternFamilyId;
  final HumanPatternActivationRule activationRule;

  Map<String, dynamic> toMap() {
    return {
      'patternId': patternId,
      'label': label,
      'dimension': dimension.key,
      'description': description,
      'patternFamilyId': patternFamilyId,
      'activationRule': activationRule.toMap(),
    };
  }
}

/// Versioned deterministic human pattern registry (HP2).
abstract final class HumanPatternRegistry {
  static const version = HumanPatternSystemVersion.registryVersion;

  static CanonicalHumanPatternEntry? byId(String patternId) {
    return _byId[patternId];
  }

  static List<CanonicalHumanPatternEntry> byDimension(
    HumanDimensionId dimension,
  ) {
    return _byDimension[dimension] ?? const [];
  }

  static List<CanonicalHumanPatternEntry> get allEntries {
    return List<CanonicalHumanPatternEntry>.unmodifiable(_entries);
  }

  static List<String> get allPatternIds {
    return _entries.map((entry) => entry.patternId).toList()..sort();
  }

  static final Map<String, CanonicalHumanPatternEntry> _byId = {
    for (final entry in _entries) entry.patternId: entry,
  };

  static final Map<HumanDimensionId, List<CanonicalHumanPatternEntry>>
      _byDimension = {
    for (final dimension in HumanDimensionId.values)
      dimension:
          _entries.where((entry) => entry.dimension == dimension).toList(),
  };

  static const _entries = <CanonicalHumanPatternEntry>[
    CanonicalHumanPatternEntry(
      patternId: 'self_directed_identity',
      label: 'Self-Directed Identity',
      dimension: HumanDimensionId.identity,
      description: 'Identity anchored in autonomous self-definition signals.',
      patternFamilyId: 'identity_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'identity_self_directed',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_SELF_IDENTITY',
        requiredDimensionKey: 'identity',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'expressive_identity',
      label: 'Expressive Identity',
      dimension: HumanDimensionId.identity,
      description: 'Identity expressed through visible self-presentation signals.',
      patternFamilyId: 'identity_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'identity_expressive',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_SELF_EXPRESSION',
        requiredDimensionKey: 'identity',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'visible_identity',
      label: 'Visible Identity',
      dimension: HumanDimensionId.identity,
      description: 'Identity shaped by public visibility and presence signals.',
      patternFamilyId: 'identity_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'identity_visible',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_PUBLIC_VISIBILITY',
        requiredDimensionKey: 'identity',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'purpose_driven_motivation',
      label: 'Purpose-Driven Motivation',
      dimension: HumanDimensionId.motivation,
      description: 'Motivation aligned to directional life-purpose signals.',
      patternFamilyId: 'motivation_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'motivation_purpose',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_LIFE_DIRECTION',
        requiredDimensionKey: 'motivation',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'resource_oriented_motivation',
      label: 'Resource-Oriented Motivation',
      dimension: HumanDimensionId.motivation,
      description: 'Motivation shaped by resource and stability signals.',
      patternFamilyId: 'motivation_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'motivation_resource',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_RESOURCE_ORIENTATION',
        requiredDimensionKey: 'motivation',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'adaptive_creator',
      label: 'Adaptive Creator',
      dimension: HumanDimensionId.motivation,
      description: 'Motivation through adaptive growth and creation signals.',
      patternFamilyId: 'motivation_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'motivation_adaptive_creator',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        sourceHumanPatternKey: 'adaptive_creator',
        requiredMirrorKey: 'MIRROR_GROWTH_ORIENTATION',
        requiredFusionFindingType: 'reinforcement',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'structured_explorer',
      label: 'Structured Explorer',
      dimension: HumanDimensionId.thinking,
      description: 'Thinking pattern combining structure with exploratory signals.',
      patternFamilyId: 'thinking_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'thinking_structured_explorer',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        sourceHumanPatternKey: 'structured_explorer',
        requiredMirrorKey: 'MIRROR_BELIEF_STRUCTURE',
        requiredFusionFindingType: 'agreement',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'reflective_builder',
      label: 'Reflective Builder',
      dimension: HumanDimensionId.thinking,
      description: 'Thinking pattern integrating reflection and construction.',
      patternFamilyId: 'thinking_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'thinking_reflective_builder',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        sourceHumanPatternKey: 'reflective_builder',
        requiredMirrorKey: 'MIRROR_INNER_WORLD',
        requiredFusionFindingType: 'reinforcement',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'analytical_thinker',
      label: 'Analytical Thinker',
      dimension: HumanDimensionId.thinking,
      description: 'Thinking pattern driven by analytical processing signals.',
      patternFamilyId: 'thinking_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'thinking_analytical',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_THINKING_PATTERN',
        requiredDimensionKey: 'thinking',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'belief_architect',
      label: 'Belief Architect',
      dimension: HumanDimensionId.thinking,
      description: 'Thinking pattern organizing belief-structure signals.',
      patternFamilyId: 'thinking_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'thinking_belief_architect',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_BELIEF_STRUCTURE',
        requiredDimensionKey: 'thinking',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'emotional_depth',
      label: 'Emotional Depth',
      dimension: HumanDimensionId.emotion,
      description: 'Emotional pattern with deep inner-world signal presence.',
      patternFamilyId: 'emotional_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'emotion_depth',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_INNER_WORLD',
        requiredDimensionKey: 'emotion',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'responsive_feeler',
      label: 'Responsive Feeler',
      dimension: HumanDimensionId.emotion,
      description: 'Emotional pattern responsive to relational signal shifts.',
      patternFamilyId: 'emotional_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'emotion_responsive',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_EMOTIONAL_PATTERN',
        requiredDimensionKey: 'emotion',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'calm_regulator',
      label: 'Calm Regulator',
      dimension: HumanDimensionId.emotion,
      description: 'Emotional pattern stabilizing through inner-regulation signals.',
      patternFamilyId: 'emotional_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'emotion_calm_regulator',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        requiredDimensionKey: 'emotion',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'relationship_stabilizer',
      label: 'Relationship Stabilizer',
      dimension: HumanDimensionId.relationship,
      description: 'Relationship pattern stabilizing connection signals.',
      patternFamilyId: 'relationship_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'relationship_stabilizer',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        sourceHumanPatternKey: 'relationship_stabilizer',
        requiredMirrorKey: 'MIRROR_RELATIONAL_PATTERN',
        requiredFusionFindingType: 'agreement',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'supportive_connector',
      label: 'Supportive Connector',
      dimension: HumanDimensionId.relationship,
      description: 'Relationship pattern emphasizing supportive connection signals.',
      patternFamilyId: 'relationship_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'relationship_supportive',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_SUPPORT_PATTERN',
        requiredDimensionKey: 'relationship',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'diplomatic_binder',
      label: 'Diplomatic Binder',
      dimension: HumanDimensionId.relationship,
      description: 'Relationship pattern harmonizing divergent relational signals.',
      patternFamilyId: 'relationship_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'relationship_diplomatic',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        requiredDimensionKey: 'relationship',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'independent_decision_maker',
      label: 'Independent Decision Maker',
      dimension: HumanDimensionId.action,
      description: 'Action pattern favoring autonomous decision signals.',
      patternFamilyId: 'decision_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'action_independent_decision',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        sourceHumanPatternKey: 'independent_decision_maker',
        requiredMirrorKey: 'MIRROR_ACTION_STYLE',
        requiredFusionFindingType: 'agreement',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'structured_operator',
      label: 'Structured Operator',
      dimension: HumanDimensionId.action,
      description: 'Action pattern organized through structural execution signals.',
      patternFamilyId: 'decision_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'action_structured_operator',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_STRUCTURE_PATTERN',
        requiredDimensionKey: 'action',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'decisive_actor',
      label: 'Decisive Actor',
      dimension: HumanDimensionId.action,
      description: 'Action pattern with high decision-to-action signal velocity.',
      patternFamilyId: 'decision_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'action_decisive',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        requiredDimensionKey: 'action',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'progressive_builder',
      label: 'Progressive Builder',
      dimension: HumanDimensionId.growth,
      description: 'Growth pattern building incrementally on orientation signals.',
      patternFamilyId: 'growth_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'growth_progressive_builder',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_GROWTH_ORIENTATION',
        requiredDimensionKey: 'growth',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'transformation_seeker',
      label: 'Transformation Seeker',
      dimension: HumanDimensionId.growth,
      description: 'Growth pattern driven by transformation signal presence.',
      patternFamilyId: 'growth_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'growth_transformation',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_TRANSFORMATION_PATTERN',
        requiredDimensionKey: 'growth',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'adaptive_growth',
      label: 'Adaptive Growth',
      dimension: HumanDimensionId.growth,
      description: 'Growth pattern activated by adaptive creator foundation signals.',
      patternFamilyId: 'growth_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'growth_adaptive',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        sourceHumanPatternKey: 'adaptive_creator',
        requiredDimensionKey: 'growth',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'meaning_seeker',
      label: 'Meaning Seeker',
      dimension: HumanDimensionId.meaning,
      description: 'Meaning pattern oriented toward purpose-discovery signals.',
      patternFamilyId: 'meaning_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'meaning_seeker',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_LIFE_DIRECTION',
        requiredDimensionKey: 'meaning',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'belief_meaning',
      label: 'Belief Meaning',
      dimension: HumanDimensionId.meaning,
      description: 'Meaning pattern derived from belief-structure signals.',
      patternFamilyId: 'meaning_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'meaning_belief',
        minPatternStrength: 0.25,
        minDimensionActivation: 0.2,
        requiredMirrorKey: 'MIRROR_BELIEF_STRUCTURE',
        requiredDimensionKey: 'meaning',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'directional_meaning',
      label: 'Directional Meaning',
      dimension: HumanDimensionId.meaning,
      description: 'Meaning pattern anchored in life-direction signal coherence.',
      patternFamilyId: 'meaning_style',
      activationRule: HumanPatternActivationRule(
        ruleId: 'meaning_directional',
        minPatternStrength: 0.2,
        minDimensionActivation: 0.15,
        requiredDimensionKey: 'meaning',
      ),
    ),

    // HS4 — semantic expansion: conflict patterns (tension-sourced)
    CanonicalHumanPatternEntry(
      patternId: 'dual_nature_actor',
      label: 'Dual Nature Actor',
      dimension: HumanDimensionId.action,
      description: 'Action conflict from cross-mirror polarity divergence signals.',
      patternFamilyId: 'conflict_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'conflict_dual_nature_actor',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        sourceHumanPatternKey: 'tension_action_style_growth_edge',
        requiredMirrorKey: 'MIRROR_ACTION_STYLE',
        requiredFusionFindingType: 'tension',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'internal_conflict_thinker',
      label: 'Internal Conflict Thinker',
      dimension: HumanDimensionId.thinking,
      description: 'Thinking tension from divergent cross-mirror belief signals.',
      patternFamilyId: 'conflict_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'conflict_internal_thinker',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        requiredMirrorKey: 'MIRROR_THINKING_PATTERN',
        requiredFusionFindingType: 'tension',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'identity_dual_signal',
      label: 'Identity Dual Signal',
      dimension: HumanDimensionId.identity,
      description: 'Identity tension from conflicting self-presentation signals.',
      patternFamilyId: 'conflict_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'conflict_identity_dual',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        requiredMirrorKey: 'MIRROR_SELF_IDENTITY',
        requiredFusionFindingType: 'tension',
      ),
    ),

    // HS4 — semantic expansion: growth edge patterns (tension/reinforcement-sourced)
    CanonicalHumanPatternEntry(
      patternId: 'growth_edge_builder',
      label: 'Growth Edge Builder',
      dimension: HumanDimensionId.growth,
      description: 'Growth edge activated by cross-mirror action tension signals.',
      patternFamilyId: 'growth_edge_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'growth_edge_action_tension',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        sourceHumanPatternKey: 'tension_action_style_growth_edge',
        requiredDimensionKey: 'growth',
        requiredFusionFindingType: 'tension',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'reinforced_strength',
      label: 'Reinforced Strength',
      dimension: HumanDimensionId.motivation,
      description: 'Motivation reinforced by cross-mirror signal amplification.',
      patternFamilyId: 'growth_edge_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'growth_edge_reinforced_strength',
        minPatternStrength: 0.20,
        minDimensionActivation: 0.10,
        requiredFusionFindingType: 'reinforcement',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'stable_orientation',
      label: 'Stable Orientation',
      dimension: HumanDimensionId.meaning,
      description: 'Meaning orientation stabilized by cross-mirror reinforcement.',
      patternFamilyId: 'growth_edge_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'growth_edge_stable_orientation',
        minPatternStrength: 0.20,
        minDimensionActivation: 0.10,
        requiredMirrorKey: 'MIRROR_LIFE_DIRECTION',
        requiredFusionFindingType: 'reinforcement',
      ),
    ),

    // HS4 — semantic expansion: blind spot patterns
    CanonicalHumanPatternEntry(
      patternId: 'relational_hidden_potential',
      label: 'Relational Hidden Potential',
      dimension: HumanDimensionId.relationship,
      description: 'Relationship blind spot from single-source dimension coverage.',
      patternFamilyId: 'blind_spot_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'blind_spot_relational_hidden',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        sourceHumanPatternKey: 'blind_spot_relational_pattern_hidden_potential',
        requiredMirrorKey: 'MIRROR_RELATIONAL_PATTERN',
        requiredFusionFindingType: 'blind_spot',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'ignored_emotional_dimension',
      label: 'Ignored Emotional Dimension',
      dimension: HumanDimensionId.emotion,
      description: 'Emotional blind spot from asymmetric mirror coverage.',
      patternFamilyId: 'blind_spot_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'blind_spot_emotional_ignored',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        requiredMirrorKey: 'MIRROR_EMOTIONAL_PATTERN',
        requiredFusionFindingType: 'blind_spot',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'asymmetric_identity_development',
      label: 'Asymmetric Identity Development',
      dimension: HumanDimensionId.identity,
      description: 'Identity blind spot from uneven cross-mirror visibility.',
      patternFamilyId: 'blind_spot_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'blind_spot_identity_asymmetric',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        requiredMirrorKey: 'MIRROR_PUBLIC_VISIBILITY',
        requiredFusionFindingType: 'blind_spot',
      ),
    ),

    // HPC4 — runtime theme coverage expansion
    CanonicalHumanPatternEntry(
      patternId: 'constructive_builder',
      label: 'Constructive Builder',
      dimension: HumanDimensionId.action,
      description: 'Action pattern from builder theme in fusion evidence.',
      patternFamilyId: 'theme_coverage_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'theme_constructive_builder',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.12,
        sourceHumanPatternKey: 'theme_builder_constructive_force',
        requiredDimensionKey: 'action',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'accountable_operator',
      label: 'Accountable Operator',
      dimension: HumanDimensionId.action,
      description: 'Action pattern from responsible theme in fusion evidence.',
      patternFamilyId: 'theme_coverage_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'theme_accountable_operator',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.12,
        sourceHumanPatternKey: 'theme_responsible_accountable_operator',
        requiredDimensionKey: 'action',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'guiding_teacher',
      label: 'Guiding Teacher',
      dimension: HumanDimensionId.growth,
      description: 'Growth pattern from teacher theme in fusion evidence.',
      patternFamilyId: 'theme_coverage_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'theme_guiding_teacher',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        sourceHumanPatternKey: 'theme_teacher_guiding_influence',
        requiredDimensionKey: 'growth',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'structured_builder_thinker',
      label: 'Structured Builder Thinker',
      dimension: HumanDimensionId.thinking,
      description: 'Thinking pattern from builder theme cross-dimension reach.',
      patternFamilyId: 'theme_coverage_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'theme_structured_builder_thinker',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.12,
        sourceHumanPatternKey: 'theme_builder_constructive_force',
        requiredDimensionKey: 'thinking',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'purpose_guide',
      label: 'Purpose Guide',
      dimension: HumanDimensionId.meaning,
      description: 'Meaning pattern from teacher theme guiding influence.',
      patternFamilyId: 'theme_coverage_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'theme_purpose_guide',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        sourceHumanPatternKey: 'theme_teacher_guiding_influence',
        requiredDimensionKey: 'meaning',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'stable_accountability',
      label: 'Stable Accountability',
      dimension: HumanDimensionId.motivation,
      description: 'Motivation pattern from responsible theme stable orientation.',
      patternFamilyId: 'theme_coverage_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'theme_stable_accountability',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        sourceHumanPatternKey: 'theme_responsible_accountable_operator',
        requiredDimensionKey: 'motivation',
      ),
    ),
    CanonicalHumanPatternEntry(
      patternId: 'growth_edge_from_tension',
      label: 'Growth Edge From Tension',
      dimension: HumanDimensionId.growth,
      description: 'Growth edge unlocked when growth dimension rises from theme coverage.',
      patternFamilyId: 'growth_edge_pattern',
      activationRule: HumanPatternActivationRule(
        ruleId: 'growth_edge_from_theme_tension',
        minPatternStrength: 0.35,
        minDimensionActivation: 0.10,
        sourceHumanPatternKey: 'tension_action_style_growth_edge',
        requiredDimensionKey: 'growth',
        requiredFusionFindingType: 'tension',
      ),
    ),
  ];
}

/// Known conflicting registry pattern pairs (HP7).
abstract final class HumanPatternConflictCatalog {
  static const pairs = <(String, String)>[
    ('structured_explorer', 'adaptive_growth'),
    ('structured_operator', 'adaptive_creator'),
    ('calm_regulator', 'responsive_feeler'),
  ];
}
