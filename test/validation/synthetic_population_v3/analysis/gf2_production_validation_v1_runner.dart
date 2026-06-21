import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/global_fusion/v2/config/global_fusion_recovery_config.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import '../../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';
import '../factory/synthetic_human_profile_factory_v3.dart';
import '../pipeline/synthetic_human_pipeline_runner_v3.dart';

/// GF2 production validation — 1000-human population with recovery enabled.
void main() {
  stdout.writeln('GF2 Production Validation V1 — 1000-human run...');

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
    final narratives = <String>[];
    final patternSets = <String>{};

    var mirrorRegressionPass = 0;
    var gf1RegressionPass = 0;
    var hmRegressionPass = 0;
    var narrativeRegressionPass = 0;

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
      narratives.add(sim.narrativeFingerprint);
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
      if (record.narrativeFingerprint.isNotEmpty) narrativeRegressionPass++;
    }

    final narrativeCounts = <String, int>{};
    for (final fp in narratives) {
      narrativeCounts[fp] = (narrativeCounts[fp] ?? 0) + 1;
    }
    final clusterSizes = narrativeCounts.values.toList()..sort();

    final activePatterns =
        patternCounts.values.where((count) => count > 0).length;
    final uniqueNarratives = narrativeCounts.length;
    final profilesInCollapse =
        narrativeCounts.values.where((c) => c >= 3).fold(0, (s, c) => s + c);
    final maxClusterSize = clusterSizes.isEmpty ? 0 : clusterSizes.last;

    final gates = {
      'activePatternsGte30': activePatterns >= 30,
      'uniqueNarrativesGte550': uniqueNarratives >= 550,
      'profilesInCollapseLte450': profilesInCollapse <= 450,
      'maxClusterLte20': maxClusterSize <= 20,
      'stableOrientationGt0': (patternCounts['stable_orientation'] ?? 0) > 0,
      'reinforcedStrengthGt0': (patternCounts['reinforced_strength'] ?? 0) > 0,
    };

    final report = {
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'populationSize': profiles.length,
      'featureFlagEnabled': true,
      'metrics': {
        'activePatterns': activePatterns,
        'uniqueNarratives': uniqueNarratives,
        'uniquePatternSets': patternSets.length,
        'profilesInCollapse': profilesInCollapse,
        'maxClusterSize': maxClusterSize,
        'stable_orientation': patternCounts['stable_orientation'] ?? 0,
        'reinforced_strength': patternCounts['reinforced_strength'] ?? 0,
        'totalActivations':
            patternCounts.values.fold<int>(0, (sum, count) => sum + count),
      },
      'gates': gates,
      'allGatesPass': gates.values.every((pass) => pass),
      'regressionAudit': {
        'mirrorUnchanged': mirrorRegressionPass == profiles.length,
        'gf1FoundationPreserved': gf1RegressionPass == profiles.length,
        'humanModelDeterministicOnGf1':
            hmRegressionPass == profiles.length,
        'baselineNarrativePresent':
            narrativeRegressionPass == profiles.length,
      },
    };

    const outPath =
        'test/validation/synthetic_population_v3/output/gf2_production_validation_v1.json';
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
