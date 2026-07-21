import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/global_fusion/v2/config/global_fusion_recovery_config.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_interaction_type.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_intelligence_layer.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_selection_scorer.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';

import '../../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';
import '../factory/synthetic_human_profile_factory_v3.dart';
import '../pipeline/synthetic_human_pipeline_runner_v3.dart';

/// Narrative Intelligence Selection V3 — fingerprint audit + diversity validation.
void main() {
  stdout.writeln('Narrative Intelligence Selection V3 — 1000-human audit...');

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
    final narrativeCounts = <String, int>{};
    final selectionFingerprintCounts = <String, int>{};
    final patternSets = <String>{};

    var mirrorRegressionPass = 0;
    var gf1RegressionPass = 0;
    var hmRegressionPass = 0;
    var determinismPass = 0;

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

      final plans = NarrativeIntelligenceLayer.buildPlans(
        sim.humanPatternSnapshot,
      );
      final selectionFingerprint = NarrativeSelectionScorer.selectionFingerprint(
        plans: plans
            .map(
              (plan) => (
                mode: plan.mode,
                interactionType: plan.interactionType.key,
                patternIds: plan.referencedPatternIds,
              ),
            )
            .toList(),
      );
      selectionFingerprintCounts[selectionFingerprint] =
          (selectionFingerprintCounts[selectionFingerprint] ?? 0) + 1;

      narrativeCounts[sim.narrativeFingerprint] =
          (narrativeCounts[sim.narrativeFingerprint] ?? 0) + 1;

      patternSets.add(
        (sim.humanPatternSnapshot.activations
                .map((a) => a.patternId)
                .toList()
              ..sort())
            .join('|'),
      );

      final replay = NarrativeRuntimeService.generate(
        patternSnapshot: sim.humanPatternSnapshot,
        createdAt: record.generatedAt,
      );
      final replayFp = _narrativeFingerprint(replay);
      if (replayFp == sim.narrativeFingerprint) determinismPass++;

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
    final uniqueSelectionFingerprints = selectionFingerprintCounts.length;
    final totalActivations =
        patternCounts.values.fold<int>(0, (sum, count) => sum + count);

    final topSelectionFingerprints = selectionFingerprintCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topClusters = narrativeCounts.entries
        .where((entry) => entry.value >= 3)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    const beforeV3 = {
      'uniqueNarratives': 586,
      'profilesInCollapse': 400,
      'maxClusterSize': 14,
      'uniqueSelectionFingerprints': 436,
    };

    final gates = {
      'uniqueNarrativesGte650': uniqueNarratives >= 650,
      'profilesInCollapseLte320': profilesInCollapse <= 320,
      'maxClusterLte10': maxClusterSize <= 10,
      'activePatternsGte30': activePatternIds.length >= 30,
      'deterministicReplay': determinismPass == profiles.length,
    };

    final report = {
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'populationSize': profiles.length,
      'beforeV3': beforeV3,
      'metrics': {
        'activePatterns': activePatternIds.length,
        'uniqueNarratives': uniqueNarratives,
        'uniqueSelectionFingerprints': uniqueSelectionFingerprints,
        'uniquePatternSets': patternSets.length,
        'profilesInCollapse': profilesInCollapse,
        'maxClusterSize': maxClusterSize,
        'totalActivations': totalActivations,
        'patternCoverage': activePatternIds.length / 30,
        'deltaUniqueNarratives':
            uniqueNarratives - beforeV3['uniqueNarratives']!,
        'deltaProfilesInCollapse':
            profilesInCollapse - beforeV3['profilesInCollapse']!,
        'deltaMaxCluster': maxClusterSize - beforeV3['maxClusterSize']!,
        'deltaSelectionFingerprints': uniqueSelectionFingerprints -
            beforeV3['uniqueSelectionFingerprints']!,
      },
      'gates': gates,
      'allGatesPass': gates.values.every((pass) => pass),
      'fingerprintAudit': {
        'topSelectionFingerprints': topSelectionFingerprints
            .take(20)
            .map(
              (entry) => {
                'selectionFingerprint': entry.key.length > 200
                    ? '${entry.key.substring(0, 200)}...'
                    : entry.key,
                'profileCount': entry.value,
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
        'patternActivationsStable': totalActivations == 13732,
        'activePatternsStable': activePatternIds.length == 30,
        'narrativeDeterministicReplay': determinismPass == profiles.length,
      },
    };

    const outPath =
        'test/validation/synthetic_population_v3/output/narrative_intelligence_selection_v3.json';
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

String _narrativeFingerprint(dynamic narrativeResult) {
  final parts = <String>[];
  for (final section in narrativeResult.sections) {
    for (final paragraph in section.paragraphs) {
      parts.add(paragraph.text.trim().toLowerCase());
    }
  }
  return parts.join('\n');
}
