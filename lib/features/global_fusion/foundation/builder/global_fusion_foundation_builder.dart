import '../constants/global_fusion_foundation_version.dart';
import '../contracts/global_fusion_identity_contract.dart';
import '../contracts/global_fusion_input.dart';
import '../domain/global_fusion_coverage.dart';
import '../domain/global_fusion_identity.dart';
import '../domain/global_fusion_lineage.dart';
import '../domain/global_fusion_snapshot.dart';
import '../engines/cross_mirror_agreement_engine.dart';
import '../engines/cross_mirror_blind_spot_engine.dart';
import '../engines/cross_mirror_reinforcement_engine.dart';
import '../engines/cross_mirror_tension_engine.dart';
import '../engines/global_fusion_confidence_composer.dart';
import '../lineage/global_fusion_evidence_preserver.dart';

/// Assembles immutable [GlobalFusionSnapshot] from mirror snapshots only.
abstract final class GlobalFusionFoundationBuilder {
  static GlobalFusionSnapshot build(
    GlobalFusionInput input, {
    DateTime? createdAt,
  }) {
    if (input.mirrors.isEmpty) {
      throw ArgumentError('GlobalFusionInput requires at least one mirror');
    }

    final agreements = CrossMirrorAgreementEngine.detect(input);
    final tensions = CrossMirrorTensionEngine.detect(input);
    final reinforcements = CrossMirrorReinforcementEngine.detect(
      input: input,
      agreements: agreements,
    );
    final blindSpots = CrossMirrorBlindSpotEngine.detect(input);
    final coverage = _coverage(input);
    final confidence = GlobalFusionConfidenceComposer.compose(
      input: input,
      coverage: coverage,
      agreements: agreements,
      tensions: tensions,
      reinforcements: reinforcements,
    );

    final sourceIds = input.sourceMirrorSnapshotIds;
    final structuralHash = GlobalFusionStructuralHash.compute(
      sourceMirrorSnapshotIds: sourceIds,
      agreementIds: agreements.map((item) => item.id).toList(),
      tensionIds: tensions.map((item) => item.id).toList(),
      reinforcementIds: reinforcements.map((item) => item.id).toList(),
      blindSpotIds: blindSpots.map((item) => item.id).toList(),
    );

    final identity = GlobalFusionIdentity(
      snapshotId: GlobalFusionIdentityContract.snapshotId(
        sourceMirrorSnapshotIds: sourceIds,
        structuralHash: structuralHash,
      ),
      globalFusionId: GlobalFusionIdentityContract.globalFusionId(
        mirrorRoleIds: input.mirrorRoleIds,
        sourceMirrorSnapshotIds: sourceIds,
      ),
      sourceMirrorSnapshotIds: sourceIds,
      snapshotVersion: GlobalFusionFoundationVersion.snapshotVersion,
    );

    final evidence = GlobalFusionEvidencePreserver.preserve(
      input: input,
      agreements: agreements,
      tensions: tensions,
      reinforcements: reinforcements,
      blindSpots: blindSpots,
    );

    final lineage = GlobalFusionLineage(
      sourceMirrorSnapshotIds: sourceIds,
      mirrorRoleBySnapshotId: {
        for (final ref in input.mirrors)
          ref.snapshot.snapshotId: ref.mirrorRoleId,
      },
      sourceMirrorStructuralHashes: {
        for (final ref in input.mirrors)
          ref.snapshot.snapshotId: ref.snapshot.structuralHash,
      },
      foundationVersion: GlobalFusionFoundationVersion.foundationVersion,
    );

    return GlobalFusionSnapshot(
      identity: identity,
      coverage: coverage,
      confidence: confidence,
      agreements: List.unmodifiable(agreements),
      tensions: List.unmodifiable(tensions),
      reinforcements: List.unmodifiable(reinforcements),
      blindSpots: List.unmodifiable(blindSpots),
      evidence: List.unmodifiable(evidence),
      lineage: lineage,
      structuralHash: structuralHash,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
    );
  }

  static GlobalFusionCoverage _coverage(GlobalFusionInput input) {
    final dimensions = <String>{};
    var signalCount = 0;
    var coverageSum = 0.0;

    for (final ref in input.mirrors) {
      dimensions.addAll(ref.snapshot.coverage.coveredDimensions);
      signalCount += ref.snapshot.coverage.signalCount;
      coverageSum += ref.snapshot.coverage.weightedCoverage;
    }

    final mirrorCount = input.mirrorCount;
    final weightedCoverage = mirrorCount == 0
        ? 0.0
        : (coverageSum / mirrorCount).clamp(0.0, 1.0);

    return GlobalFusionCoverage(
      mirrorCount: mirrorCount,
      mirrorRoleIds: input.mirrorRoleIds,
      coveredDimensions: dimensions.toList()..sort(),
      totalSignalCount: signalCount,
      weightedCoverage: weightedCoverage,
    );
  }
}
