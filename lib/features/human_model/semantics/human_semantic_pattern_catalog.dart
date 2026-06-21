import '../catalog/human_pattern_catalog.dart';
import '../domain/human_dimension.dart';
import 'fusion_finding_to_meaning_mapper.dart';
import 'human_semantic_source_type.dart';

/// HS2/HS3 — semantic pattern catalog covering all mirror keys × finding types.
abstract final class HumanSemanticPatternCatalog {
  static const _mirrorKeys = [
    'MIRROR_SELF_IDENTITY',
    'MIRROR_SELF_EXPRESSION',
    'MIRROR_RELATIONAL_PATTERN',
    'MIRROR_RESOURCE_ORIENTATION',
    'MIRROR_ACTION_STYLE',
    'MIRROR_GROWTH_ORIENTATION',
    'MIRROR_PUBLIC_VISIBILITY',
    'MIRROR_TRANSFORMATION_PATTERN',
    'MIRROR_BELIEF_STRUCTURE',
    'MIRROR_INNER_WORLD',
    'MIRROR_LIFE_DIRECTION',
    'MIRROR_THINKING_PATTERN',
    'MIRROR_EMOTIONAL_PATTERN',
    'MIRROR_SUPPORT_PATTERN',
    'MIRROR_STRUCTURE_PATTERN',
  ];

  static const _sourceTypes = HumanSemanticSourceType.values;

  static List<HumanPatternDefinition> get semanticPatterns {
    return _cached ??= _build();
  }

  static List<HumanPatternDefinition>? _cached;

  static List<HumanPatternDefinition> _build() {
    final patterns = <HumanPatternDefinition>[];

    for (final mirrorKey in _mirrorKeys) {
      for (final sourceType in _sourceTypes) {
        final mapping = FusionFindingToMeaningMapper.resolve(
          sourceType: sourceType,
          mirrorKey: mirrorKey,
          mirrorDimension: _defaultMirrorDimension(mirrorKey),
        );

        patterns.add(
          HumanPatternDefinition(
            patternKey: mapping.patternKey,
            label: mapping.label,
            primaryDimension: mapping.primaryDimension,
            secondaryDimensions: _secondaryDimensions(mapping.primaryDimension),
            fusionFindingType: sourceType.key,
            mirrorKey: mirrorKey,
            meaningCategoryKey: mapping.meaningCategory.key,
          ),
        );
      }
    }

    patterns.sort((a, b) => a.patternKey.compareTo(b.patternKey));
    return List.unmodifiable(patterns);
  }

  static HumanPatternDefinition? byMirrorKeyAndType({
    required String mirrorKey,
    required String fusionFindingType,
  }) {
    for (final pattern in allPatterns) {
      if (pattern.mirrorKey == mirrorKey &&
          pattern.fusionFindingType == fusionFindingType) {
        return pattern;
      }
    }
    return null;
  }

  static List<HumanPatternDefinition> get allPatterns {
    return [
      ...HumanPatternCatalog.foundationPatterns,
      ...semanticPatterns,
    ];
  }

  static String _defaultMirrorDimension(String mirrorKey) {
    return switch (mirrorKey) {
      'MIRROR_SELF_IDENTITY' ||
      'MIRROR_SELF_EXPRESSION' ||
      'MIRROR_PUBLIC_VISIBILITY' =>
        'identity',
      'MIRROR_RESOURCE_ORIENTATION' => 'resources',
      'MIRROR_BELIEF_STRUCTURE' || 'MIRROR_THINKING_PATTERN' => 'beliefs',
      'MIRROR_INNER_WORLD' || 'MIRROR_EMOTIONAL_PATTERN' => 'inner_world',
      'MIRROR_RELATIONAL_PATTERN' || 'MIRROR_SUPPORT_PATTERN' => 'relationships',
      'MIRROR_ACTION_STYLE' || 'MIRROR_STRUCTURE_PATTERN' => 'action',
      'MIRROR_GROWTH_ORIENTATION' ||
      'MIRROR_TRANSFORMATION_PATTERN' =>
        'growth',
      'MIRROR_LIFE_DIRECTION' => 'life_direction',
      _ => 'identity',
    };
  }

  static List<HumanDimensionId> _secondaryDimensions(
    HumanDimensionId primary,
  ) {
    return switch (primary) {
      HumanDimensionId.identity => [HumanDimensionId.meaning],
      HumanDimensionId.motivation => [HumanDimensionId.growth],
      HumanDimensionId.thinking => [HumanDimensionId.action],
      HumanDimensionId.emotion => [HumanDimensionId.relationship],
      HumanDimensionId.relationship => [HumanDimensionId.emotion],
      HumanDimensionId.action => [HumanDimensionId.thinking],
      HumanDimensionId.growth => [HumanDimensionId.motivation],
      HumanDimensionId.meaning => [HumanDimensionId.identity],
    };
  }
}
