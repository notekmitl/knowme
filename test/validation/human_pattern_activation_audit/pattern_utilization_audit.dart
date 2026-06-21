import 'package:knowme/features/human_model/domain/human_dimension.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import '../synthetic_population/pipeline/synthetic_human_run_record.dart';

/// Audit E — full pattern utilization distribution.
class PatternUtilizationReport {
  const PatternUtilizationReport({
    required this.populationSize,
    required this.registryPatternCount,
    required this.topActivated,
    required this.bottomActivated,
    required this.neverActivated,
    required this.activationDistribution,
    required this.familyDistribution,
    required this.dimensionDistribution,
  });

  final int populationSize;
  final int registryPatternCount;
  final List<PatternActivationStat> topActivated;
  final List<PatternActivationStat> bottomActivated;
  final List<PatternActivationStat> neverActivated;
  final Map<String, int> activationDistribution;
  final Map<String, int> familyDistribution;
  final Map<String, int> dimensionDistribution;

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'registryPatternCount': registryPatternCount,
      'topActivated': topActivated.map((item) => item.toJson()).toList(),
      'bottomActivated': bottomActivated.map((item) => item.toJson()).toList(),
      'neverActivated': neverActivated.map((item) => item.toJson()).toList(),
      'activationDistribution': activationDistribution,
      'familyDistribution': familyDistribution,
      'dimensionDistribution': dimensionDistribution,
    };
  }
}

class PatternActivationStat {
  const PatternActivationStat({
    required this.patternId,
    required this.label,
    required this.patternFamilyId,
    required this.dimension,
    required this.activationCount,
    required this.activationRate,
  });

  final String patternId;
  final String label;
  final String patternFamilyId;
  final String dimension;
  final int activationCount;
  final double activationRate;

  Map<String, dynamic> toJson() {
    return {
      'patternId': patternId,
      'label': label,
      'patternFamilyId': patternFamilyId,
      'dimension': dimension,
      'activationCount': activationCount,
      'activationRate': activationRate,
    };
  }
}

abstract final class PatternUtilizationAudit {
  static PatternUtilizationReport analyze(List<SyntheticHumanRunRecord> records) {
    final populationSize = records.length;
    final activationCounts = <String, int>{};
    final familyCounts = <String, int>{};
    final dimensionCounts = <String, int>{};

    for (final record in records) {
      for (final activation in record.humanPatternSnapshot.activations) {
        activationCounts[activation.patternId] =
            (activationCounts[activation.patternId] ?? 0) + 1;

        final entry = HumanPatternRegistry.byId(activation.patternId);
        if (entry != null) {
          familyCounts[entry.patternFamilyId] =
              (familyCounts[entry.patternFamilyId] ?? 0) + 1;
          dimensionCounts[entry.dimension.key] =
              (dimensionCounts[entry.dimension.key] ?? 0) + 1;
        }
      }
    }

    final stats = HumanPatternRegistry.allEntries.map((entry) {
      final count = activationCounts[entry.patternId] ?? 0;
      return PatternActivationStat(
        patternId: entry.patternId,
        label: entry.label,
        patternFamilyId: entry.patternFamilyId,
        dimension: entry.dimension.key,
        activationCount: count,
        activationRate: populationSize == 0 ? 0 : count / populationSize,
      );
    }).toList()
      ..sort((a, b) => b.activationCount.compareTo(a.activationCount));

    final never = stats.where((item) => item.activationCount == 0).toList();
    final activated = stats.where((item) => item.activationCount > 0).toList();

    return PatternUtilizationReport(
      populationSize: populationSize,
      registryPatternCount: HumanPatternRegistry.allPatternIds.length,
      topActivated: activated.take(10).toList(),
      bottomActivated: activated.length <= 10
          ? const []
          : activated.reversed.take(10).toList().reversed.toList(),
      neverActivated: never,
      activationDistribution: {
        for (final item in stats) item.patternId: item.activationCount,
      },
      familyDistribution: _sorted(familyCounts),
      dimensionDistribution: _sorted(dimensionCounts),
    );
  }

  static Map<String, int> _sorted(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map<String, int>.fromEntries(entries);
  }
}
