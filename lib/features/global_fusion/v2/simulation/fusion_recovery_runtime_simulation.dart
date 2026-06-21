import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';

import '../builder/global_fusion_coverage_recovery_builder.dart';
import '../engines/global_fusion_recovery_composer.dart';
import '../report/fusion_recovery_comparative_report.dart';

/// FCR5 — runtime simulation using real mirrors + V2 recovery (RT/HM/HP read-only).
class FusionRecoveryRuntimeSimulationResult {
  const FusionRecoveryRuntimeSimulationResult({
    required this.recoveryResult,
    required this.comparativeReport,
    required this.composedFusionSnapshot,
    required this.simulatedHumanModelSnapshot,
    required this.simulatedHumanPatternSnapshot,
  });

  final GlobalFusionRecoveryResult recoveryResult;
  final FusionRecoveryComparativeReport comparativeReport;
  final GlobalFusionSnapshot composedFusionSnapshot;
  final HumanModelSnapshot simulatedHumanModelSnapshot;
  final HumanPatternSnapshot simulatedHumanPatternSnapshot;
}

abstract final class FusionRecoveryRuntimeSimulation {
  static FusionRecoveryRuntimeSimulationResult run({
    required List<KnowMeMirrorSnapshot> mirrorSnapshots,
    required List<String> mirrorRoleIds,
    required GlobalFusionSnapshot foundationSnapshot,
    required HumanModelSnapshot baselineHumanModelSnapshot,
    required HumanPatternSnapshot baselineHumanPatternSnapshot,
    DateTime? generatedAt,
  }) {
    final input = GlobalFusionInput(
      mirrors: [
        for (var i = 0; i < mirrorSnapshots.length; i++)
          GlobalFusionMirrorRef(
            mirrorRoleId: mirrorRoleIds[i],
            snapshot: mirrorSnapshots[i],
          ),
      ],
    );

    final recovery = GlobalFusionCoverageRecoveryBuilder.build(
      input: input,
      foundationSnapshot: foundationSnapshot,
      createdAt: generatedAt,
    );

    final composed = GlobalFusionRecoveryComposer.composeForSimulation(
      input: input,
      recovered: recovery.recoveredSnapshot,
    );

    final afterHuman = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: composed),
      createdAt: generatedAt,
    );
    final afterPattern = HumanPatternSnapshotBuilder.build(
      HumanPatternInput(humanModelSnapshot: afterHuman),
      createdAt: generatedAt,
    );

    final report = FusionRecoveryComparativeReportBuilder.build(
      beforeMirrorThemeCount: _mirrorThemeCount(mirrorSnapshots),
      beforeFusionThemeCount: _fusionThemeCount(foundationSnapshot),
      afterFusionThemeCount: _fusionThemeCount(composed),
      beforeFusionFindings: _findingCount(foundationSnapshot),
      afterFusionFindings: _findingCount(composed),
      beforeHumanMeanings: baselineHumanModelSnapshot.patterns.length,
      afterHumanMeanings: afterHuman.patterns.length,
      beforePatternActivations: baselineHumanPatternSnapshot.activations.length,
      afterPatternActivations: afterPattern.activations.length,
      beforeActivationRate: _activationRate(baselineHumanPatternSnapshot),
      afterActivationRate: _activationRate(afterPattern),
      supplementalFindingCount: recovery.recoveredSnapshot.supplementalFindingCount,
      compressionAudit: recovery.compressionAudit,
    );

    return FusionRecoveryRuntimeSimulationResult(
      recoveryResult: recovery,
      comparativeReport: report,
      composedFusionSnapshot: composed,
      simulatedHumanModelSnapshot: afterHuman,
      simulatedHumanPatternSnapshot: afterPattern,
    );
  }

  static int _mirrorThemeCount(List<KnowMeMirrorSnapshot> snapshots) {
    final themes = <String>{};
    for (final snapshot in snapshots) {
      for (final row in snapshot.evidence) {
        themes.add(row.sourceThemeId);
        themes.addAll(row.themeIds);
      }
    }
    return themes.length;
  }

  static int _fusionThemeCount(GlobalFusionSnapshot snapshot) {
    return snapshot.evidence
        .map((row) => row.sourceThemeId)
        .where((id) => !id.startsWith('fusion_finding:'))
        .toSet()
        .length;
  }

  static int _findingCount(GlobalFusionSnapshot snapshot) {
    return snapshot.agreements.length +
        snapshot.tensions.length +
        snapshot.reinforcements.length +
        snapshot.blindSpots.length;
  }

  static double _activationRate(HumanPatternSnapshot snapshot) {
    final registry = HumanPatternRegistry.allEntries.length;
    if (registry == 0) return 0;
    return snapshot.activations.length / registry;
  }
}
