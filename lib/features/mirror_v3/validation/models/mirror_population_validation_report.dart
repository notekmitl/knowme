/// Distribution summary for population validation metrics.
class MirrorPopulationDistributionSummary {
  const MirrorPopulationDistributionSummary({
    required this.agreementPerCase,
    required this.tensionPerCase,
    required this.reinforcementPerCase,
    required this.blindSpotPerCase,
    required this.confidencePerCase,
  });

  final double agreementPerCase;
  final double tensionPerCase;
  final double reinforcementPerCase;
  final double blindSpotPerCase;
  final double confidencePerCase;

  Map<String, dynamic> toMap() {
    return {
      'agreementPerCase': agreementPerCase,
      'tensionPerCase': tensionPerCase,
      'reinforcementPerCase': reinforcementPerCase,
      'blindSpotPerCase': blindSpotPerCase,
      'confidencePerCase': confidencePerCase,
    };
  }
}

/// MV2.1 population validation report.
class MirrorPopulationValidationReport {
  const MirrorPopulationValidationReport({
    required this.totalCases,
    required this.agreementCount,
    required this.tensionCount,
    required this.reinforcementCount,
    required this.blindSpotCount,
    required this.distribution,
    required this.anomalies,
    required this.passed,
  });

  final int totalCases;
  final int agreementCount;
  final int tensionCount;
  final int reinforcementCount;
  final int blindSpotCount;
  final MirrorPopulationDistributionSummary distribution;
  final List<String> anomalies;
  final bool passed;

  Map<String, dynamic> toMap() {
    return {
      'totalCases': totalCases,
      'agreementCount': agreementCount,
      'tensionCount': tensionCount,
      'reinforcementCount': reinforcementCount,
      'blindSpotCount': blindSpotCount,
      'distribution': distribution.toMap(),
      'anomalies': anomalies,
      'passed': passed,
    };
  }
}
