/// Blind spot distribution bucket for MV2.4.
class MirrorBlindSpotDistributionBucket {
  const MirrorBlindSpotDistributionBucket({
    required this.label,
    required this.caseCount,
    required this.rate,
  });

  final String label;
  final int caseCount;
  final double rate;

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'caseCount': caseCount,
      'rate': rate,
    };
  }
}

/// MV2.4 blind spot validation report.
class MirrorBlindSpotValidationReport {
  const MirrorBlindSpotValidationReport({
    required this.totalCases,
    required this.noBlindSpotCases,
    required this.singleBlindSpotCases,
    required this.multipleBlindSpotCases,
    required this.distribution,
    required this.anomalies,
    required this.passed,
  });

  final int totalCases;
  final int noBlindSpotCases;
  final int singleBlindSpotCases;
  final int multipleBlindSpotCases;
  final List<MirrorBlindSpotDistributionBucket> distribution;
  final List<String> anomalies;
  final bool passed;

  Map<String, dynamic> toMap() {
    return {
      'totalCases': totalCases,
      'noBlindSpotCases': noBlindSpotCases,
      'singleBlindSpotCases': singleBlindSpotCases,
      'multipleBlindSpotCases': multipleBlindSpotCases,
      'distribution': distribution.map((bucket) => bucket.toMap()).toList(),
      'anomalies': anomalies,
      'passed': passed,
    };
  }
}
