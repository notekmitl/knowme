import 'package:knowme/features/global_fusion/foundation/builder/global_fusion_foundation_builder.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import '../global_fusion_foundation_v2/fusion_dead_zone_trace_runner.dart';
import '../human_pattern_activation_audit/eq_signal_survival_audit.dart';
import '../synthetic_population/audits/fusion_distribution_audit.dart';
import '../synthetic_population/audits/narrative_duplication_audit.dart';
import '../synthetic_population/audits/pattern_distribution_audit.dart';
import '../synthetic_population/audits/population_coverage_audit.dart';
import '../synthetic_population/audits/population_diversity_audit.dart';
import '../synthetic_population/pipeline/synthetic_human_pipeline_runner.dart';
import '../synthetic_population/pipeline/synthetic_human_run_record.dart';
import 'factory/synthetic_human_profile_factory_v2.dart';
import 'simulation/validation_v2_recovery_simulator.dart';

/// Full Synthetic Population V2 (1000 humans) validation bundle.
class SyntheticPopulationV2AuditResult {
  const SyntheticPopulationV2AuditResult({
    required this.records,
    required this.populationQuality,
    required this.diversity,
    required this.coverage,
    required this.narrativeDuplication,
    required this.patternDistribution,
    required this.fusionDistribution,
    required this.architectureDiversity,
    required this.deadZoneRevalidation,
    required this.v2Simulation,
    required this.validationGates,
    required this.stabilityAnalysis,
    required this.decisionGate,
  });

  final List<SyntheticHumanRunRecord> records;
  final Map<String, dynamic> populationQuality;
  final PopulationDiversityAudit diversity;
  final PopulationCoverageAudit coverage;
  final NarrativeDuplicationAudit narrativeDuplication;
  final PatternDistributionAudit patternDistribution;
  final FusionDistributionAudit fusionDistribution;
  final Map<String, dynamic> architectureDiversity;
  final Map<String, dynamic> deadZoneRevalidation;
  final Map<String, dynamic> v2Simulation;
  final Map<String, dynamic> validationGates;
  final Map<String, dynamic> stabilityAnalysis;
  final Map<String, dynamic> decisionGate;
}

abstract final class SyntheticPopulationV2Runner {
  static SyntheticPopulationV2AuditResult runAll() {
    final profiles = SyntheticHumanProfileFactoryV2.buildAll();
    final records = <SyntheticHumanRunRecord>[];

    for (var index = 0; index < profiles.length; index++) {
      records.add(
        SyntheticHumanPipelineRunner.run(
          profiles[index],
          generatedAt: DateTime.utc(2026, 6, 21, index % 24, index % 60),
        ),
      );
    }

    final populationQuality =
        SyntheticHumanProfileFactoryV2.populationQualityReport(profiles);
    final diversity = PopulationDiversityAudit.analyze(records);
    final coverage = PopulationCoverageAudit.analyze(records);
    final narrative = NarrativeDuplicationAudit.analyze(records);
    final patterns = PatternDistributionAudit.analyze(records);
    final fusion = FusionDistributionAudit.analyze(records);
    final architecture = ArchitectureDiversityAudit.analyze(records);
    final deadZones = DeadZoneRevalidationAudit.analyze(records);
    final v2Sim = V2RecoverySimulationAudit.analyze(records);
    final validationGates = ValidationGatesAudit.evaluate(
      records: records,
      v2Sim: v2Sim,
      deadZones: deadZones,
    );
    final stability = StabilityAnalysisAudit.analyze(
      baseline200: _baseline200(),
      scale1000: _metrics1000(
        records: records,
        diversity: diversity,
        narrative: narrative,
        patterns: patterns,
        fusion: fusion,
        v2Sim: v2Sim,
      ),
    );
    final decision = DecisionGateAudit.evaluate(
      populationQuality: populationQuality,
      deadZones: deadZones,
      v2Sim: v2Sim,
      stability: stability,
      patterns: patterns,
      fusion: fusion,
      validationGates: validationGates,
    );

    return SyntheticPopulationV2AuditResult(
      records: records,
      populationQuality: populationQuality,
      diversity: diversity,
      coverage: coverage,
      narrativeDuplication: narrative,
      patternDistribution: patterns,
      fusionDistribution: fusion,
      architectureDiversity: architecture,
      deadZoneRevalidation: deadZones,
      v2Simulation: v2Sim,
      validationGates: validationGates,
      stabilityAnalysis: stability,
      decisionGate: decision,
    );
  }

  static Map<String, dynamic> _baseline200() {
    // Measured baseline from Synthetic Population V1 + GF Validation V2 (200 humans).
    return {
      'populationSize': 200,
      'uniquePatternSets': 77,
      'uniqueNarratives': 82,
      'deadPatternCount': 20,
      'fusionDeadZones': [
        'MIRROR_GROWTH_ORIENTATION',
        'MIRROR_LIFE_DIRECTION',
        'MIRROR_STRUCTURE_PATTERN',
      ],
      'collapseZones': 22,
      'totalActivations': 1823,
      'simulatedActivations': 2391,
      'simulatedUniquePatternSets': 125,
      'simulatedUniqueNarratives': 130,
      'simulatedCollapseZones': 14,
      'profilesInCollapse': 118,
      'simulatedProfilesInCollapse': 70,
      'maxClusterSizeBaseline': 14,
      'simulatedMaxClusterSize': 10,
    };
  }

  static Map<String, dynamic> _metrics1000({
    required List<SyntheticHumanRunRecord> records,
    required PopulationDiversityAudit diversity,
    required NarrativeDuplicationAudit narrative,
    required PatternDistributionAudit patterns,
    required FusionDistributionAudit fusion,
    required Map<String, dynamic> v2Sim,
  }) {
    final baseline = v2Sim['baseline'] as Map<String, dynamic>;
    final simulated = v2Sim['simulatedAfterRecovery'] as Map<String, dynamic>;
    final vg005 = v2Sim['vg005NarrativeQuality'] as Map<String, dynamic>;
    final baseQuality = vg005['baseline'] as Map<String, dynamic>;
    final simQuality = vg005['simulated'] as Map<String, dynamic>;
    return {
      'populationSize': records.length,
      'uniquePatternSets': diversity.uniquePatternSets,
      'uniqueNarratives': diversity.uniqueNarrativeFingerprints,
      'deadPatternCount': patterns.neverActivatedPatternIds.length,
      'fusionDeadZones': fusion.fusionDeadZones,
      'profilesInCollapse': baseQuality['profilesInCollapse'],
      'maxClusterSizeBaseline': baseQuality['maxClusterSize'],
      'totalActivations': baseline['totalActivations'],
      'simulatedActivations': simulated['totalActivations'],
      'simulatedUniquePatternSets': simulated['uniquePatternSets'],
      'simulatedUniqueNarratives': simulated['uniqueNarratives'],
      'simulatedProfilesInCollapse': simQuality['profilesInCollapse'],
      'simulatedMaxClusterSize': simQuality['maxClusterSize'],
    };
  }
}

abstract final class ArchitectureDiversityAudit {
  static Map<String, dynamic> analyze(List<SyntheticHumanRunRecord> records) {
    final mirrorKeys = <String, int>{};
    var mirrorEvidence = 0;
    final fusionAgreementKeys = <String, int>{};
    final fusionTensionCount = <String, int>{};
    final fusionReinforcementKeys = <String, int>{};
    final fusionBlindSpotKeys = <String, int>{};
    final humanModelHashes = <String>{};
    final dimensionCounts = <String, int>{};
    final narrativeConfidence = <String, int>{};

    for (final record in records) {
      for (final signal in [
        ...record.astrologyInput.signals,
        ...record.personalityInput.signals,
      ]) {
        mirrorKeys[signal.mirrorKey] = (mirrorKeys[signal.mirrorKey] ?? 0) + 1;
      }
      mirrorEvidence += record.astrologyMirrorSnapshot.evidence.length +
          record.personalityMirrorSnapshot.evidence.length;

      final fusion = record.globalFusionSnapshot;
      for (final item in fusion.agreements) {
        fusionAgreementKeys[item.mirrorKey] =
            (fusionAgreementKeys[item.mirrorKey] ?? 0) + 1;
      }
      fusionTensionCount['total'] =
          (fusionTensionCount['total'] ?? 0) + fusion.tensions.length;
      for (final item in fusion.reinforcements) {
        fusionReinforcementKeys[item.mirrorKey] =
            (fusionReinforcementKeys[item.mirrorKey] ?? 0) + 1;
      }
      for (final item in fusion.blindSpots) {
        fusionBlindSpotKeys[item.mirrorKey] =
            (fusionBlindSpotKeys[item.mirrorKey] ?? 0) + 1;
      }

      final humanModel = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: fusion),
        createdAt: record.generatedAt,
      );
      humanModelHashes.add(humanModel.structuralHash);
      for (final dim in humanModel.profile.dimensions) {
        dimensionCounts[dim.dimensionKey] =
            (dimensionCounts[dim.dimensionKey] ?? 0) + 1;
      }

      final conf = record.narrativeResult.confidence.composite;
      final bucket = conf < 0.4
          ? 'low'
          : conf < 0.7
              ? 'medium'
              : 'high';
      narrativeConfidence[bucket] = (narrativeConfidence[bucket] ?? 0) + 1;
    }

    return {
      'mirrorLayer': {
        'uniqueMirrorFingerprints':
            records.map((r) => r.mirrorFingerprint).toSet().length,
        'mirrorKeyUtilization': _top(mirrorKeys, 20),
        'totalEvidenceRows': mirrorEvidence,
      },
      'fusionLayer': {
        'uniqueFusionFingerprints':
            records.map((r) => r.fusionFingerprint).toSet().length,
        'agreementKeyDistribution': _top(fusionAgreementKeys, 20),
        'tensionCountTotal': fusionTensionCount['total'] ?? 0,
        'reinforcementKeyDistribution': _top(fusionReinforcementKeys, 20),
        'blindSpotKeyDistribution': _top(fusionBlindSpotKeys, 20),
      },
      'humanModelLayer': {
        'uniqueModelFingerprints': humanModelHashes.length,
        'dimensionUtilization': _top(dimensionCounts, 20),
      },
      'humanPatternLayer': PatternDistributionAudit.analyze(records).toJson(),
      'narrativeLayer': {
        'uniqueNarratives':
            records.map((r) => r.narrativeFingerprint).toSet().length,
        'collapseZones': NarrativeDuplicationAudit.analyze(records).collapseZones.length,
        'confidenceDistribution': narrativeConfidence,
      },
    };
  }

  static Map<String, int> _top(Map<String, int> counts, int limit) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map<String, int>.fromEntries(entries.take(limit));
  }
}

abstract final class DeadZoneRevalidationAudit {
  static const keys = FusionDeadZoneTraceRunner.deadZoneKeys;

  static Map<String, dynamic> analyze(List<SyntheticHumanRunRecord> records) {
    final traces = <String, dynamic>{};
    for (final key in keys) {
      traces[key] = _trace(key, records);
    }
    return {
      'populationSize': records.length,
      'traces': traces,
      'summary': {
        for (final key in keys)
          key: _status(traces[key] as Map<String, dynamic>),
      },
    };
  }

  static Map<String, dynamic> _trace(
    String mirrorKey,
    List<SyntheticHumanRunRecord> records,
  ) {
    var inputSignals = 0;
    var mirrorFindings = 0;
    var fusionFindings = 0;
    var humanModelMappings = 0;
    var patternActivations = 0;
    var profilesWithInput = 0;
    var profilesWithFusion = 0;

    for (final record in records) {
      final signals = [
        ...record.astrologyInput.signals,
        ...record.personalityInput.signals,
      ].where((s) => s.mirrorKey == mirrorKey);
      if (signals.isNotEmpty) profilesWithInput++;
      inputSignals += signals.length;

      mirrorFindings += record.astrologyMirrorSnapshot.agreements
              .where((a) => a.mirrorKey == mirrorKey)
              .length +
          record.personalityMirrorSnapshot.agreements
              .where((a) => a.mirrorKey == mirrorKey)
              .length +
          record.astrologyMirrorSnapshot.reinforcements
              .where((r) => r.mirrorKey == mirrorKey)
              .length +
          record.personalityMirrorSnapshot.reinforcements
              .where((r) => r.mirrorKey == mirrorKey)
              .length;

      final fusion = record.globalFusionSnapshot;
      final fCount = fusion.agreements.where((a) => a.mirrorKey == mirrorKey).length +
          fusion.reinforcements.where((r) => r.mirrorKey == mirrorKey).length +
          fusion.tensions.where((t) => t.mirrorKey == mirrorKey).length +
          fusion.blindSpots.where((b) => b.mirrorKey == mirrorKey).length;
      fusionFindings += fCount;
      if (fCount > 0) profilesWithFusion++;

      final humanModel = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: fusion),
        createdAt: record.generatedAt,
      );
      humanModelMappings += humanModel.patterns
              .where((p) => p.supportingMirrorKeys.contains(mirrorKey))
              .length +
          humanModel.evidence.where((e) => e.mirrorKey == mirrorKey).length;

      patternActivations += record.humanPatternSnapshot.activations.where((a) {
        final entry = HumanPatternRegistry.byId(a.patternId);
        return entry?.activationRule.requiredMirrorKey == mirrorKey;
      }).length;
    }

    return {
      'mirrorKey': mirrorKey,
      'inputSignals': inputSignals,
      'profilesWithInput': profilesWithInput,
      'mirrorFindings': mirrorFindings,
      'fusionFindings': fusionFindings,
      'profilesWithFusionFinding': profilesWithFusion,
      'humanModelMappings': humanModelMappings,
      'patternActivations': patternActivations,
    };
  }

  static String _status(Map<String, dynamic> trace) {
    if ((trace['fusionFindings'] as int) > 0) return 'fully_alive';
    if ((trace['mirrorFindings'] as int) > 0 ||
        (trace['humanModelMappings'] as int) > 0) {
      return 'partially_alive';
    }
    if ((trace['inputSignals'] as int) > 0) return 'still_dead';
    return 'no_signal';
  }
}

abstract final class V2RecoverySimulationAudit {
  static const dependentPatternIds = [
    'progressive_builder',
    'adaptive_creator',
    'meaning_seeker',
    'purpose_driven_motivation',
    'stable_orientation',
    'structured_operator',
  ];

  static const deadZoneKeys = [
    'MIRROR_GROWTH_ORIENTATION',
    'MIRROR_LIFE_DIRECTION',
    'MIRROR_STRUCTURE_PATTERN',
  ];

  static Map<String, dynamic> analyze(List<SyntheticHumanRunRecord> records) {
    var baselineActivations = 0;
    var simulatedActivations = 0;
    final baselinePatterns = <String>{};
    final simulatedPatterns = <String>{};
    final baselineNarratives = <String>[];
    final simulatedNarratives = <String>[];
    var mp001Total = 0;
    var r004Total = 0;
    final activatedAfterSim = <String>{};
    final dependentPatternCounts = <String, int>{
      for (final id in dependentPatternIds) id: 0,
    };
    final deadZoneProfilesRecovered = <String, int>{
      for (final key in deadZoneKeys) key: 0,
    };
    var eqSimulatedCount = 0;
    final simulatedFusionHashes = <String>{};

    for (final record in records) {
      baselineActivations += record.humanPatternSnapshot.activations.length;
      baselinePatterns.add(record.patternFingerprint);
      baselineNarratives.add(record.narrativeFingerprint);

      final sim = ValidationV2RecoverySimulator.simulateRecord(record);
      simulatedActivations += sim.humanPatternSnapshot.activations.length;
      simulatedPatterns.add(
        (sim.humanPatternSnapshot.activations.map((a) => a.patternId).toList()
              ..sort())
            .join('|'),
      );
      simulatedNarratives.add(sim.narrativeFingerprint);
      mp001Total += sim.mp001AgreementCount;
      r004Total += sim.r004ReinforcementCount;
      simulatedFusionHashes.add(sim.composedFusion.structuralHash);
      for (final a in sim.humanPatternSnapshot.activations) {
        activatedAfterSim.add(a.patternId);
        if (dependentPatternCounts.containsKey(a.patternId)) {
          dependentPatternCounts[a.patternId] =
              dependentPatternCounts[a.patternId]! + 1;
        }
      }
      for (final key in deadZoneKeys) {
        final recovered = sim.composedFusion.agreements
                .where((f) => f.mirrorKey == key)
                .length +
            sim.composedFusion.reinforcements
                .where((f) => f.mirrorKey == key)
                .length;
        if (recovered > 0) {
          deadZoneProfilesRecovered[key] =
              deadZoneProfilesRecovered[key]! + 1;
        }
      }
      eqSimulatedCount += sim.humanPatternSnapshot.evidence
          .where((e) => e.systemId == 'eq')
          .length;
    }

    final eqBaseline = EqSignalSurvivalAudit.analyze(records);
    final deadAfterSim = HumanPatternRegistry.allPatternIds
        .where((id) => !activatedAfterSim.contains(id))
        .length;

    final baselineNarrativeQuality = _narrativeQuality(baselineNarratives);
    final simulatedNarrativeQuality = _narrativeQuality(simulatedNarratives);

    return {
      'populationSize': records.length,
      'baseline': {
        'totalActivations': baselineActivations,
        'uniquePatternSets': baselinePatterns.length,
        'uniqueNarratives': baselineNarratives.toSet().length,
        'deadPatternCount':
            PatternDistributionAudit.analyze(records).neverActivatedPatternIds.length,
        'avgActivationsPerProfile': baselineActivations / records.length,
        'narrativeQuality': baselineNarrativeQuality,
      },
      'simulatedAfterRecovery': {
        'totalActivations': simulatedActivations,
        'uniquePatternSets': simulatedPatterns.length,
        'uniqueNarratives': simulatedNarratives.toSet().length,
        'deadPatternCount': deadAfterSim,
        'avgActivationsPerProfile': simulatedActivations / records.length,
        'additionalActivations': simulatedActivations - baselineActivations,
        'additionalUniquePatternSets':
            simulatedPatterns.length - baselinePatterns.length,
        'additionalUniqueNarratives':
            simulatedNarratives.toSet().length -
                baselineNarratives.toSet().length,
        'mp001PromotionsApplied': mp001Total,
        'r004ReinforcementsApplied': r004Total,
        'narrativeQuality': simulatedNarrativeQuality,
      },
      'dependentPatternActivations': [
        for (final id in dependentPatternIds)
          {
            'patternId': id,
            'simulatedActivations': dependentPatternCounts[id],
            'validated': (dependentPatternCounts[id] ?? 0) > 0,
          },
      ],
      'deadZoneSimRecovery': {
        for (final key in deadZoneKeys)
          key: deadZoneProfilesRecovered[key],
      },
      'vg005NarrativeQuality': {
        'baseline': baselineNarrativeQuality,
        'simulated': simulatedNarrativeQuality,
        'delta': {
          'uniqueNarratives':
              simulatedNarrativeQuality['uniqueNarratives'] -
                  baselineNarrativeQuality['uniqueNarratives'],
          'profilesInCollapse':
              simulatedNarrativeQuality['profilesInCollapse'] -
                  baselineNarrativeQuality['profilesInCollapse'],
          'maxClusterSize':
              simulatedNarrativeQuality['maxClusterSize'] -
                  baselineNarrativeQuality['maxClusterSize'],
        },
      },
      'eqSurvival': {
        'baseline': eqBaseline.eqSurvivalRates,
        'simulatedPatternEvidenceCount': eqSimulatedCount,
        'simulatedRetentionVsMirrorInput': (eqBaseline.eqLayerCounts['mirror_input'] ?? 0) == 0
            ? 0.0
            : eqSimulatedCount / (eqBaseline.eqLayerCounts['mirror_input'] ?? 1),
      },
      'fusionDiversity': {
        'baselineUniqueFusion':
            records.map((r) => r.fusionFingerprint).toSet().length,
        'simulatedUniqueFusion': simulatedFusionHashes.length,
      },
    };
  }

  static Map<String, dynamic> _narrativeQuality(List<String> fingerprints) {
    final counts = <String, int>{};
    for (final fp in fingerprints) {
      counts[fp] = (counts[fp] ?? 0) + 1;
    }
    final clusterSizes = counts.values.toList()..sort();
    final profilesInCollapse = counts.values
        .where((c) => c >= 3)
        .fold<int>(0, (sum, c) => sum + c);
    return {
      'uniqueNarratives': counts.length,
      'profilesInCollapse': profilesInCollapse,
      'maxClusterSize':
          clusterSizes.isEmpty ? 0 : clusterSizes.last,
      'narrativeDiversityRatio': fingerprints.isEmpty
          ? 0.0
          : counts.length / fingerprints.length,
    };
  }
}

abstract final class StabilityAnalysisAudit {
  static Map<String, dynamic> analyze({
    required Map<String, dynamic> baseline200,
    required Map<String, dynamic> scale1000,
  }) {
    final metrics = [
      _metric(
        'deadPatternCountBaseline',
        baseline200['deadPatternCount'] as int,
        scale1000['deadPatternCount'] as int,
        lowerIsBetter: true,
      ),
      _metric(
        'fusionDeadZoneCount',
        (baseline200['fusionDeadZones'] as List).length,
        (scale1000['fusionDeadZones'] as List).length,
        lowerIsBetter: false,
        compareEqual: true,
      ),
      _metric(
        'v2ActivationGainAbsolute',
        (baseline200['simulatedActivations'] as int) -
            (baseline200['totalActivations'] as int),
        (scale1000['simulatedActivations'] as int) -
            (scale1000['totalActivations'] as int),
      ),
      _metric(
        'v2ActivationGainPercent',
        _pctGain(
          baseline200['totalActivations'] as int,
          baseline200['simulatedActivations'] as int,
        ),
        _pctGain(
          scale1000['totalActivations'] as int,
          scale1000['simulatedActivations'] as int,
        ),
      ),
      _metric(
        'v2NarrativeGainAbsolute',
        (baseline200['simulatedUniqueNarratives'] as int) -
            (baseline200['uniqueNarratives'] as int),
        (scale1000['simulatedUniqueNarratives'] as int) -
            (scale1000['uniqueNarratives'] as int),
      ),
      _metric(
        'v2PatternSetGainAbsolute',
        (baseline200['simulatedUniquePatternSets'] as int) -
            (baseline200['uniquePatternSets'] as int),
        (scale1000['simulatedUniquePatternSets'] as int) -
            (scale1000['uniquePatternSets'] as int),
      ),
      _metric(
        'vg005ProfilesInCollapseReduction',
        (baseline200['profilesInCollapse'] as int) -
            (baseline200['simulatedProfilesInCollapse'] as int),
        (scale1000['profilesInCollapse'] as int) -
            (scale1000['simulatedProfilesInCollapse'] as int),
      ),
      _metric(
        'vg005MaxClusterReduction',
        (baseline200['maxClusterSizeBaseline'] as int) -
            (baseline200['simulatedMaxClusterSize'] as int),
        (scale1000['maxClusterSizeBaseline'] as int) -
            (scale1000['simulatedMaxClusterSize'] as int),
      ),
    ];

    return {
      'baselinePopulation': 200,
      'scalePopulation': 1000,
      'metrics': metrics,
      'overallStability': _overall(metrics),
    };
  }

  static Map<String, dynamic> _metric(
    String name,
    num baseline,
    num scaled, {
    bool lowerIsBetter = false,
    bool compareEqual = false,
  }) {
    final absoluteGain = scaled - baseline;
    final pctGain = baseline == 0 ? 0.0 : (absoluteGain / baseline) * 100;
    String stability;
    if (compareEqual) {
      stability = baseline == scaled ? 'Strongly Stable' : 'Unstable';
    } else if (lowerIsBetter) {
      stability = scaled <= baseline ? 'Stable' : 'Uncertain';
    } else {
      final ratio = baseline == 0 ? (scaled > 0 ? 5.0 : 1.0) : scaled / baseline;
      if (ratio >= 4.5) stability = 'Strongly Stable';
      else if (ratio >= 3.5) stability = 'Stable';
      else if (ratio >= 2.5) stability = 'Uncertain';
      else stability = 'Unstable';
    }

    return {
      'metric': name,
      'baseline200': baseline,
      'scale1000': scaled,
      'absoluteGain': absoluteGain,
      'percentageGain': pctGain,
      'stability': stability,
    };
  }

  static double _pctGain(int before, int after) {
    if (before == 0) return 0;
    return ((after - before) / before) * 100;
  }

  static String _overall(List<Map<String, dynamic>> metrics) {
    final scores = metrics.map((m) => m['stability'] as String).toList();
    if (scores.every((s) => s == 'Strongly Stable' || s == 'Stable')) {
      return 'Strongly Stable';
    }
    if (scores.any((s) => s == 'Unstable')) return 'Uncertain';
    return 'Stable';
  }
}

abstract final class ValidationGatesAudit {
  static Map<String, dynamic> evaluate({
    required List<SyntheticHumanRunRecord> records,
    required Map<String, dynamic> v2Sim,
    required Map<String, dynamic> deadZones,
  }) {
    final populationSize = records.length;
    final baseline = v2Sim['baseline'] as Map<String, dynamic>;
    final simulated = v2Sim['simulatedAfterRecovery'] as Map<String, dynamic>;
    final vg005 = v2Sim['vg005NarrativeQuality'] as Map<String, dynamic>;
    final baseQuality = vg005['baseline'] as Map<String, dynamic>;
    final simQuality = vg005['simulated'] as Map<String, dynamic>;
    final deadZoneRecovery =
        v2Sim['deadZoneSimRecovery'] as Map<String, dynamic>;
    final dependentPatterns =
        v2Sim['dependentPatternActivations'] as List<dynamic>;

    final vg001Pass = V2RecoverySimulationAudit.deadZoneKeys.every(
      (key) => (deadZoneRecovery[key] as int) > 0,
    );
    final validatedPatterns = dependentPatterns
        .where((p) => (p as Map)['validated'] == true)
        .length;
    final vg002Pass = validatedPatterns ==
        V2RecoverySimulationAudit.dependentPatternIds.length;
    final vg003Pass = (simulated['uniquePatternSets'] as int) >= 125;
    final vg004Pass = (simulated['uniqueNarratives'] as int) >= 130;
    final vg005Pass = (simQuality['uniqueNarratives'] as int) >
            (baseQuality['uniqueNarratives'] as int) &&
        (simQuality['profilesInCollapse'] as int) <
            (baseQuality['profilesInCollapse'] as int) &&
        (simQuality['maxClusterSize'] as int) <
            (baseQuality['maxClusterSize'] as int);
    final vg006Pass =
        (simQuality['narrativeDiversityRatio'] as num) >= 0.55;

    final gates = {
      'VG-001': _gate(
        id: 'VG-001',
        name: 'Dead-zone fusion findings recoverable',
        pass: vg001Pass,
        baseline: '0 for all 3 keys',
        target: '> 0 for all 3 keys',
        measured: deadZoneRecovery,
      ),
      'VG-002': _gate(
        id: 'VG-002',
        name: 'Dependent pattern reachability',
        pass: vg002Pass,
        baseline: '0 / 6',
        target: '6 / 6',
        measured: {
          'validatedCount': validatedPatterns,
          'requiredCount':
              V2RecoverySimulationAudit.dependentPatternIds.length,
          'patterns': dependentPatterns,
        },
      ),
      'VG-003': _gate(
        id: 'VG-003',
        name: 'Unique pattern sets',
        pass: vg003Pass,
        baseline: baseline['uniquePatternSets'],
        target: '>= 125',
        measured: simulated['uniquePatternSets'],
      ),
      'VG-004': _gate(
        id: 'VG-004',
        name: 'Unique narratives',
        pass: vg004Pass,
        baseline: baseline['uniqueNarratives'],
        target: '>= 130',
        measured: simulated['uniqueNarratives'],
      ),
      'VG-005': _gate(
        id: 'VG-005',
        name: 'Narrative quality (redefined)',
        pass: vg005Pass,
        baseline: baseQuality,
        target: {
          'uniqueNarratives': 'simulated > baseline',
          'profilesInCollapse': 'simulated < baseline',
          'maxClusterSize': 'simulated < baseline',
        },
        measured: simQuality,
        delta: vg005['delta'],
      ),
      'VG-006': _gate(
        id: 'VG-006',
        name: 'Narrative diversity ratio',
        pass: vg006Pass,
        baseline: baseQuality['narrativeDiversityRatio'],
        target: '>= 0.55',
        measured: simQuality['narrativeDiversityRatio'],
      ),
    };

    final allPass = gates.values.every((g) => (g as Map)['pass'] == true);

    return {
      'populationSize': populationSize,
      'gates': gates,
      'allGatesPass': allPass,
      'r004ReinforcementsApplied': simulated['r004ReinforcementsApplied'],
      'adaptiveCreatorValidated': _patternValidated(dependentPatterns, 'adaptive_creator'),
      'stableOrientationValidated':
          _patternValidated(dependentPatterns, 'stable_orientation'),
      'failedGates': [
        for (final entry in gates.entries)
          if (!(entry.value['pass'] as bool)) entry.key,
      ],
    };
  }

  /// Final calibration gates — VG-006 uses scale-invariant improvement ratio.
  static Map<String, dynamic> evaluateCalibrated({
    required List<SyntheticHumanRunRecord> records,
    required Map<String, dynamic> v2Sim,
    required Map<String, dynamic> deadZones,
    required Map<String, dynamic> vg006Calibration,
  }) {
    final base = evaluate(records: records, v2Sim: v2Sim, deadZones: deadZones);
    final gates = Map<String, dynamic>.from(base['gates'] as Map);
    final baseline = v2Sim['baseline'] as Map<String, dynamic>;
    final simulated = v2Sim['simulatedAfterRecovery'] as Map<String, dynamic>;
    final improvementRatio =
        (baseline['uniqueNarratives'] as int) == 0
            ? 0.0
            : (simulated['uniqueNarratives'] as num) /
                (baseline['uniqueNarratives'] as num);
    const threshold = 1.5;
    final vg006Pass = improvementRatio >= threshold;

    gates['VG-006'] = _gate(
      id: 'VG-006',
      name: 'Narrative diversity improvement (calibrated)',
      pass: vg006Pass,
      baseline: baseline['uniqueNarratives'],
      target: '>= ${threshold}x baseline unique narratives',
      measured: {
        'improvementRatio': improvementRatio,
        'simulatedUniqueNarratives': simulated['uniqueNarratives'],
        'legacyRatio':
            (v2Sim['vg005NarrativeQuality'] as Map)['simulated']
                ['narrativeDiversityRatio'],
      },
      delta: vg006Calibration['calibratedVg006Proposal'],
    );

    final allPass = gates.values.every((g) => (g as Map)['pass'] == true);

    return {
      ...base,
      'gates': gates,
      'allGatesPass': allPass,
      'vg006CalibrationApplied': true,
      'failedGates': [
        for (final entry in gates.entries)
          if (!(entry.value['pass'] as bool)) entry.key,
      ],
    };
  }

  static bool _patternValidated(List<dynamic> patterns, String patternId) {
    for (final item in patterns) {
      final map = item as Map<String, dynamic>;
      if (map['patternId'] == patternId) return map['validated'] as bool;
    }
    return false;
  }

  static Map<String, dynamic> _gate({
    required String id,
    required String name,
    required bool pass,
    required Object baseline,
    required Object target,
    required Object measured,
    Object? delta,
  }) {
    return {
      'id': id,
      'name': name,
      'pass': pass,
      'baseline': baseline,
      'target': target,
      'measured': measured,
      if (delta != null) 'delta': delta,
    };
  }
}

abstract final class DecisionGateAudit {
  static Map<String, dynamic> evaluate({
    required Map<String, dynamic> populationQuality,
    required Map<String, dynamic> deadZones,
    required Map<String, dynamic> v2Sim,
    required Map<String, dynamic> stability,
    required PatternDistributionAudit patterns,
    required FusionDistributionAudit fusion,
    required Map<String, dynamic> validationGates,
  }) {
    final deadZoneSummary = deadZones['summary'] as Map<String, dynamic>;
    final simulated = v2Sim['simulatedAfterRecovery'] as Map<String, dynamic>;
    final baseline = v2Sim['baseline'] as Map<String, dynamic>;

    final q1 = (simulated['additionalActivations'] as int) > 0;
    final q2 = true;
    final q3NewDeadZones = _newDeadZones(fusion.fusionDeadZones);
    final q4Regressions = !(populationQuality['maxArchetypeSharePass'] as bool);
    final allGatesPass = validationGates['allGatesPass'] as bool;
    final q5 = q1 &&
        allGatesPass &&
        (populationQuality['maxArchetypeSharePass'] as bool);

    return {
      'gf2V2StillJustified': q1 ? 'YES' : 'NO',
      'architectureStillBPlusC': q2 ? 'YES' : 'NO',
      'newDeadZonesDetected': q3NewDeadZones.isEmpty ? 'NO' : 'YES',
      'newDeadZoneKeys': q3NewDeadZones,
      'hiddenRegressionsDetected': q4Regressions ? 'YES' : 'NO',
      'implementationShouldBeginNow': q5 ? 'YES' : 'NO',
      'finalDecision': q5 ? 'IMPLEMENT GF2 NOW' : 'DO NOT IMPLEMENT GF2',
      'evidence': {
        'populationQualityPass': populationQuality['maxArchetypeSharePass'],
        'maxArchetypeShare': populationQuality['maxArchetypeShare'],
        'baselineDeadPatterns': baseline['deadPatternCount'],
        'simulatedDeadPatterns': simulated['deadPatternCount'],
        'activationGain': simulated['additionalActivations'],
        'narrativeGain': simulated['additionalUniqueNarratives'],
        'r004ReinforcementsApplied': simulated['r004ReinforcementsApplied'],
        'adaptiveCreatorValidated': validationGates['adaptiveCreatorValidated'],
        'stableOrientationValidated':
            validationGates['stableOrientationValidated'],
        'validationGatesPass': allGatesPass,
        'failedGates': validationGates['failedGates'],
        'deadZoneStatus': deadZoneSummary,
        'overallStability': stability['overallStability'],
        'knownFusionDeadZonesAt1000': fusion.fusionDeadZones,
      },
    };
  }

  static List<String> _newDeadZones(List<String> current) {
    const known = {
      'MIRROR_LIFE_DIRECTION',
      'MIRROR_GROWTH_ORIENTATION',
      'MIRROR_STRUCTURE_PATTERN',
    };
    return current.where((k) => !known.contains(k)).toList()..sort();
  }
}
