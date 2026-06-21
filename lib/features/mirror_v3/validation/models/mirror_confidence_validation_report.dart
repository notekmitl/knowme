/// Single confidence monotonicity check result.
class MirrorConfidenceCaseResult {
  const MirrorConfidenceCaseResult({
    required this.seed,
    required this.oneLensConfidence,
    required this.twoLensConfidence,
    required this.threeLensConfidence,
    required this.monotonic,
    required this.issues,
  });

  final int seed;
  final double oneLensConfidence;
  final double twoLensConfidence;
  final double threeLensConfidence;
  final bool monotonic;
  final List<String> issues;
}

/// MV2.3 confidence validation report.
class MirrorConfidenceValidationReport {
  const MirrorConfidenceValidationReport({
    required this.caseCount,
    required this.monotonicCases,
    required this.violations,
    required this.cases,
    required this.passed,
  });

  final int caseCount;
  final int monotonicCases;
  final int violations;
  final List<MirrorConfidenceCaseResult> cases;
  final bool passed;

  Map<String, dynamic> toMap() {
    return {
      'caseCount': caseCount,
      'monotonicCases': monotonicCases,
      'violations': violations,
      'passed': passed,
      'cases': cases
          .map(
            (item) => {
              'seed': item.seed,
              'oneLensConfidence': item.oneLensConfidence,
              'twoLensConfidence': item.twoLensConfidence,
              'threeLensConfidence': item.threeLensConfidence,
              'monotonic': item.monotonic,
              'issues': item.issues,
            },
          )
          .toList(),
    };
  }
}
