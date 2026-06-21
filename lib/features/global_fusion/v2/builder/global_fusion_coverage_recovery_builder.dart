import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

import '../audit/fusion_compression_audit.dart';
import '../audit/fusion_coverage_audit.dart';
import '../audit/recoverable_findings_audit.dart';
import '../constants/global_fusion_v2_version.dart';
import '../domain/fusion_recovery_enums.dart';
import '../domain/global_fusion_recovered_snapshot.dart';
import '../engines/filtered_mirror_reinforcement_recovery_engine.dart';
import '../engines/supplemental_agreement_recovery_engine.dart';
import '../engines/supplemental_reinforcement_recovery_engine.dart';
import '../engines/supplemental_single_mirror_reinforcement_engine.dart';
import '../engines/supplemental_theme_recovery_engine.dart';

/// FCR4 — orchestrates V2 coverage recovery without modifying V1 foundation.
class GlobalFusionRecoveryResult {
  const GlobalFusionRecoveryResult({
    required this.recoveredSnapshot,
    required this.coverageAudit,
    required this.compressionAudit,
    required this.recoverableAudit,
  });

  final GlobalFusionRecoveredSnapshot recoveredSnapshot;
  final FusionCoverageAuditReport coverageAudit;
  final FusionCompressionAuditReport compressionAudit;
  final RecoverableFindingsAuditReport recoverableAudit;
}

abstract final class GlobalFusionCoverageRecoveryBuilder {
  static GlobalFusionRecoveryResult build({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
    DateTime? createdAt,
  }) {
    final coverageAudit = FusionCoverageAudit.analyze(
      input: input,
      foundationSnapshot: foundationSnapshot,
    );

    final filteredByRule = <FusionCompressionRule, int>{};
    for (final entry in coverageAudit.entries) {
      if (entry.disposition != MirrorFindingDisposition.filtered) continue;
      final rule = entry.filterRule;
      if (rule == null) continue;
      filteredByRule[rule] = (filteredByRule[rule] ?? 0) + 1;
    }

    final fusionFindingCount = foundationSnapshot.agreements.length +
        foundationSnapshot.tensions.length +
        foundationSnapshot.reinforcements.length +
        foundationSnapshot.blindSpots.length;

    final compressionAudit = FusionCompressionAudit.analyze(
      totalMirrorFindings: coverageAudit.totalMirrorFindings,
      fusionFindingCount: fusionFindingCount,
      filteredByRule: filteredByRule,
    );

    final bridgeReinforcements =
        SupplementalReinforcementRecoveryEngine.recover(
      input: input,
      foundationSnapshot: foundationSnapshot,
    );

    final bridgeSourceIds = bridgeReinforcements
        .expand((item) => item.sourceFindingIds)
        .toSet();

    final recoveredThemes = bridgeReinforcements
        .expand((item) => item.themeIds)
        .toSet();

    final singleReinforcements =
        SupplementalSingleMirrorReinforcementEngine.recover(
      input: input,
      foundationSnapshot: foundationSnapshot,
      recoveredSourceIds: bridgeSourceIds,
    );

    final singleSourceIds = singleReinforcements
        .expand((item) => item.sourceFindingIds)
        .toSet();

    final supplementalAgreements =
        SupplementalAgreementRecoveryEngine.recover(
      input: input,
      foundationSnapshot: foundationSnapshot,
      recoveredSourceIds: {...bridgeSourceIds, ...singleSourceIds},
    );

    recoveredThemes.addAll(
      supplementalAgreements.expand((item) => item.themeIds),
    );

    final r004SourceIds = {
      ...bridgeSourceIds,
      ...singleSourceIds,
      ...supplementalAgreements.expand((item) => item.sourceFindingIds),
    };

    final r004Reinforcements =
        FilteredMirrorReinforcementRecoveryEngine.recover(
      input: input,
      foundationSnapshot: foundationSnapshot,
      supplementalAgreements: supplementalAgreements,
      recoveredSourceIds: r004SourceIds,
    );

    final supplementalReinforcements = [
      ...bridgeReinforcements,
      ...singleReinforcements,
      ...r004Reinforcements,
    ];

    final supplementalThemeSignals = SupplementalThemeRecoveryEngine.recover(
      input: input,
      foundationSnapshot: foundationSnapshot,
      recoveredThemeKeys: recoveredThemes,
    );

    final recoveredSnapshot = GlobalFusionRecoveredSnapshot(
      foundationSnapshot: foundationSnapshot,
      supplementalReinforcements: supplementalReinforcements,
      supplementalAgreements: supplementalAgreements,
      supplementalThemeSignals: supplementalThemeSignals,
      recoveryVersion: GlobalFusionV2Version.recoveryVersion,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
    );

    final recoverableAudit = RecoverableFindingsAudit.fromSupplemental(
      reinforcements: supplementalReinforcements,
      agreements: supplementalAgreements,
      themeSignals: supplementalThemeSignals,
    );

    return GlobalFusionRecoveryResult(
      recoveredSnapshot: recoveredSnapshot,
      coverageAudit: coverageAudit,
      compressionAudit: compressionAudit,
      recoverableAudit: recoverableAudit,
    );
  }
}
