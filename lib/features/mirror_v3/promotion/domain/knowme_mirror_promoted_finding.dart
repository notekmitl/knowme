/// MV2 promoted mirror finding — agreement-equivalent for GF2 only (GF1 ignores).
class KnowMeMirrorPromotedFinding {
  const KnowMeMirrorPromotedFinding({
    required this.id,
    required this.promotionRuleId,
    required this.findingType,
    required this.patternType,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.themeIds,
    required this.supportingSystems,
    required this.supportingLensKeys,
    required this.confidence,
    required this.sourceSignalIds,
    required this.sourceEvidenceRowIds,
    required this.riskLevel,
  });

  final String id;
  final String promotionRuleId;
  final String findingType;
  final String patternType;
  final String mirrorKey;
  final String mirrorDimension;
  final List<String> themeIds;
  final List<String> supportingSystems;
  final List<String> supportingLensKeys;
  final double confidence;
  final List<String> sourceSignalIds;
  final List<String> sourceEvidenceRowIds;
  final String riskLevel;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'promotionRuleId': promotionRuleId,
      'findingType': findingType,
      'patternType': patternType,
      'mirrorKey': mirrorKey,
      'mirrorDimension': mirrorDimension,
      'themeIds': themeIds,
      'supportingSystems': supportingSystems,
      'supportingLensKeys': supportingLensKeys,
      'confidence': confidence,
      'sourceSignalIds': sourceSignalIds,
      'sourceEvidenceRowIds': sourceEvidenceRowIds,
      'riskLevel': riskLevel,
    };
  }

  factory KnowMeMirrorPromotedFinding.fromMap(Map<String, dynamic> map) {
    return KnowMeMirrorPromotedFinding(
      id: _requiredString(map['id']),
      promotionRuleId: _requiredString(map['promotionRuleId']),
      findingType: _requiredString(map['findingType']),
      patternType: _requiredString(map['patternType']),
      mirrorKey: _requiredString(map['mirrorKey']),
      mirrorDimension: _requiredString(map['mirrorDimension']),
      themeIds: _stringList(map['themeIds']),
      supportingSystems: _stringList(map['supportingSystems']),
      supportingLensKeys: _stringList(map['supportingLensKeys']),
      confidence: _requiredDouble(map['confidence']),
      sourceSignalIds: _stringList(map['sourceSignalIds']),
      sourceEvidenceRowIds: _stringList(map['sourceEvidenceRowIds']),
      riskLevel: _requiredString(map['riskLevel']),
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
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
