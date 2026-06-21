/// Closed MV2 promotion registry — exactly one rule for V2 launch.
abstract final class MirrorPromotionRegistry {
  static const singleSystemEvidencePromotion = MirrorPromotionRuleDefinition(
    ruleId: 'single_system_evidence_promotion',
    targetMirrorKeys: ['MIRROR_STRUCTURE_PATTERN'],
    minConfidence: 0.55,
    maxPromotedConfidence: 0.75,
    enabled: true,
  );

  static const v1Rules = [singleSystemEvidencePromotion];
}

class MirrorPromotionRuleDefinition {
  const MirrorPromotionRuleDefinition({
    required this.ruleId,
    required this.targetMirrorKeys,
    required this.minConfidence,
    required this.maxPromotedConfidence,
    required this.enabled,
  });

  final String ruleId;
  final List<String> targetMirrorKeys;
  final double minConfidence;
  final double maxPromotedConfidence;
  final bool enabled;
}
