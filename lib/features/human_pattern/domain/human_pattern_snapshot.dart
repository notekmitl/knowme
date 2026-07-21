import 'pattern_activation.dart';
import 'pattern_confidence.dart';
import 'pattern_evidence.dart';
import 'pattern_lineage.dart';
import 'pattern_snapshot_coverage.dart';
import 'human_pattern_snapshot_identity.dart';

/// Immutable human pattern snapshot — narrative input foundation (HP8).
class HumanPatternSnapshot {
  const HumanPatternSnapshot({
    required this.identity,
    required this.activations,
    required this.confidence,
    required this.coverage,
    required this.evidence,
    required this.lineage,
    required this.structuralHash,
    required this.createdAt,
  });

  final HumanPatternSnapshotIdentity identity;
  final List<PatternActivation> activations;
  final PatternConfidence confidence;
  final PatternSnapshotCoverage coverage;
  final List<PatternEvidence> evidence;
  final PatternLineage lineage;
  final String structuralHash;
  final DateTime createdAt;

  String get snapshotId => identity.snapshotId;

  Map<String, dynamic> toMap() {
    return {
      'identity': identity.toMap(),
      'activations': activations.map((item) => item.toMap()).toList(),
      'confidence': confidence.toMap(),
      'coverage': coverage.toMap(),
      'evidence': evidence.map((item) => item.toMap()).toList(),
      'lineage': lineage.toMap(),
      'structuralHash': structuralHash,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory HumanPatternSnapshot.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is! String) {
      throw FormatException('Invalid createdAt: $createdAtRaw');
    }

    return HumanPatternSnapshot(
      identity: HumanPatternSnapshotIdentity.fromMap(
        Map<String, dynamic>.from(map['identity'] as Map),
      ),
      activations: _activations(map['activations']),
      confidence: PatternConfidence.fromMap(
        Map<String, dynamic>.from(map['confidence'] as Map),
      ),
      coverage: PatternSnapshotCoverage.fromMap(
        Map<String, dynamic>.from(map['coverage'] as Map),
      ),
      evidence: _evidence(map['evidence']),
      lineage: PatternLineage.fromMap(
        Map<String, dynamic>.from(map['lineage'] as Map),
      ),
      structuralHash: _requiredString(map['structuralHash']),
      createdAt: DateTime.parse(createdAtRaw).toUtc(),
    );
  }
}

List<PatternActivation> _activations(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => PatternActivation.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<PatternEvidence> _evidence(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => PatternEvidence.fromMap(
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
