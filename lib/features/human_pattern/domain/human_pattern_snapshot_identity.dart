class HumanPatternSnapshotIdentity {
  const HumanPatternSnapshotIdentity({
    required this.snapshotId,
    required this.humanPatternSystemId,
    required this.sourceHumanModelSnapshotId,
    required this.snapshotVersion,
    required this.registryVersion,
  });

  final String snapshotId;
  final String humanPatternSystemId;
  final String sourceHumanModelSnapshotId;
  final String snapshotVersion;
  final String registryVersion;

  Map<String, dynamic> toMap() {
    return {
      'snapshotId': snapshotId,
      'humanPatternSystemId': humanPatternSystemId,
      'sourceHumanModelSnapshotId': sourceHumanModelSnapshotId,
      'snapshotVersion': snapshotVersion,
      'registryVersion': registryVersion,
    };
  }

  factory HumanPatternSnapshotIdentity.fromMap(Map<String, dynamic> map) {
    return HumanPatternSnapshotIdentity(
      snapshotId: _requiredString(map['snapshotId']),
      humanPatternSystemId: _requiredString(map['humanPatternSystemId']),
      sourceHumanModelSnapshotId:
          _requiredString(map['sourceHumanModelSnapshotId']),
      snapshotVersion: _requiredString(map['snapshotVersion']),
      registryVersion: _requiredString(map['registryVersion']),
    );
  }
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}
