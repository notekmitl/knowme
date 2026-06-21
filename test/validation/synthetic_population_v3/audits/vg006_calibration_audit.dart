import '../../synthetic_population/factory/synthetic_human_profile_factory.dart';
import '../../synthetic_population/pipeline/synthetic_human_pipeline_runner.dart';
import '../../synthetic_population/pipeline/synthetic_human_run_record.dart';
import '../../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';

/// Task C — VG-006 calibration review across population scales.
abstract final class Vg006CalibrationAudit {
  static Map<String, dynamic> analyze({
    required List<SyntheticHumanRunRecord> records200,
    required List<SyntheticHumanRunRecord> records1000,
  }) {
    final scale200 = _scaleMetrics(records200);
    final scale1000 = _scaleMetrics(records1000);

    return {
      'scale200': scale200,
      'scale1000': scale1000,
      'metricComparison': _compareMetrics(scale200, scale1000),
      'recommendedPrimaryMetric': 'uniqueNarrativesWithVg005Composite',
      'legacyVg006RatioAssessment': {
        'passAt200': (scale200['simulated']['narrativeDiversityRatio'] as num) >= 0.55,
        'passAt1000':
            (scale1000['simulated']['narrativeDiversityRatio'] as num) >= 0.55,
        'conclusion':
            'Absolute uniqueNarrativeRatio is scale-dependent and inversely correlated with population size at fixed archetype diversity.',
      },
      'calibratedVg006Proposal': {
        'metric': 'narrativeDiversityImprovementRatio',
        'formula': 'simulated.uniqueNarratives / baseline.uniqueNarratives',
        'threshold': 1.5,
        'passAt200': scale200['simulated']['narrativeDiversityImprovementRatio'],
        'passAt1000': scale1000['simulated']['narrativeDiversityImprovementRatio'],
        'pass200':
            (scale200['simulated']['narrativeDiversityImprovementRatio'] as num) >=
                1.5,
        'pass1000':
            (scale1000['simulated']['narrativeDiversityImprovementRatio'] as num) >=
                1.5,
      },
    };
  }

  static Map<String, dynamic> _scaleMetrics(List<SyntheticHumanRunRecord> records) {
    final baselineNarratives = records.map((r) => r.narrativeFingerprint).toList();
    final simulatedNarratives = <String>[];
    var baselineUnique = baselineNarratives.toSet().length;

    for (final record in records) {
      final sim = ValidationV2RecoverySimulator.simulateRecord(record);
      simulatedNarratives.add(sim.narrativeFingerprint);
    }

    final baseQ = _quality(baselineNarratives);
    final simQ = _quality(simulatedNarratives);

    return {
      'populationSize': records.length,
      'baseline': baseQ,
      'simulated': {
        ...simQ,
        'narrativeDiversityImprovementRatio':
            baseQ['uniqueNarratives'] == 0
                ? 0.0
                : simQ['uniqueNarratives'] / baseQ['uniqueNarratives'],
      },
    };
  }

  static Map<String, dynamic> _quality(List<String> fingerprints) {
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
      'maxClusterSize': clusterSizes.isEmpty ? 0 : clusterSizes.last,
      'narrativeDiversityRatio':
          fingerprints.isEmpty ? 0.0 : counts.length / fingerprints.length,
    };
  }

  static List<Map<String, dynamic>> _compareMetrics(
    Map<String, dynamic> scale200,
    Map<String, dynamic> scale1000,
  ) {
    final metrics = [
      'uniqueNarratives',
      'profilesInCollapse',
      'maxClusterSize',
      'narrativeDiversityRatio',
    ];
    return [
      for (final metric in metrics)
        {
          'metric': metric,
          'baseline200': (scale200['baseline'] as Map)[metric],
          'simulated200': (scale200['simulated'] as Map)[metric],
          'baseline1000': (scale1000['baseline'] as Map)[metric],
          'simulated1000': (scale1000['simulated'] as Map)[metric],
          'scaleInvariantImprovementDirection':
              _improves(metric, scale200, scale1000),
        },
    ];
  }

  static bool _improves(
    String metric,
    Map<String, dynamic> scale200,
    Map<String, dynamic> scale1000,
  ) {
    final b200 = (scale200['baseline'] as Map)[metric] as num;
    final s200 = (scale200['simulated'] as Map)[metric] as num;
    final b1000 = (scale1000['baseline'] as Map)[metric] as num;
    final s1000 = (scale1000['simulated'] as Map)[metric] as num;

    if (metric == 'profilesInCollapse' || metric == 'maxClusterSize') {
      return s200 < b200 && s1000 < b1000;
    }
    return s200 > b200 && s1000 > b1000;
  }

  static List<SyntheticHumanRunRecord> buildPopulation200() {
    final profiles = SyntheticHumanProfileFactory.buildAll();
    final records = <SyntheticHumanRunRecord>[];
    for (var i = 0; i < profiles.length; i++) {
      records.add(
        SyntheticHumanPipelineRunner.run(
          profiles[i],
          generatedAt: DateTime.utc(2026, 6, 21, i % 24, i % 60),
        ),
      );
    }
    return records;
  }
}
