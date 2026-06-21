/// Evidence row preserved in snapshot for explainability.
class KnowMeMirrorSnapshotEvidenceRow {
  const KnowMeMirrorSnapshotEvidenceRow({
    required this.mirrorObjectId,
    required this.mirrorKey,
    required this.systemId,
    required this.sourceType,
    required this.sourceThemeId,
    required this.sourceSnapshotId,
    required this.ruleId,
    required this.weight,
    required this.themeIds,
    required this.interpretationIds,
    required this.signalIds,
    required this.meaningIds,
  });

  final String mirrorObjectId;
  final String mirrorKey;
  final String systemId;
  final String sourceType;
  final String sourceThemeId;
  final String sourceSnapshotId;
  final String ruleId;
  final double weight;
  final List<String> themeIds;
  final List<String> interpretationIds;
  final List<String> signalIds;
  final List<String> meaningIds;

  Map<String, dynamic> toMap() {
    return {
      'mirrorObjectId': mirrorObjectId,
      'mirrorKey': mirrorKey,
      'systemId': systemId,
      'sourceType': sourceType,
      'sourceThemeId': sourceThemeId,
      'sourceSnapshotId': sourceSnapshotId,
      'ruleId': ruleId,
      'weight': weight,
      'themeIds': themeIds,
      'interpretationIds': interpretationIds,
      'signalIds': signalIds,
      'meaningIds': meaningIds,
    };
  }

  factory KnowMeMirrorSnapshotEvidenceRow.fromMap(Map<String, dynamic> map) {
    final weight = map['weight'];
    if (weight is! num) throw FormatException('Invalid weight: $weight');

    return KnowMeMirrorSnapshotEvidenceRow(
      mirrorObjectId: _requiredString(map['mirrorObjectId']),
      mirrorKey: _requiredString(map['mirrorKey']),
      systemId: _requiredString(map['systemId']),
      sourceType: _requiredString(map['sourceType']),
      sourceThemeId: _requiredString(map['sourceThemeId']),
      sourceSnapshotId: _requiredString(map['sourceSnapshotId']),
      ruleId: _requiredString(map['ruleId']),
      weight: weight.toDouble(),
      themeIds: _stringList(map['themeIds']),
      interpretationIds: _stringList(map['interpretationIds']),
      signalIds: _stringList(map['signalIds']),
      meaningIds: _stringList(map['meaningIds']),
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
