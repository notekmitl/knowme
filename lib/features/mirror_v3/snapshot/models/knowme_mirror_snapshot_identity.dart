/// Immutable snapshot identity block (MV3.2).
class KnowMeMirrorSnapshotIdentity {
  const KnowMeMirrorSnapshotIdentity({
    required this.snapshotId,
    required this.mirrorId,
    required this.mirrorBundleId,
    required this.mirrorScopeId,
    required this.mirrorObjectIds,
    required this.snapshotVersion,
  });

  final String snapshotId;
  final String mirrorId;
  final String mirrorBundleId;
  final String mirrorScopeId;
  final List<String> mirrorObjectIds;
  final String snapshotVersion;

  Map<String, dynamic> toMap() {
    return {
      'snapshotId': snapshotId,
      'mirrorId': mirrorId,
      'mirrorBundleId': mirrorBundleId,
      'mirrorScopeId': mirrorScopeId,
      'mirrorObjectIds': mirrorObjectIds,
      'snapshotVersion': snapshotVersion,
    };
  }

  factory KnowMeMirrorSnapshotIdentity.fromMap(Map<String, dynamic> map) {
    return KnowMeMirrorSnapshotIdentity(
      snapshotId: _requiredString(map['snapshotId']),
      mirrorId: _requiredString(map['mirrorId']),
      mirrorBundleId: _requiredString(map['mirrorBundleId']),
      mirrorScopeId: _requiredString(map['mirrorScopeId']),
      mirrorObjectIds: _stringList(map['mirrorObjectIds']),
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
