/// Traceable lineage for human pattern snapshot.
class PatternLineage {
  const PatternLineage({
    required this.sourceHumanModelSnapshotId,
    required this.sourceHumanModelStructuralHash,
    required this.sourceGlobalFusionSnapshotId,
    required this.registryVersion,
    required this.activationByPatternId,
  });

  final String sourceHumanModelSnapshotId;
  final String sourceHumanModelStructuralHash;
  final String sourceGlobalFusionSnapshotId;
  final String registryVersion;
  final Map<String, String> activationByPatternId;

  Map<String, dynamic> toMap() {
    return {
      'sourceHumanModelSnapshotId': sourceHumanModelSnapshotId,
      'sourceHumanModelStructuralHash': sourceHumanModelStructuralHash,
      'sourceGlobalFusionSnapshotId': sourceGlobalFusionSnapshotId,
      'registryVersion': registryVersion,
      'activationByPatternId': activationByPatternId,
    };
  }

  factory PatternLineage.fromMap(Map<String, dynamic> map) {
    return PatternLineage(
      sourceHumanModelSnapshotId:
          _requiredString(map['sourceHumanModelSnapshotId']),
      sourceHumanModelStructuralHash:
          _requiredString(map['sourceHumanModelStructuralHash']),
      sourceGlobalFusionSnapshotId:
          _requiredString(map['sourceGlobalFusionSnapshotId']),
      registryVersion: _requiredString(map['registryVersion']),
      activationByPatternId: _stringMap(map['activationByPatternId']),
    );
  }
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
