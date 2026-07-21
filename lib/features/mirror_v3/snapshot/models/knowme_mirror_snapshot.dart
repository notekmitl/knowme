import 'knowme_mirror_snapshot_confidence.dart';
import 'knowme_mirror_snapshot_coverage.dart';
import 'knowme_mirror_snapshot_evidence.dart';
import 'knowme_mirror_snapshot_findings.dart';
import 'knowme_mirror_snapshot_identity.dart';
import 'knowme_mirror_snapshot_lineage.dart';
import 'knowme_mirror_snapshot_metadata.dart';
import '../../promotion/domain/knowme_mirror_promoted_finding.dart';

/// Immutable persisted mirror reflection asset (MV3.1).
class KnowMeMirrorSnapshot {
  const KnowMeMirrorSnapshot({
    required this.identity,
    required this.metadata,
    required this.coverage,
    required this.confidence,
    required this.agreements,
    required this.tensions,
    required this.reinforcements,
    required this.blindSpots,
    required this.evidence,
    required this.promotedFindings,
    required this.lineage,
    required this.structuralHash,
    required this.createdAt,
    required this.engineVersion,
  });

  final KnowMeMirrorSnapshotIdentity identity;
  final KnowMeMirrorSnapshotMetadata metadata;
  final KnowMeMirrorSnapshotCoverage coverage;
  final KnowMeMirrorSnapshotConfidence confidence;
  final List<KnowMeMirrorSnapshotAgreement> agreements;
  final List<KnowMeMirrorSnapshotTension> tensions;
  final List<KnowMeMirrorSnapshotReinforcement> reinforcements;
  final List<KnowMeMirrorSnapshotBlindSpot> blindSpots;
  final List<KnowMeMirrorSnapshotEvidenceRow> evidence;
  final List<KnowMeMirrorPromotedFinding> promotedFindings;
  final KnowMeMirrorSnapshotLineage lineage;
  final String structuralHash;
  final DateTime createdAt;
  final String engineVersion;

  String get snapshotId => identity.snapshotId;
  String get mirrorId => identity.mirrorId;
  String get mirrorBundleId => identity.mirrorBundleId;
  String get snapshotVersion => identity.snapshotVersion;

  Map<String, dynamic> toMap() {
    return {
      'identity': identity.toMap(),
      'metadata': metadata.toMap(),
      'coverage': coverage.toMap(),
      'confidence': confidence.toMap(),
      'agreements': agreements.map((item) => item.toMap()).toList(),
      'tensions': tensions.map((item) => item.toMap()).toList(),
      'reinforcements': reinforcements.map((item) => item.toMap()).toList(),
      'blindSpots': blindSpots.map((item) => item.toMap()).toList(),
      'evidence': evidence.map((item) => item.toMap()).toList(),
      'promotedFindings':
          promotedFindings.map((item) => item.toMap()).toList(),
      'lineage': lineage.toMap(),
      'structuralHash': structuralHash,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'engineVersion': engineVersion,
    };
  }

  factory KnowMeMirrorSnapshot.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is! String) {
      throw FormatException('Invalid createdAt: $createdAtRaw');
    }

    return KnowMeMirrorSnapshot(
      identity: KnowMeMirrorSnapshotIdentity.fromMap(
        Map<String, dynamic>.from(map['identity'] as Map),
      ),
      metadata: KnowMeMirrorSnapshotMetadata.fromMap(
        Map<String, dynamic>.from(map['metadata'] as Map),
      ),
      coverage: KnowMeMirrorSnapshotCoverage.fromMap(
        Map<String, dynamic>.from(map['coverage'] as Map),
      ),
      confidence: KnowMeMirrorSnapshotConfidence.fromMap(
        Map<String, dynamic>.from(map['confidence'] as Map),
      ),
      agreements: _findingsList<KnowMeMirrorSnapshotAgreement>(
        map['agreements'],
        KnowMeMirrorSnapshotAgreement.fromMap,
      ),
      tensions: _findingsList<KnowMeMirrorSnapshotTension>(
        map['tensions'],
        KnowMeMirrorSnapshotTension.fromMap,
      ),
      reinforcements: _findingsList<KnowMeMirrorSnapshotReinforcement>(
        map['reinforcements'],
        KnowMeMirrorSnapshotReinforcement.fromMap,
      ),
      blindSpots: _findingsList<KnowMeMirrorSnapshotBlindSpot>(
        map['blindSpots'],
        KnowMeMirrorSnapshotBlindSpot.fromMap,
      ),
      evidence: _findingsList<KnowMeMirrorSnapshotEvidenceRow>(
        map['evidence'],
        KnowMeMirrorSnapshotEvidenceRow.fromMap,
      ),
      promotedFindings: _promotedFindings(map['promotedFindings']),
      lineage: KnowMeMirrorSnapshotLineage.fromMap(
        Map<String, dynamic>.from(map['lineage'] as Map),
      ),
      structuralHash: _requiredString(map['structuralHash']),
      createdAt: DateTime.parse(createdAtRaw).toUtc(),
      engineVersion: _requiredString(map['engineVersion']),
    );
  }
}

List<KnowMeMirrorPromotedFinding> _promotedFindings(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map(
        (item) => KnowMeMirrorPromotedFinding.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}

List<T> _findingsList<T>(
  dynamic raw,
  T Function(Map<String, dynamic> map) parse,
) {
  if (raw is! List) return <T>[];
  return raw
      .whereType<Map>()
      .map((item) => parse(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}
