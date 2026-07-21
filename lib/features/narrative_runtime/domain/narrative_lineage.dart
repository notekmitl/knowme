/// Full traceability chain preserved on every narrative paragraph.
class NarrativeLineage {
  const NarrativeLineage({
    required this.narrativeParagraphId,
    required this.patternId,
    required this.activationId,
    required this.humanModelPatternId,
    required this.humanModelSnapshotId,
    required this.fusionFindingId,
    required this.mirrorFindingId,
    required this.mirrorSnapshotId,
    required this.mirrorRoleId,
    required this.sourceThemeId,
    required this.themeIds,
  });

  final String narrativeParagraphId;
  final String patternId;
  final String activationId;
  final String humanModelPatternId;
  final String humanModelSnapshotId;
  final String fusionFindingId;
  final String mirrorFindingId;
  final String mirrorSnapshotId;
  final String mirrorRoleId;
  final String sourceThemeId;
  final List<String> themeIds;

  Map<String, dynamic> toMap() {
    return {
      'narrativeParagraphId': narrativeParagraphId,
      'patternId': patternId,
      'activationId': activationId,
      'humanModelPatternId': humanModelPatternId,
      'humanModelSnapshotId': humanModelSnapshotId,
      'fusionFindingId': fusionFindingId,
      'mirrorFindingId': mirrorFindingId,
      'mirrorSnapshotId': mirrorSnapshotId,
      'mirrorRoleId': mirrorRoleId,
      'sourceThemeId': sourceThemeId,
      'themeIds': themeIds,
    };
  }

  factory NarrativeLineage.fromMap(Map<String, dynamic> map) {
    return NarrativeLineage(
      narrativeParagraphId: _requiredString(map['narrativeParagraphId']),
      patternId: _requiredString(map['patternId']),
      activationId: _requiredString(map['activationId']),
      humanModelPatternId: _requiredString(map['humanModelPatternId']),
      humanModelSnapshotId: _requiredString(map['humanModelSnapshotId']),
      fusionFindingId: _requiredString(map['fusionFindingId']),
      mirrorFindingId: _requiredString(map['mirrorFindingId']),
      mirrorSnapshotId: _requiredString(map['mirrorSnapshotId']),
      mirrorRoleId: _requiredString(map['mirrorRoleId']),
      sourceThemeId: _requiredString(map['sourceThemeId']),
      themeIds: _stringList(map['themeIds']),
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
