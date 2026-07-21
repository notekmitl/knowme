/// Structural snapshot metadata — no narrative fields.
class KnowMeMirrorSnapshotMetadata {
  const KnowMeMirrorSnapshotMetadata({
    required this.mirrorCount,
    required this.findingCount,
    required this.sourceSystemCount,
    required this.sourceThemeCount,
    required this.engineVersion,
    required this.domainVersion,
  });

  final int mirrorCount;
  final int findingCount;
  final int sourceSystemCount;
  final int sourceThemeCount;
  final String engineVersion;
  final String domainVersion;

  Map<String, dynamic> toMap() {
    return {
      'mirrorCount': mirrorCount,
      'findingCount': findingCount,
      'sourceSystemCount': sourceSystemCount,
      'sourceThemeCount': sourceThemeCount,
      'engineVersion': engineVersion,
      'domainVersion': domainVersion,
    };
  }

  factory KnowMeMirrorSnapshotMetadata.fromMap(Map<String, dynamic> map) {
    return KnowMeMirrorSnapshotMetadata(
      mirrorCount: _requiredInt(map['mirrorCount']),
      findingCount: _requiredInt(map['findingCount']),
      sourceSystemCount: _requiredInt(map['sourceSystemCount']),
      sourceThemeCount: _requiredInt(map['sourceThemeCount']),
      engineVersion: _requiredString(map['engineVersion']),
      domainVersion: _requiredString(map['domainVersion']),
    );
  }
}

int _requiredInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  throw FormatException('Invalid int: $raw');
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}
