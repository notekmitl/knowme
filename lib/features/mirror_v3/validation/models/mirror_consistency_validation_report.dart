/// MV2.2 consistency validation report.
class MirrorConsistencyValidationReport {
  const MirrorConsistencyValidationReport({
    required this.caseCount,
    required this.runsPerCase,
    required this.allDeterministic,
    required this.mismatches,
    required this.passed,
  });

  final int caseCount;
  final int runsPerCase;
  final bool allDeterministic;
  final List<String> mismatches;
  final bool passed;

  Map<String, dynamic> toMap() {
    return {
      'caseCount': caseCount,
      'runsPerCase': runsPerCase,
      'allDeterministic': allDeterministic,
      'mismatches': mismatches,
      'passed': passed,
    };
  }
}
