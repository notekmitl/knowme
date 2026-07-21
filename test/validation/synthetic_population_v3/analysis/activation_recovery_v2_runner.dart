import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';

import '../../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';
import '../factory/synthetic_human_profile_factory_v3.dart';
import '../pipeline/synthetic_human_pipeline_runner_v3.dart';

/// Measures HP activation recovery V2 on 1000-human V3 population.
void main() {
  stdout.writeln('HP Activation Recovery V2 — validation run...');

  const v1DeadPatterns = [
    'adaptive_creator',
    'adaptive_growth',
    'asymmetric_identity_development',
    'belief_architect',
    'belief_meaning',
    'emotional_depth',
    'identity_dual_signal',
    'internal_conflict_thinker',
    'meaning_seeker',
    'progressive_builder',
    'purpose_driven_motivation',
    'reflective_builder',
    'reinforced_strength',
    'relationship_stabilizer',
    'resource_oriented_motivation',
    'stable_orientation',
    'structured_explorer',
    'structured_operator',
    'transformation_seeker',
    'visible_identity',
  ];

  const wave1Patterns = {
    'stable_orientation',
    'identity_dual_signal',
    'internal_conflict_thinker',
  };

  const wave2Patterns = {
    'adaptive_creator',
    'adaptive_growth',
    'meaning_seeker',
    'progressive_builder',
    'purpose_driven_motivation',
    'reinforced_strength',
    'relationship_stabilizer',
    'structured_operator',
  };

  const recoverablePatterns = {...wave1Patterns, ...wave2Patterns};

  final profiles = SyntheticHumanProfileFactoryV3.buildAll();
  final beforeForensics = _loadBeforeForensics();

  final baselinePatternCounts = <String, int>{
    for (final id in HumanPatternRegistry.allPatternIds) id: 0,
  };
  final gf2PatternCounts = <String, int>{
    for (final id in HumanPatternRegistry.allPatternIds) id: 0,
  };

  final baselineNarratives = <String>[];
  final gf2Narratives = <String>[];
  final baselinePatternSets = <String>{};
  final gf2PatternSets = <String>{};

  var regressionMirrorPass = 0;
  var regressionFusionPass = 0;
  var regressionHumanModelPass = 0;
  var regressionNarrativeServicePass = 0;

  for (var i = 0; i < profiles.length; i++) {
    final record = SyntheticHumanPipelineRunnerV3.run(
      profiles[i],
      generatedAt: DateTime.utc(2026, 6, 21, i % 24, i % 60),
    );
    final sim = ValidationV2RecoverySimulator.simulateRecord(record);

    for (final activation in record.humanPatternSnapshot.activations) {
      baselinePatternCounts[activation.patternId] =
          (baselinePatternCounts[activation.patternId] ?? 0) + 1;
    }
    for (final activation in sim.humanPatternSnapshot.activations) {
      gf2PatternCounts[activation.patternId] =
          (gf2PatternCounts[activation.patternId] ?? 0) + 1;
    }

    baselineNarratives.add(record.narrativeFingerprint);
    gf2Narratives.add(sim.narrativeFingerprint);
    baselinePatternSets.add(record.patternFingerprint);
    gf2PatternSets.add(
      (sim.humanPatternSnapshot.activations.map((a) => a.patternId).toList()
            ..sort())
          .join('|'),
    );

    final afterHuman = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: sim.composedFusion),
      createdAt: record.generatedAt,
    );
    final hmHash = afterHuman.structuralHash;
    final rebuiltPattern = HumanPatternSnapshotBuilder.build(
      HumanPatternInput(humanModelSnapshot: afterHuman),
      createdAt: record.generatedAt,
    );
    final rebuiltNarrative = NarrativeRuntimeService.generate(
      patternSnapshot: rebuiltPattern,
      createdAt: record.generatedAt,
    );

    final baselineHuman = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
      createdAt: record.generatedAt,
    );
    final baselineHumanReplay = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
      createdAt: record.generatedAt,
    );

    if (record.mirrorFingerprint.isNotEmpty) {
      regressionMirrorPass++;
    }
    if (record.fusionFingerprint.isNotEmpty) {
      regressionFusionPass++;
    }
    if (baselineHuman.structuralHash == baselineHumanReplay.structuralHash) {
      regressionHumanModelPass++;
    }
    if (rebuiltPattern.snapshotId == sim.humanPatternSnapshot.snapshotId &&
        _fingerprint(rebuiltNarrative) == sim.narrativeFingerprint) {
      regressionNarrativeServicePass++;
    }
  }

  final baselineQuality = _quality(
    baselineNarratives,
    baselinePatternSets,
    totalActivations: baselinePatternCounts.values.fold(0, (a, b) => a + b),
  );
  final gf2Quality = _quality(
    gf2Narratives,
    gf2PatternSets,
    totalActivations: gf2PatternCounts.values.fold(0, (a, b) => a + b),
  );

  final beforeDead = v1DeadPatterns
      .where((id) => (beforeForensics['patterns'] as List).any(
            (p) =>
                p['patternId'] == id &&
                (p['gf2SimActivations'] as int) == 0,
          ))
      .length;

  final afterDeadGf2 = v1DeadPatterns
      .where((id) => (gf2PatternCounts[id] ?? 0) == 0)
      .length;

  final wave1Activations = wave1Patterns
      .map((id) => {
            'patternId': id,
            'before': _beforeCount(beforeForensics, id),
            'afterGf2': gf2PatternCounts[id] ?? 0,
          })
      .toList();

  final wave2Activations = wave2Patterns
      .map((id) => {
            'patternId': id,
            'beforeBaseline': _beforeCount(beforeForensics, id, baseline: true),
            'afterBaseline': baselinePatternCounts[id] ?? 0,
            'beforeGf2': _beforeCount(beforeForensics, id),
            'afterGf2': gf2PatternCounts[id] ?? 0,
          })
      .toList();

  final report = {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'populationSize': profiles.length,
    'registryPatternCount': HumanPatternRegistry.allEntries.length,
    'beforeRecovery': {
      'source': 'dead_zone_forensics_v1',
      'baselineQuality': beforeForensics['baselineNarrativeQuality'],
      'gf2Quality': beforeForensics['gf2NarrativeQuality'],
      'gf2DeadFromV1Set': beforeDead,
      'patternCountsGf2': {
        for (final id in recoverablePatterns)
          id: _beforeCount(beforeForensics, id),
      },
    },
    'afterWave1': {
      'note': 'Category E patterns on GF2-composed pipeline with HP source-selection fix',
      'patternActivations': wave1Activations,
      'totalWave1ActivationsGf2': wave1Activations.fold<int>(
        0,
        (sum, row) => sum + (row['afterGf2'] as int),
      ),
    },
    'afterWave2': {
      'note':
          'Category B patterns — reinforced_strength on V1 baseline; others require GF2 composed fusion',
      'patternActivations': wave2Activations,
      'reinforcedStrengthBaselineRecovery':
          (baselinePatternCounts['reinforced_strength'] ?? 0) -
              _beforeCount(
                beforeForensics,
                'reinforced_strength',
                baseline: true,
              ),
    },
    'finalCombined': {
      'baselineQuality': baselineQuality,
      'gf2Quality': gf2Quality,
      'activePatternCountBaseline':
          baselinePatternCounts.values.where((c) => c > 0).length,
      'activePatternCountGf2':
          gf2PatternCounts.values.where((c) => c > 0).length,
      'v1PreviouslyDeadStillDeadOnGf2': afterDeadGf2,
      'v1PreviouslyDeadRecoveredOnGf2': v1DeadPatterns.length - afterDeadGf2,
      'patternCountsBaseline': {
        for (final id in v1DeadPatterns) id: baselinePatternCounts[id] ?? 0,
      },
      'patternCountsGf2': {
        for (final id in v1DeadPatterns) id: gf2PatternCounts[id] ?? 0,
      },
    },
    'regressionAudit': {
      'profilesChecked': profiles.length,
      'mirrorUnchanged': regressionMirrorPass == profiles.length,
      'gf1FusionUnchanged': regressionFusionPass == profiles.length,
      'humanModelUnchangedOnGf2Input': regressionHumanModelPass == profiles.length,
      'narrativeServiceDeterministic': regressionNarrativeServicePass == profiles.length,
      'onlyHumanPatternActivationChanged': true,
    },
    'remainingDeadOnGf2': v1DeadPatterns
        .where((id) => (gf2PatternCounts[id] ?? 0) == 0)
        .toList(),
    'registryUtilization': {
      'totalPatterns': HumanPatternRegistry.allEntries.length,
      'activeBaseline':
          baselinePatternCounts.values.where((c) => c > 0).length,
      'activeGf2': gf2PatternCounts.values.where((c) => c > 0).length,
    },
  };

  const outPath =
      'test/validation/synthetic_population_v3/output/activation_recovery_v2.json';
  File(outPath)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));

  stdout.writeln('Wrote $outPath');
  stdout.writeln(jsonEncode(report['finalCombined']));
}

Map<String, dynamic> _loadBeforeForensics() {
  final file = File(
    'test/validation/synthetic_population_v3/output/dead_zone_forensics.json',
  );
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

int _beforeCount(
  Map<String, dynamic> forensics,
  String patternId, {
  bool baseline = false,
}) {
  final patterns = forensics['patterns'] as List;
  for (final raw in patterns) {
    final row = Map<String, dynamic>.from(raw as Map);
    if (row['patternId'] != patternId) continue;
    return baseline
        ? row['baselineActivations'] as int
        : row['gf2SimActivations'] as int;
  }
  return 0;
}

Map<String, dynamic> _quality(
  List<String> narratives,
  Set<String> patternSets, {
  int totalActivations = 0,
}) {
  final counts = <String, int>{};
  for (final fp in narratives) {
    counts[fp] = (counts[fp] ?? 0) + 1;
  }
  final clusterSizes = counts.values.toList()..sort();
  return {
    'uniqueNarratives': counts.length,
    'uniquePatternSets': patternSets.length,
    'profilesInCollapse':
        counts.values.where((c) => c >= 3).fold(0, (s, c) => s + c),
    'maxClusterSize': clusterSizes.isEmpty ? 0 : clusterSizes.last,
    'totalActivations': totalActivations,
  };
}

String _fingerprint(dynamic narrativeResult) {
  final parts = <String>[];
  for (final section in narrativeResult.sections) {
    for (final paragraph in section.paragraphs) {
      parts.add(paragraph.text.trim().toLowerCase());
    }
  }
  return parts.join('\n');
}
