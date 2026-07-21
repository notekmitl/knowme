import '../enums/knowme_mirror_source_type.dart';
import '../enums/knowme_mirror_system_id.dart';

/// System-specific evidence row preserved on mirror objects.
class KnowMeMirrorEvidenceRef {
  const KnowMeMirrorEvidenceRef({
    required this.systemId,
    required this.sourceType,
    required this.sourceThemeId,
    required this.sourceSnapshotId,
    required this.ruleId,
    required this.weight,
  });

  final KnowMeMirrorSystemId systemId;
  final KnowMeMirrorSourceType sourceType;
  final String sourceThemeId;
  final String sourceSnapshotId;
  final String ruleId;
  final double weight;

  Map<String, dynamic> toMap() {
    return {
      'systemId': systemId.id,
      'sourceType': sourceType.id,
      'sourceThemeId': sourceThemeId,
      'sourceSnapshotId': sourceSnapshotId,
      'ruleId': ruleId,
      'weight': weight,
    };
  }

  factory KnowMeMirrorEvidenceRef.fromMap(Map<String, dynamic> map) {
    final systemId = parseKnowMeMirrorSystemId(_requiredString(map['systemId']));
    final sourceType =
        parseKnowMeMirrorSourceType(_requiredString(map['sourceType']));
    if (systemId == null || sourceType == null) {
      throw FormatException('Invalid evidence ref: $map');
    }

    final weight = map['weight'];
    if (weight is! num) {
      throw FormatException('Invalid weight: $weight');
    }

    return KnowMeMirrorEvidenceRef(
      systemId: systemId,
      sourceType: sourceType,
      sourceThemeId: _requiredString(map['sourceThemeId']),
      sourceSnapshotId: _requiredString(map['sourceSnapshotId']),
      ruleId: _requiredString(map['ruleId']),
      weight: weight.toDouble(),
    );
  }

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }
}
