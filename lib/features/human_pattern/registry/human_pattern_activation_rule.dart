/// Structural activation rule — no narrative prose.
class HumanPatternActivationRule {
  const HumanPatternActivationRule({
    required this.ruleId,
    required this.minPatternStrength,
    required this.minDimensionActivation,
    this.sourceHumanPatternKey,
    this.requiredMirrorKey,
    this.requiredDimensionKey,
    this.requiredFusionFindingType,
  });

  final String ruleId;
  final double minPatternStrength;
  final double minDimensionActivation;
  final String? sourceHumanPatternKey;
  final String? requiredMirrorKey;
  final String? requiredDimensionKey;
  final String? requiredFusionFindingType;

  Map<String, dynamic> toMap() {
    return {
      'ruleId': ruleId,
      'minPatternStrength': minPatternStrength,
      'minDimensionActivation': minDimensionActivation,
      'sourceHumanPatternKey': sourceHumanPatternKey,
      'requiredMirrorKey': requiredMirrorKey,
      'requiredDimensionKey': requiredDimensionKey,
      'requiredFusionFindingType': requiredFusionFindingType,
    };
  }

  factory HumanPatternActivationRule.fromMap(Map<String, dynamic> map) {
    return HumanPatternActivationRule(
      ruleId: _requiredString(map['ruleId']),
      minPatternStrength: _requiredDouble(map['minPatternStrength']),
      minDimensionActivation: _requiredDouble(map['minDimensionActivation']),
      sourceHumanPatternKey: _optionalString(map['sourceHumanPatternKey']),
      requiredMirrorKey: _optionalString(map['requiredMirrorKey']),
      requiredDimensionKey: _optionalString(map['requiredDimensionKey']),
      requiredFusionFindingType:
          _optionalString(map['requiredFusionFindingType']),
    );
  }
}

String? _optionalString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) return null;
  return raw.trim();
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}

double _requiredDouble(dynamic raw) {
  if (raw is! num) throw FormatException('Invalid double: $raw');
  return raw.toDouble();
}
