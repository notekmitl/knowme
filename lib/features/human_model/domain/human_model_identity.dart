/// Deterministic identity block for human model snapshot.
class HumanModelIdentity {
  const HumanModelIdentity({
    required this.snapshotId,
    required this.humanModelId,
    required this.sourceGlobalFusionSnapshotId,
    required this.snapshotVersion,
  });

  final String snapshotId;
  final String humanModelId;
  final String sourceGlobalFusionSnapshotId;
  final String snapshotVersion;

  Map<String, dynamic> toMap() {
    return {
      'snapshotId': snapshotId,
      'humanModelId': humanModelId,
      'sourceGlobalFusionSnapshotId': sourceGlobalFusionSnapshotId,
      'snapshotVersion': snapshotVersion,
    };
  }

  factory HumanModelIdentity.fromMap(Map<String, dynamic> map) {
    return HumanModelIdentity(
      snapshotId: _requiredString(map['snapshotId']),
      humanModelId: _requiredString(map['humanModelId']),
      sourceGlobalFusionSnapshotId:
          _requiredString(map['sourceGlobalFusionSnapshotId']),
      snapshotVersion: _requiredString(map['snapshotVersion']),
    );
  }
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}
