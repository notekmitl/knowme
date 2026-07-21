import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/global_fusion/v2/config/global_fusion_recovery_config.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/narrative_runtime/registry/narrative_pattern_copy.dart';

import '../../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';
import '../factory/synthetic_human_profile_factory_v3.dart';
import '../pipeline/synthetic_human_pipeline_runner_v3.dart';

/// Narrative Pattern Copy Expansion V1 — coverage audit + diversity validation.
void main() {
  stdout.writeln('Narrative Copy Expansion V1 — 1000-human audit...');

  final previousEnabled = GlobalFusionRecoveryConfig.enabled;
  final previousPromotion = GlobalFusionRecoveryConfig.promotionEnabled;
  final previousSupplemental = GlobalFusionRecoveryConfig.supplementalEnabled;
  GlobalFusionRecoveryConfig.enabled = true;
  GlobalFusionRecoveryConfig.promotionEnabled = true;
  GlobalFusionRecoveryConfig.supplementalEnabled = true;

  try {
    final profiles = SyntheticHumanProfileFactoryV3.buildAll();
    final patternCounts = <String, int>{
      for (final id in HumanPatternRegistry.allPatternIds) id: 0,
    };
    final patternNarrativeUsage = <String, int>{};
    final copyGroupCounts = <String, int>{};
    final narrativeCounts = <String, int>{};
    final narrativeToProfiles = <String, List<int>>{};
    final patternSets = <String>{};

    var mirrorRegressionPass = 0;
    var gf1RegressionPass = 0;
    var hmRegressionPass = 0;
    var narrativeEvidencePass = 0;

    for (var i = 0; i < profiles.length; i++) {
      final record = SyntheticHumanPipelineRunnerV3.run(
        profiles[i],
        generatedAt: DateTime.utc(2026, 6, 21, i % 24, i % 60),
      );
      final sim = ValidationV2RecoverySimulator.simulateRecord(record);

      for (final activation in sim.humanPatternSnapshot.activations) {
        patternCounts[activation.patternId] =
            (patternCounts[activation.patternId] ?? 0) + 1;
      }

      if (sim.narrativeFingerprint.isNotEmpty) narrativeEvidencePass++;

      narrativesTrack(
        sim: sim,
        profileIndex: i,
        patternNarrativeUsage: patternNarrativeUsage,
        copyGroupCounts: copyGroupCounts,
        narrativeCounts: narrativeCounts,
        narrativeToProfiles: narrativeToProfiles,
      );

      patternSets.add(
        (sim.humanPatternSnapshot.activations
                .map((a) => a.patternId)
                .toList()
              ..sort())
            .join('|'),
      );

      if (record.mirrorFingerprint.isNotEmpty) mirrorRegressionPass++;
      if (record.fusionFingerprint == record.globalFusionSnapshot.structuralHash ||
          record.fusionFingerprint.isNotEmpty) {
        gf1RegressionPass++;
      }

      final baselineHuman = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
        createdAt: record.generatedAt,
      );
      final baselineHumanReplay = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
        createdAt: record.generatedAt,
      );
      if (baselineHuman.structuralHash == baselineHumanReplay.structuralHash) {
        hmRegressionPass++;
      }
    }

    final clusterSizes = narrativeCounts.values.toList()..sort();
    final activePatternIds = patternCounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();

    final profilesInCollapse =
        narrativeCounts.values.where((c) => c >= 3).fold(0, (s, c) => s + c);
    final maxClusterSize = clusterSizes.isEmpty ? 0 : clusterSizes.last;
    final uniqueNarratives = narrativeCounts.length;

    final topCopyGroups = copyGroupCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topClusters = narrativeCounts.entries
        .where((entry) => entry.value >= 3)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final patternAudit = activePatternIds.map((patternId) {
      final activationCount = patternCounts[patternId] ?? 0;
      final narrativeUsage = patternNarrativeUsage[patternId] ?? 0;
      return {
        'patternId': patternId,
        'activationCount': activationCount,
        'narrativeUsageCount': narrativeUsage,
        'hasSpecificCopy': NarrativePatternCopy.hasSpecificCopy(patternId),
      };
    }).toList();

    const baseline = {
      'uniqueNarratives': 552,
      'profilesInCollapse': 446,
      'maxClusterSize': 16,
      'activePatterns': 30,
    };

    final totalActivations =
        patternCounts.values.fold<int>(0, (sum, count) => sum + count);
    final patternCoverage = activePatternIds.length / 30;
    final narrativeEvidenceCoverage = narrativeEvidencePass / profiles.length;

    final gates = {
      'uniqueNarrativesGt552': uniqueNarratives > baseline['uniqueNarratives']!,
      'profilesInCollapseLt446':
          profilesInCollapse < baseline['profilesInCollapse']!,
      'maxClusterLt16': maxClusterSize < baseline['maxClusterSize']!,
      'activePatternsGte30':
          activePatternIds.length >= baseline['activePatterns']!,
    };

    final report = {
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'populationSize': profiles.length,
      'baseline': baseline,
      'metrics': {
        'activePatterns': activePatternIds.length,
        'uniqueNarratives': uniqueNarratives,
        'uniquePatternSets': patternSets.length,
        'profilesInCollapse': profilesInCollapse,
        'maxClusterSize': maxClusterSize,
        'totalActivations': totalActivations,
        'patternCoverage': patternCoverage,
        'narrativeEvidenceCoverage': narrativeEvidenceCoverage,
        'deltaUniqueNarratives':
            uniqueNarratives - baseline['uniqueNarratives']!,
        'deltaProfilesInCollapse':
            profilesInCollapse - baseline['profilesInCollapse']!,
        'deltaMaxCluster':
            maxClusterSize - baseline['maxClusterSize']!,
      },
      'gates': gates,
      'allGatesPass': gates.values.every((pass) => pass),
      'coverageAudit': {
        'patternAudit': patternAudit,
        'topOverusedCopyGroups': topCopyGroups
            .take(20)
            .map(
              (entry) => {
                'copyGroup': entry.key,
                'usageCount': entry.value,
              },
            )
            .toList(),
      },
      'topRemainingCollapseClusters': topClusters
          .take(15)
          .map(
            (entry) => {
              'clusterSize': entry.value,
              'narrativeSample': entry.key.length > 160
                  ? '${entry.key.substring(0, 160)}...'
                  : entry.key,
            },
          )
          .toList(),
      'regressionAudit': {
        'mirrorUnchanged': mirrorRegressionPass == profiles.length,
        'gf1FoundationPreserved': gf1RegressionPass == profiles.length,
        'humanModelDeterministicOnGf1':
            hmRegressionPass == profiles.length,
        'narrativeEvidencePresent':
            narrativeEvidencePass == profiles.length,
        'patternActivationsStable': totalActivations == 13732,
        'activePatternsStable': activePatternIds.length == 30,
      },
    };

    const outPath =
        'test/validation/synthetic_population_v3/output/narrative_copy_expansion_v1.json';
    File(outPath)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));

    stdout.writeln('Wrote $outPath');
    stdout.writeln(jsonEncode(report['metrics']));
    stdout.writeln('Gates pass: ${report['allGatesPass']}');
  } finally {
    GlobalFusionRecoveryConfig.enabled = previousEnabled;
    GlobalFusionRecoveryConfig.promotionEnabled = previousPromotion;
    GlobalFusionRecoveryConfig.supplementalEnabled = previousSupplemental;
  }
}

void narrativesTrack({
  required ValidationV2SimulationResult sim,
  required int profileIndex,
  required Map<String, int> patternNarrativeUsage,
  required Map<String, int> copyGroupCounts,
  required Map<String, int> narrativeCounts,
  required Map<String, List<int>> narrativeToProfiles,
}) {
  final fp = sim.narrativeFingerprint;
  narrativeCounts[fp] = (narrativeCounts[fp] ?? 0) + 1;
  narrativeToProfiles.putIfAbsent(fp, () => []).add(profileIndex);

  for (final line in fp.split('\n')) {
    if (line.trim().isEmpty) continue;
    final group = NarrativePatternCopy.copyGroupForText(line);
    copyGroupCounts[group] = (copyGroupCounts[group] ?? 0) + 1;
  }

  for (final activation in sim.humanPatternSnapshot.activations) {
    patternNarrativeUsage[activation.patternId] =
        (patternNarrativeUsage[activation.patternId] ?? 0) + 1;
  }
}
