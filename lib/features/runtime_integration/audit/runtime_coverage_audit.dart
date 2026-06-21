import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import '../pipeline/knowme_runtime_pipeline.dart';

/// RT4 — human pattern coverage statistics from real runtime.
class RuntimeCoverageStatistics {
  const RuntimeCoverageStatistics({
    required this.registryPatternCount,
    required this.activatedPatternCount,
    required this.activationRate,
    required this.averageActivationsPerUser,
    required this.activatedDimensionCount,
    required this.dimensionCoverageRate,
    required this.activatedPatternIds,
  });

  final int registryPatternCount;
  final int activatedPatternCount;
  final double activationRate;
  final double averageActivationsPerUser;
  final int activatedDimensionCount;
  final double dimensionCoverageRate;
  final List<String> activatedPatternIds;
}

abstract final class RuntimeCoverageAudit {
  static RuntimeCoverageStatistics analyze(KnowMeRuntimePipelineResult result) {
    final registryCount = HumanPatternRegistry.allEntries.length;
    final activated = result.humanPatternSnapshot.activations;
    final activatedIds = activated.map((item) => item.patternId).toList()
      ..sort();

    return RuntimeCoverageStatistics(
      registryPatternCount: registryCount,
      activatedPatternCount: activated.length,
      activationRate:
          registryCount == 0 ? 0 : activated.length / registryCount,
      averageActivationsPerUser: activated.length.toDouble(),
      activatedDimensionCount:
          result.humanPatternSnapshot.coverage.activatedDimensionCount,
      dimensionCoverageRate: result.humanPatternSnapshot.coverage.weightedCoverage,
      activatedPatternIds: activatedIds,
    );
  }
}
