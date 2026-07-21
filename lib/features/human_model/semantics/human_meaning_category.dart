import 'human_semantic_source_type.dart';

/// HS2 — structural human meaning categories derived from fusion finding types.
enum HumanMeaningCategory {
  sharedSignal('shared_signal', 'Shared Signal'),
  coreAlignment('core_alignment', 'Core Alignment'),

  internalConflict('internal_conflict', 'Internal Conflict'),
  growthEdge('growth_edge', 'Growth Edge'),
  dualNature('dual_nature', 'Dual Nature'),

  coreStrength('core_strength', 'Core Strength'),
  naturalOrientation('natural_orientation', 'Natural Orientation'),
  stablePattern('stable_pattern', 'Stable Pattern'),

  hiddenPotential('hidden_potential', 'Hidden Potential'),
  ignoredDimension('ignored_dimension', 'Ignored Dimension'),
  asymmetricDevelopment('asymmetric_development', 'Asymmetric Development');

  const HumanMeaningCategory(this.key, this.label);

  final String key;
  final String label;

  static List<HumanMeaningCategory> forSourceType(
    HumanSemanticSourceType sourceType,
  ) {
    return switch (sourceType) {
      HumanSemanticSourceType.agreement => [
          sharedSignal,
          coreAlignment,
        ],
      HumanSemanticSourceType.tension => [
          internalConflict,
          growthEdge,
          dualNature,
        ],
      HumanSemanticSourceType.reinforcement => [
          coreStrength,
          naturalOrientation,
          stablePattern,
        ],
      HumanSemanticSourceType.blindSpot => [
          hiddenPotential,
          ignoredDimension,
          asymmetricDevelopment,
        ],
    };
  }
}
