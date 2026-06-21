/// Traceable lineage from global fusion back to source mirror snapshots.
class GlobalFusionLineage {
  const GlobalFusionLineage({
    required this.sourceMirrorSnapshotIds,
    required this.mirrorRoleBySnapshotId,
    required this.sourceMirrorStructuralHashes,
    required this.foundationVersion,
  });

  final List<String> sourceMirrorSnapshotIds;
  final Map<String, String> mirrorRoleBySnapshotId;
  final Map<String, String> sourceMirrorStructuralHashes;
  final String foundationVersion;

  Map<String, dynamic> toMap() {
    return {
      'sourceMirrorSnapshotIds': sourceMirrorSnapshotIds,
      'mirrorRoleBySnapshotId': mirrorRoleBySnapshotId,
      'sourceMirrorStructuralHashes': sourceMirrorStructuralHashes,
      'foundationVersion': foundationVersion,
    };
  }

  factory GlobalFusionLineage.fromMap(Map<String, dynamic> map) {
    return GlobalFusionLineage(
      sourceMirrorSnapshotIds: _stringList(map['sourceMirrorSnapshotIds']),
      mirrorRoleBySnapshotId: _stringMap(map['mirrorRoleBySnapshotId']),
      sourceMirrorStructuralHashes:
          _stringMap(map['sourceMirrorStructuralHashes']),
      foundationVersion: _requiredString(map['foundationVersion']),
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
}

Map<String, String> _stringMap(dynamic raw) {
  if (raw is! Map) return const {};
  final result = <String, String>{};
  for (final entry in raw.entries) {
    if (entry.key is String && entry.value is String) {
      result[entry.key as String] = entry.value as String;
    }
  }
  return Map<String, String>.unmodifiable(result);
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}
