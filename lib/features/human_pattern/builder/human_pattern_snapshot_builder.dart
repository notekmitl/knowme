import 'dart:convert';

import 'package:knowme/features/human_model/domain/human_dimension.dart';

import '../constants/human_pattern_system_version.dart';
import '../contracts/human_pattern_identity_contract.dart';
import '../contracts/human_pattern_input.dart';
import '../domain/human_pattern_snapshot.dart';
import '../domain/human_pattern_snapshot_identity.dart';
import '../domain/pattern_activation.dart';
import '../domain/pattern_lineage.dart';
import '../domain/pattern_snapshot_coverage.dart';
import '../engines/pattern_activation_engine.dart';
import '../lineage/pattern_evidence_preserver.dart';
import '../registry/human_pattern_registry.dart';

abstract final class HumanPatternSnapshotBuilder {
  static HumanPatternSnapshot build(
    HumanPatternInput input, {
    DateTime? createdAt,
  }) {
    final humanModelSnapshot = input.humanModelSnapshot;
    final activations = PatternActivationEngine.activate(humanModelSnapshot);
    final evidence = PatternEvidencePreserver.preserve(
      humanModelSnapshot: humanModelSnapshot,
      activations: activations,
    );
    final confidence = PatternConfidenceComposer.aggregate(activations);
    final coverage = _coverage(activations);

    final structuralHash = _structuralHash(
      sourceHumanModelSnapshotId: humanModelSnapshot.snapshotId,
      activationIds: activations.map((item) => item.activationId).toList(),
      registryVersion: HumanPatternRegistry.version,
    );

    final identity = HumanPatternSnapshotIdentity(
      snapshotId: HumanPatternIdentityContract.snapshotId(
        sourceHumanModelSnapshotId: humanModelSnapshot.snapshotId,
        structuralHash: structuralHash,
        registryVersion: HumanPatternRegistry.version,
      ),
      humanPatternSystemId: HumanPatternIdentityContract.humanPatternSystemId(
        sourceHumanModelSnapshotId: humanModelSnapshot.snapshotId,
      ),
      sourceHumanModelSnapshotId: humanModelSnapshot.snapshotId,
      snapshotVersion: HumanPatternSystemVersion.snapshotVersion,
      registryVersion: HumanPatternRegistry.version,
    );

    final lineage = PatternLineage(
      sourceHumanModelSnapshotId: humanModelSnapshot.snapshotId,
      sourceHumanModelStructuralHash: humanModelSnapshot.structuralHash,
      sourceGlobalFusionSnapshotId:
          humanModelSnapshot.lineage.sourceGlobalFusionSnapshotId,
      registryVersion: HumanPatternRegistry.version,
      activationByPatternId: {
        for (final activation in activations)
          activation.patternId: activation.activationId,
      },
    );

    return HumanPatternSnapshot(
      identity: identity,
      activations: List.unmodifiable(activations),
      confidence: confidence,
      coverage: coverage,
      evidence: List.unmodifiable(evidence),
      lineage: lineage,
      structuralHash: structuralHash,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
    );
  }

  static PatternSnapshotCoverage _coverage(List<PatternActivation> activations) {
    final dimensions = activations.map((item) => item.dimension.key).toSet()
      ..removeWhere((key) => key.isEmpty);
    final activatedKeys = dimensions.toList()..sort();

    return PatternSnapshotCoverage(
      registryPatternCount: HumanPatternRegistry.allEntries.length,
      activatedPatternCount: activations.length,
      activatedDimensionCount: dimensions.length,
      weightedCoverage: HumanDimensionId.values.isEmpty
          ? 0.0
          : (dimensions.length / HumanDimensionId.values.length).clamp(0.0, 1.0),
      activatedDimensionKeys: activatedKeys,
    );
  }

  static String _structuralHash({
    required String sourceHumanModelSnapshotId,
    required List<String> activationIds,
    required String registryVersion,
  }) {
    final payload = jsonEncode({
      'sourceHumanModelSnapshotId': sourceHumanModelSnapshotId,
      'activationIds': (List<String>.from(activationIds)..sort()),
      'registryVersion': registryVersion,
    });

    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(payload)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
