import 'human_confidence.dart';
import 'human_coverage.dart';
import 'human_evidence.dart';
import 'human_lineage.dart';
import 'human_model_identity.dart';
import 'human_pattern.dart';
import 'human_profile.dart';

/// Immutable human model snapshot — narrative-ready foundation output (HM8).
class HumanModelSnapshot {
  const HumanModelSnapshot({
    required this.identity,
    required this.profile,
    required this.confidence,
    required this.coverage,
    required this.evidence,
    required this.lineage,
    required this.structuralHash,
    required this.createdAt,
  });

  final HumanModelIdentity identity;
  final HumanProfile profile;
  final HumanConfidence confidence;
  final HumanCoverage coverage;
  final List<HumanEvidence> evidence;
  final HumanLineage lineage;
  final String structuralHash;
  final DateTime createdAt;

  String get snapshotId => identity.snapshotId;

  List<HumanPattern> get patterns => profile.patterns;

  Map<String, dynamic> toMap() {
    return {
      'identity': identity.toMap(),
      'profile': profile.toMap(),
      'confidence': confidence.toMap(),
      'coverage': coverage.toMap(),
      'evidence': evidence.map((item) => item.toMap()).toList(),
      'lineage': lineage.toMap(),
      'structuralHash': structuralHash,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory HumanModelSnapshot.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is! String) {
      throw FormatException('Invalid createdAt: $createdAtRaw');
    }

    return HumanModelSnapshot(
      identity: HumanModelIdentity.fromMap(
        Map<String, dynamic>.from(map['identity'] as Map),
      ),
      profile: HumanProfile.fromMap(
        Map<String, dynamic>.from(map['profile'] as Map),
      ),
      confidence: HumanConfidence.fromMap(
        Map<String, dynamic>.from(map['confidence'] as Map),
      ),
      coverage: HumanCoverage.fromMap(
        Map<String, dynamic>.from(map['coverage'] as Map),
      ),
      evidence: _evidence(map['evidence']),
      lineage: HumanLineage.fromMap(
        Map<String, dynamic>.from(map['lineage'] as Map),
      ),
      structuralHash: _requiredString(map['structuralHash']),
      createdAt: DateTime.parse(createdAtRaw).toUtc(),
    );
  }
}

List<HumanEvidence> _evidence(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => HumanEvidence.fromMap(
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
