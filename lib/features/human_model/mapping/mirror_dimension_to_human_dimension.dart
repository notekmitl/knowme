import '../domain/human_dimension.dart';

/// Maps mirror-platform dimension ids to canonical human dimensions.
///
/// Uses structural mirror vocabulary only — no MBTI or astrology references.
abstract final class MirrorDimensionToHumanDimension {
  static HumanDimensionId? map(String mirrorDimension) {
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
      _ => _fallback(normalized),
    };
  }

  static HumanDimensionId? _fallback(String normalized) {
    if (normalized.contains('meaning') || normalized.contains('belief')) {
      return HumanDimensionId.meaning;
    }
    if (normalized.contains('relation')) {
      return HumanDimensionId.relationship;
    }
    if (normalized.contains('action')) {
      return HumanDimensionId.action;
    }
    if (normalized.contains('growth')) {
      return HumanDimensionId.growth;
    }
    return null;
  }
}
