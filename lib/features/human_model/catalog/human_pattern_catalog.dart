import '../domain/human_dimension.dart';

/// Structural human pattern definition — labels only, no narrative (HM3).
class HumanPatternDefinition {
  const HumanPatternDefinition({
    required this.patternKey,
    required this.label,
    required this.primaryDimension,
    required this.secondaryDimensions,
    required this.fusionFindingType,
    required this.mirrorKey,
    this.meaningCategoryKey,
  });

  final String patternKey;
  final String label;
  final HumanDimensionId primaryDimension;
  final List<HumanDimensionId> secondaryDimensions;
  final String fusionFindingType;
  final String mirrorKey;
  final String? meaningCategoryKey;
}

/// Frozen v1 foundation pattern catalog (pre-semantic expansion).
abstract final class HumanPatternCatalog {
  static const foundationPatterns = <HumanPatternDefinition>[
    HumanPatternDefinition(
      patternKey: 'independent_decision_maker',
      label: 'Independent Decision Maker',
      primaryDimension: HumanDimensionId.action,
      secondaryDimensions: [HumanDimensionId.identity],
      fusionFindingType: 'agreement',
      mirrorKey: 'MIRROR_ACTION_STYLE',
      meaningCategoryKey: 'shared_signal',
    ),
    HumanPatternDefinition(
      patternKey: 'structured_explorer',
      label: 'Structured Explorer',
      primaryDimension: HumanDimensionId.thinking,
      secondaryDimensions: [HumanDimensionId.growth],
      fusionFindingType: 'agreement',
      mirrorKey: 'MIRROR_BELIEF_STRUCTURE',
      meaningCategoryKey: 'shared_signal',
    ),
    HumanPatternDefinition(
      patternKey: 'reflective_builder',
      label: 'Reflective Builder',
      primaryDimension: HumanDimensionId.thinking,
      secondaryDimensions: [HumanDimensionId.emotion],
      fusionFindingType: 'reinforcement',
      mirrorKey: 'MIRROR_INNER_WORLD',
      meaningCategoryKey: 'core_strength',
    ),
    HumanPatternDefinition(
      patternKey: 'relationship_stabilizer',
      label: 'Relationship Stabilizer',
      primaryDimension: HumanDimensionId.relationship,
      secondaryDimensions: [HumanDimensionId.emotion],
      fusionFindingType: 'agreement',
      mirrorKey: 'MIRROR_RELATIONAL_PATTERN',
      meaningCategoryKey: 'shared_signal',
    ),
    HumanPatternDefinition(
      patternKey: 'adaptive_creator',
      label: 'Adaptive Creator',
      primaryDimension: HumanDimensionId.growth,
      secondaryDimensions: [HumanDimensionId.action, HumanDimensionId.motivation],
      fusionFindingType: 'reinforcement',
      mirrorKey: 'MIRROR_GROWTH_ORIENTATION',
      meaningCategoryKey: 'core_strength',
    ),
  ];

  @Deprecated('Use HumanSemanticPatternCatalog.allPatterns')
  static List<HumanPatternDefinition> get patterns => foundationPatterns;

  static HumanPatternDefinition? byMirrorKeyAndType({
    required String mirrorKey,
    required String fusionFindingType,
  }) {
    for (final pattern in foundationPatterns) {
      if (pattern.mirrorKey == mirrorKey &&
          pattern.fusionFindingType == fusionFindingType) {
        return pattern;
      }
    }
    return null;
  }
}
