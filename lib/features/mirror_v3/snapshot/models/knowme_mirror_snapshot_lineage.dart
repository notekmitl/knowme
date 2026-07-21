/// Traceable source snapshot lineage preserved on MV3 snapshot.
class KnowMeMirrorSnapshotLineage {
  const KnowMeMirrorSnapshotLineage({
    required this.mirrorScopeId,
    required this.personalityOnly,
    required this.sourceSnapshotVersions,
    this.astrologyThemeSnapshotId,
    this.astrologyThemeBundleId,
    this.astrologyMeaningSnapshotId,
    this.mbtiLensSnapshotId,
    this.bigFiveLensSnapshotId,
    this.eqLensSnapshotId,
    this.promotionVersion,
    this.promotionRuleIds = const [],
  });

  final String mirrorScopeId;
  final String? astrologyThemeSnapshotId;
  final String? astrologyThemeBundleId;
  final String? astrologyMeaningSnapshotId;
  final String? mbtiLensSnapshotId;
  final String? bigFiveLensSnapshotId;
  final String? eqLensSnapshotId;
  final bool personalityOnly;
  final Map<String, String> sourceSnapshotVersions;
  final String? promotionVersion;
  final List<String> promotionRuleIds;

  Map<String, dynamic> toMap() {
    return {
      'mirrorScopeId': mirrorScopeId,
      'astrologyThemeSnapshotId': astrologyThemeSnapshotId,
      'astrologyThemeBundleId': astrologyThemeBundleId,
      'astrologyMeaningSnapshotId': astrologyMeaningSnapshotId,
      'mbtiLensSnapshotId': mbtiLensSnapshotId,
      'bigFiveLensSnapshotId': bigFiveLensSnapshotId,
      'eqLensSnapshotId': eqLensSnapshotId,
      'personalityOnly': personalityOnly,
      'sourceSnapshotVersions': sourceSnapshotVersions,
      if (promotionVersion != null) 'promotionVersion': promotionVersion,
      'promotionRuleIds': promotionRuleIds,
    };
  }

  factory KnowMeMirrorSnapshotLineage.fromMap(Map<String, dynamic> map) {
    final versionsRaw = map['sourceSnapshotVersions'];
    final versions = <String, String>{};
    if (versionsRaw is Map) {
      for (final entry in versionsRaw.entries) {
        if (entry.key is String && entry.value is String) {
          versions[entry.key as String] = entry.value as String;
        }
      }
    }

    return KnowMeMirrorSnapshotLineage(
      mirrorScopeId: _requiredString(map['mirrorScopeId']),
      astrologyThemeSnapshotId: _optionalString(map['astrologyThemeSnapshotId']),
      astrologyThemeBundleId: _optionalString(map['astrologyThemeBundleId']),
      astrologyMeaningSnapshotId:
          _optionalString(map['astrologyMeaningSnapshotId']),
      mbtiLensSnapshotId: _optionalString(map['mbtiLensSnapshotId']),
      bigFiveLensSnapshotId: _optionalString(map['bigFiveLensSnapshotId']),
      eqLensSnapshotId: _optionalString(map['eqLensSnapshotId']),
      personalityOnly: map['personalityOnly'] == true,
      sourceSnapshotVersions: Map<String, String>.unmodifiable(versions),
      promotionVersion: _optionalString(map['promotionVersion']),
      promotionRuleIds: _stringList(map['promotionRuleIds']),
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

String? _optionalString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) return null;
  return raw.trim();
}
