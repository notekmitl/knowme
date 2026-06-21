import '../domain/human_dimension.dart';
import 'human_meaning_category.dart';
import 'human_semantic_source_type.dart';

/// HS2 — maps fusion finding type + mirror context to human meaning category.
class FusionMeaningMapping {
  const FusionMeaningMapping({
    required this.sourceType,
    required this.meaningCategory,
    required this.patternKey,
    required this.label,
    required this.primaryDimension,
  });

  final HumanSemanticSourceType sourceType;
  final HumanMeaningCategory meaningCategory;
  final String patternKey;
  final String label;
  final HumanDimensionId primaryDimension;
}

abstract final class FusionFindingToMeaningMapper {
  static FusionMeaningMapping resolve({
    required HumanSemanticSourceType sourceType,
    required String mirrorKey,
    required String mirrorDimension,
  }) {
    final dimension =
        _mirrorKeyToDimension(mirrorKey) ??
        _mirrorDimensionToHumanDimension(mirrorDimension);
    final meaningCategory = _primaryMeaning(sourceType, dimension);
    final slug = _mirrorSlug(mirrorKey);

    return FusionMeaningMapping(
      sourceType: sourceType,
      meaningCategory: meaningCategory,
      patternKey: '${sourceType.key}_${slug}_${meaningCategory.key}',
      label: '${meaningCategory.label} (${_mirrorLabel(mirrorKey)})',
      primaryDimension: dimension ?? HumanDimensionId.identity,
    );
  }

  static HumanMeaningCategory _primaryMeaning(
    HumanSemanticSourceType sourceType,
    HumanDimensionId? dimension,
  ) {
    final options = HumanMeaningCategory.forSourceType(sourceType);
    if (options.isEmpty) return HumanMeaningCategory.sharedSignal;

    return switch (sourceType) {
      HumanSemanticSourceType.agreement => HumanMeaningCategory.sharedSignal,
      HumanSemanticSourceType.tension =>
        dimension == HumanDimensionId.growth ||
                dimension == HumanDimensionId.action
            ? HumanMeaningCategory.growthEdge
            : HumanMeaningCategory.internalConflict,
      HumanSemanticSourceType.reinforcement =>
        HumanMeaningCategory.coreStrength,
      HumanSemanticSourceType.blindSpot =>
        HumanMeaningCategory.hiddenPotential,
    };
  }

  static HumanDimensionId? _mirrorKeyToDimension(String mirrorKey) {
    return switch (mirrorKey) {
      'MIRROR_SELF_IDENTITY' ||
      'MIRROR_SELF_EXPRESSION' ||
      'MIRROR_PUBLIC_VISIBILITY' =>
        HumanDimensionId.identity,
      'MIRROR_RESOURCE_ORIENTATION' => HumanDimensionId.motivation,
      'MIRROR_BELIEF_STRUCTURE' ||
      'MIRROR_THINKING_PATTERN' =>
        HumanDimensionId.thinking,
      'MIRROR_INNER_WORLD' ||
      'MIRROR_EMOTIONAL_PATTERN' =>
        HumanDimensionId.emotion,
      'MIRROR_RELATIONAL_PATTERN' ||
      'MIRROR_SUPPORT_PATTERN' =>
        HumanDimensionId.relationship,
      'MIRROR_ACTION_STYLE' ||
      'MIRROR_STRUCTURE_PATTERN' =>
        HumanDimensionId.action,
      'MIRROR_GROWTH_ORIENTATION' ||
      'MIRROR_TRANSFORMATION_PATTERN' =>
        HumanDimensionId.growth,
      'MIRROR_LIFE_DIRECTION' => HumanDimensionId.meaning,
      _ => null,
    };
  }

  static HumanDimensionId? _mirrorDimensionToHumanDimension(
    String mirrorDimension,
  ) {
    final normalized = mirrorDimension.trim().toLowerCase();
    return switch (normalized) {
      'identity' || 'expression' || 'visibility' => HumanDimensionId.identity,
      'resources' => HumanDimensionId.motivation,
      'beliefs' => HumanDimensionId.thinking,
      'inner_world' => HumanDimensionId.emotion,
      'relationships' => HumanDimensionId.relationship,
      'action' => HumanDimensionId.action,
      'growth' || 'transformation' => HumanDimensionId.growth,
      'life_direction' => HumanDimensionId.meaning,
      _ => null,
    };
  }

  static String _mirrorSlug(String mirrorKey) {
    return mirrorKey
        .replaceFirst('MIRROR_', '')
        .toLowerCase();
  }

  static String _mirrorLabel(String mirrorKey) {
    return mirrorKey.replaceFirst('MIRROR_', '').replaceAll('_', ' ');
  }
}
