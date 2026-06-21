/// Full lineage evidence row for human patterns (HM6).
class HumanEvidence {
  const HumanEvidence({
    required this.humanPatternId,
    required this.fusionFindingId,
    required this.mirrorFindingId,
    required this.mirrorSnapshotId,
    required this.mirrorRoleId,
    required this.sourceThemeId,
    required this.mirrorKey,
    required this.systemId,
    required this.sourceSnapshotId,
    required this.themeIds,
    required this.signalIds,
    required this.weight,
  });

  final String humanPatternId;
  final String fusionFindingId;
  final String mirrorFindingId;
  final String mirrorSnapshotId;
  final String mirrorRoleId;
  final String sourceThemeId;
  final String mirrorKey;
  final String systemId;
  final String sourceSnapshotId;
  final List<String> themeIds;
  final List<String> signalIds;
  final double weight;

  Map<String, dynamic> toMap() {
    return {
      'humanPatternId': humanPatternId,
      'fusionFindingId': fusionFindingId,
      'mirrorFindingId': mirrorFindingId,
      'mirrorSnapshotId': mirrorSnapshotId,
      'mirrorRoleId': mirrorRoleId,
      'sourceThemeId': sourceThemeId,
      'mirrorKey': mirrorKey,
      'systemId': systemId,
      'sourceSnapshotId': sourceSnapshotId,
      'themeIds': themeIds,
      'signalIds': signalIds,
      'weight': weight,
    };
  }

  factory HumanEvidence.fromMap(Map<String, dynamic> map) {
    return HumanEvidence(
      humanPatternId: _requiredString(map['humanPatternId']),
      fusionFindingId: _requiredString(map['fusionFindingId']),
      mirrorFindingId: _requiredString(map['mirrorFindingId']),
      mirrorSnapshotId: _requiredString(map['mirrorSnapshotId']),
      mirrorRoleId: _requiredString(map['mirrorRoleId']),
      sourceThemeId: _requiredString(map['sourceThemeId']),
      mirrorKey: _requiredString(map['mirrorKey']),
      systemId: _requiredString(map['systemId']),
      sourceSnapshotId: _requiredString(map['sourceSnapshotId']),
      themeIds: _stringList(map['themeIds']),
      signalIds: _stringList(map['signalIds']),
      weight: _requiredDouble(map['weight']),
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
