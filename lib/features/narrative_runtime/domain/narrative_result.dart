import 'narrative_confidence.dart';
import 'narrative_mode.dart';
import 'narrative_section.dart';

/// Production narrative output — generated from [HumanPatternSnapshot] only.
class NarrativeResult {
  const NarrativeResult({
    required this.sourceSnapshotId,
    required this.sourceStructuralHash,
    required this.sections,
    required this.confidence,
    required this.runtimeVersion,
    required this.createdAt,
  });

  final String sourceSnapshotId;
  final String sourceStructuralHash;
  final List<NarrativeSection> sections;
  final NarrativeConfidence confidence;
  final String runtimeVersion;
  final DateTime createdAt;

  NarrativeSection? sectionFor(NarrativeMode mode) {
    for (final section in sections) {
      if (section.mode == mode) return section;
    }
    return null;
  }

  int get paragraphCount =>
      sections.fold(0, (sum, section) => sum + section.paragraphs.length);

  Map<String, dynamic> toMap() {
    return {
      'sourceSnapshotId': sourceSnapshotId,
      'sourceStructuralHash': sourceStructuralHash,
      'sections': sections.map((item) => item.toMap()).toList(),
      'confidence': confidence.toMap(),
      'runtimeVersion': runtimeVersion,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory NarrativeResult.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is! String) {
      throw FormatException('Invalid createdAt: $createdAtRaw');
    }

    return NarrativeResult(
      sourceSnapshotId: _requiredString(map['sourceSnapshotId']),
      sourceStructuralHash: _requiredString(map['sourceStructuralHash']),
      sections: _sectionList(map['sections']),
      confidence: NarrativeConfidence.fromMap(
        Map<String, dynamic>.from(map['confidence'] as Map),
      ),
      runtimeVersion: _requiredString(map['runtimeVersion']),
      createdAt: DateTime.parse(createdAtRaw).toUtc(),
    );
  }
}

List<NarrativeSection> _sectionList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => NarrativeSection.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}
