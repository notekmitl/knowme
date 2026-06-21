import 'global_fusion_confidence.dart';
import 'global_fusion_coverage.dart';
import 'global_fusion_evidence.dart';
import 'global_fusion_findings.dart';
import 'global_fusion_identity.dart';
import 'global_fusion_lineage.dart';

/// Immutable global fusion snapshot — mirror aggregation output (GF9).
class GlobalFusionSnapshot {
  const GlobalFusionSnapshot({
    required this.identity,
    required this.coverage,
    required this.confidence,
    required this.agreements,
    required this.tensions,
    required this.reinforcements,
    required this.blindSpots,
    required this.evidence,
    required this.lineage,
    required this.structuralHash,
    required this.createdAt,
  });

  final GlobalFusionIdentity identity;
  final GlobalFusionCoverage coverage;
  final GlobalFusionConfidence confidence;
  final List<GlobalFusionCrossMirrorAgreement> agreements;
  final List<GlobalFusionCrossMirrorTension> tensions;
  final List<GlobalFusionCrossMirrorReinforcement> reinforcements;
  final List<GlobalFusionCrossMirrorBlindSpot> blindSpots;
  final List<GlobalFusionEvidence> evidence;
  final GlobalFusionLineage lineage;
  final String structuralHash;
  final DateTime createdAt;

  String get snapshotId => identity.snapshotId;

  Map<String, dynamic> toMap() {
    return {
      'identity': identity.toMap(),
      'coverage': coverage.toMap(),
      'confidence': confidence.toMap(),
      'agreements': agreements.map((item) => item.toMap()).toList(),
      'tensions': tensions.map((item) => item.toMap()).toList(),
      'reinforcements': reinforcements.map((item) => item.toMap()).toList(),
      'blindSpots': blindSpots.map((item) => item.toMap()).toList(),
      'evidence': evidence.map((item) => item.toMap()).toList(),
      'lineage': lineage.toMap(),
      'structuralHash': structuralHash,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory GlobalFusionSnapshot.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is! String) {
      throw FormatException('Invalid createdAt: $createdAtRaw');
    }

    return GlobalFusionSnapshot(
      identity: GlobalFusionIdentity.fromMap(
        Map<String, dynamic>.from(map['identity'] as Map),
      ),
      coverage: GlobalFusionCoverage.fromMap(
        Map<String, dynamic>.from(map['coverage'] as Map),
      ),
      confidence: GlobalFusionConfidence.fromMap(
        Map<String, dynamic>.from(map['confidence'] as Map),
      ),
      agreements: _agreements(map['agreements']),
      tensions: _tensions(map['tensions']),
      reinforcements: _reinforcements(map['reinforcements']),
      blindSpots: _blindSpots(map['blindSpots']),
      evidence: _evidence(map['evidence']),
      lineage: GlobalFusionLineage.fromMap(
        Map<String, dynamic>.from(map['lineage'] as Map),
      ),
      structuralHash: _requiredString(map['structuralHash']),
      createdAt: DateTime.parse(createdAtRaw).toUtc(),
    );
  }
}

List<GlobalFusionCrossMirrorAgreement> _agreements(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => GlobalFusionCrossMirrorAgreement.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<GlobalFusionCrossMirrorTension> _tensions(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => GlobalFusionCrossMirrorTension.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<GlobalFusionCrossMirrorReinforcement> _reinforcements(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => GlobalFusionCrossMirrorReinforcement.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<GlobalFusionCrossMirrorBlindSpot> _blindSpots(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => GlobalFusionCrossMirrorBlindSpot.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<GlobalFusionEvidence> _evidence(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => GlobalFusionEvidence.fromMap(
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
