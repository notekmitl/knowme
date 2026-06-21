/// Preserved evidence row linking global finding → mirror finding → theme.
class GlobalFusionEvidence {
  const GlobalFusionEvidence({
    required this.globalFindingId,
    required this.mirrorRoleId,
    required this.mirrorSnapshotId,
    required this.mirrorFindingId,
    required this.mirrorObjectId,
    required this.mirrorKey,
    required this.sourceThemeId,
    required this.systemId,
    required this.sourceSnapshotId,
    required this.themeIds,
    required this.signalIds,
    required this.weight,
  });

  final String globalFindingId;
  final String mirrorRoleId;
  final String mirrorSnapshotId;
  final String mirrorFindingId;
  final String mirrorObjectId;
  final String mirrorKey;
  final String sourceThemeId;
  final String systemId;
  final String sourceSnapshotId;
  final List<String> themeIds;
  final List<String> signalIds;
  final double weight;

  Map<String, dynamic> toMap() {
    return {
      'globalFindingId': globalFindingId,
      'mirrorRoleId': mirrorRoleId,
      'mirrorSnapshotId': mirrorSnapshotId,
      'mirrorFindingId': mirrorFindingId,
      'mirrorObjectId': mirrorObjectId,
      'mirrorKey': mirrorKey,
      'sourceThemeId': sourceThemeId,
      'systemId': systemId,
      'sourceSnapshotId': sourceSnapshotId,
      'themeIds': themeIds,
      'signalIds': signalIds,
      'weight': weight,
    };
  }

  factory GlobalFusionEvidence.fromMap(Map<String, dynamic> map) {
    return GlobalFusionEvidence(
      globalFindingId: _requiredString(map['globalFindingId']),
      mirrorRoleId: _requiredString(map['mirrorRoleId']),
      mirrorSnapshotId: _requiredString(map['mirrorSnapshotId']),
      mirrorFindingId: _requiredString(map['mirrorFindingId']),
      mirrorObjectId: _requiredString(map['mirrorObjectId']),
      mirrorKey: _requiredString(map['mirrorKey']),
      sourceThemeId: _requiredString(map['sourceThemeId']),
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
