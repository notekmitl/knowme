import 'package:knowme/features/global_fusion/foundation/constants/global_fusion_foundation_version.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_identity_contract.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_findings.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_identity.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_lineage.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/foundation/lineage/global_fusion_evidence_preserver.dart';

import '../constants/global_fusion_v2_version.dart';
import '../domain/global_fusion_composed_snapshot.dart';
import '../domain/global_fusion_recovered_snapshot.dart';
import '../domain/global_fusion_supplemental_findings.dart';

/// FCR4/FCR5 — composes V1 + supplemental into downstream-compatible snapshot.
abstract final class GlobalFusionRecoveryComposer {
  static GlobalFusionComposedSnapshot compose({
    required GlobalFusionInput input,
    required GlobalFusionRecoveredSnapshot recovered,
  }) {
    final fusionSnapshot = _composeFusionSnapshot(input: input, recovered: recovered);
    return GlobalFusionComposedSnapshot(
      fusionSnapshot: fusionSnapshot,
      foundationSnapshot: recovered.foundationSnapshot,
      recovery: recovered,
      supplementalAgreementCount: recovered.supplementalAgreements.length,
      supplementalReinforcementCount: recovered.supplementalReinforcements.length,
      composedAt: recovered.createdAt,
    );
  }

  static GlobalFusionSnapshot composeForSimulation({
    required GlobalFusionInput input,
    required GlobalFusionRecoveredSnapshot recovered,
  }) {
    return _composeFusionSnapshot(input: input, recovered: recovered);
  }

  static GlobalFusionSnapshot _composeFusionSnapshot({
    required GlobalFusionInput input,
    required GlobalFusionRecoveredSnapshot recovered,
  }) {
    final foundation = recovered.foundationSnapshot;

    final agreements = [
      ...foundation.agreements,
      ...recovered.supplementalAgreements.map(_toAgreement),
    ]..sort((a, b) => a.id.compareTo(b.id));

    final reinforcements = [
      ...foundation.reinforcements,
      ...recovered.supplementalReinforcements.map(_toReinforcement),
    ]..sort((a, b) => a.id.compareTo(b.id));

    final tensions = List<GlobalFusionCrossMirrorTension>.from(foundation.tensions);
    final blindSpots =
        List<GlobalFusionCrossMirrorBlindSpot>.from(foundation.blindSpots);

    final evidence = GlobalFusionEvidencePreserver.preserve(
      input: input,
      agreements: agreements,
      tensions: tensions,
      reinforcements: reinforcements,
      blindSpots: blindSpots,
    );

    final structuralHash = GlobalFusionStructuralHash.compute(
      sourceMirrorSnapshotIds: foundation.lineage.sourceMirrorSnapshotIds,
      agreementIds: agreements.map((item) => item.id).toList(),
      tensionIds: tensions.map((item) => item.id).toList(),
      reinforcementIds: reinforcements.map((item) => item.id).toList(),
      blindSpotIds: blindSpots.map((item) => item.id).toList(),
    );

    final recoveryHashSuffix =
        recovered.supplementalFindingCount.toRadixString(16).padLeft(4, '0');

    final identity = GlobalFusionIdentity(
      snapshotId: GlobalFusionIdentityContract.snapshotId(
        sourceMirrorSnapshotIds: foundation.lineage.sourceMirrorSnapshotIds,
        structuralHash: '$structuralHash$recoveryHashSuffix',
      ),
      globalFusionId: foundation.identity.globalFusionId,
      sourceMirrorSnapshotIds: foundation.lineage.sourceMirrorSnapshotIds,
      snapshotVersion: GlobalFusionFoundationVersion.snapshotVersion,
    );

    final lineage = GlobalFusionLineage(
      sourceMirrorSnapshotIds: foundation.lineage.sourceMirrorSnapshotIds,
      mirrorRoleBySnapshotId: foundation.lineage.mirrorRoleBySnapshotId,
      sourceMirrorStructuralHashes: foundation.lineage.sourceMirrorStructuralHashes,
      foundationVersion:
          '${foundation.lineage.foundationVersion}+${GlobalFusionV2Version.recoveryVersion}',
    );

    return GlobalFusionSnapshot(
      identity: identity,
      coverage: foundation.coverage,
      confidence: foundation.confidence,
      agreements: List.unmodifiable(agreements),
      tensions: List.unmodifiable(tensions),
      reinforcements: List.unmodifiable(reinforcements),
      blindSpots: List.unmodifiable(blindSpots),
      evidence: List.unmodifiable(evidence),
      lineage: lineage,
      structuralHash: structuralHash,
      createdAt: recovered.createdAt,
    );
  }

  static GlobalFusionCrossMirrorAgreement _toAgreement(
    GlobalFusionSupplementalAgreement supplemental,
  ) {
    return GlobalFusionCrossMirrorAgreement(
      id: supplemental.id,
      mirrorKey: supplemental.mirrorKey,
      mirrorDimension: supplemental.mirrorDimension,
      mirrorRoleIds: supplemental.mirrorRoleIds,
      mirrorFindingIds: supplemental.mirrorFindingIds,
      themeIds: supplemental.themeIds,
      confidence: supplemental.agreementStrength,
      agreementStrength: supplemental.agreementStrength,
    );
  }

  static GlobalFusionCrossMirrorReinforcement _toReinforcement(
    GlobalFusionSupplementalReinforcement supplemental,
  ) {
    return GlobalFusionCrossMirrorReinforcement(
      id: supplemental.id,
      mirrorKey: supplemental.mirrorKey,
      mirrorDimension: supplemental.mirrorDimension,
      mirrorRoleIds: supplemental.mirrorRoleIds,
      mirrorFindingIds: supplemental.mirrorFindingIds,
      themeIds: supplemental.themeIds,
      evidenceCount: supplemental.evidenceCount,
      reinforcementBoost: supplemental.reinforcementBoost,
    );
  }
}
