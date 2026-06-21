/// Traceable lineage back to global fusion and mirror layers (HM6).
class HumanLineage {
  const HumanLineage({
    required this.sourceGlobalFusionSnapshotId,
    required this.sourceGlobalFusionStructuralHash,
    required this.fusionFindingByPatternId,
    required this.foundationVersion,
  });

  final String sourceGlobalFusionSnapshotId;
  final String sourceGlobalFusionStructuralHash;
  final Map<String, String> fusionFindingByPatternId;
  final String foundationVersion;

  Map<String, dynamic> toMap() {
    return {
      'sourceGlobalFusionSnapshotId': sourceGlobalFusionSnapshotId,
      'sourceGlobalFusionStructuralHash': sourceGlobalFusionStructuralHash,
      'fusionFindingByPatternId': fusionFindingByPatternId,
      'foundationVersion': foundationVersion,
    };
  }

  factory HumanLineage.fromMap(Map<String, dynamic> map) {
    return HumanLineage(
      sourceGlobalFusionSnapshotId:
          _requiredString(map['sourceGlobalFusionSnapshotId']),
      sourceGlobalFusionStructuralHash:
          _requiredString(map['sourceGlobalFusionStructuralHash']),
      fusionFindingByPatternId: _stringMap(map['fusionFindingByPatternId']),
      foundationVersion: _requiredString(map['foundationVersion']),
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
