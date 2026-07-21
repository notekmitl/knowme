/// Deterministic identity block for a persisted global fusion snapshot.
class GlobalFusionIdentity {
  const GlobalFusionIdentity({
    required this.snapshotId,
    required this.globalFusionId,
    required this.sourceMirrorSnapshotIds,
    required this.snapshotVersion,
  });

  final String snapshotId;
  final String globalFusionId;
  final List<String> sourceMirrorSnapshotIds;
  final String snapshotVersion;

  Map<String, dynamic> toMap() {
    return {
      'snapshotId': snapshotId,
      'globalFusionId': globalFusionId,
      'sourceMirrorSnapshotIds': sourceMirrorSnapshotIds,
      'snapshotVersion': snapshotVersion,
    };
  }

  factory GlobalFusionIdentity.fromMap(Map<String, dynamic> map) {
    return GlobalFusionIdentity(
      snapshotId: _requiredString(map['snapshotId']),
      globalFusionId: _requiredString(map['globalFusionId']),
      sourceMirrorSnapshotIds: _stringList(map['sourceMirrorSnapshotIds']),
      snapshotVersion: _requiredString(map['snapshotVersion']),
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
