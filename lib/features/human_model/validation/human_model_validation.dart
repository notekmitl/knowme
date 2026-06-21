import '../domain/human_model_snapshot.dart';
import '../lineage/human_lineage_trace.dart';

/// HM7 audit report for human model snapshots.
class HumanModelAuditReport {
  const HumanModelAuditReport({
    required this.passed,
    required this.issues,
    required this.invalidCoverage,
    required this.invalidConfidence,
    required this.incompleteLineage,
    required this.orphanPatterns,
    required this.duplicatePatterns,
  });

  final bool passed;
  final List<String> issues;
  final bool invalidCoverage;
  final bool invalidConfidence;
  final bool incompleteLineage;
  final bool orphanPatterns;
  final bool duplicatePatterns;
}

abstract final class HumanModelValidation {
  static HumanModelAuditReport audit(HumanModelSnapshot snapshot) {
    final issues = <String>[];
    var invalidCoverage = false;
    var invalidConfidence = false;
    var incompleteLineage = false;
    var orphanPatterns = false;
    var duplicatePatterns = false;

    if (snapshot.coverage.weightedCoverage < 0 ||
        snapshot.coverage.weightedCoverage > 1) {
      invalidCoverage = true;
      issues.add('invalid coverage: ${snapshot.coverage.weightedCoverage}');
    }

    if (snapshot.confidence.composite < 0 ||
        snapshot.confidence.composite > 1) {
      invalidConfidence = true;
      issues.add('invalid confidence: ${snapshot.confidence.composite}');
    }

    if (!HumanLineageTrace.hasCompleteLineage(snapshot)) {
      incompleteLineage = true;
      issues.add('incomplete lineage: pattern missing evidence chain');
    }

    final evidencePatternIds =
        snapshot.evidence.map((row) => row.humanPatternId).toSet();
    for (final pattern in snapshot.patterns) {
      if (!evidencePatternIds.contains(pattern.id)) {
        orphanPatterns = true;
        issues.add('orphan pattern: ${pattern.id}');
      }
    }

    final patternKeys = snapshot.patterns.map((item) => item.patternKey).toList();
    final uniqueKeys = patternKeys.toSet();
    if (uniqueKeys.length != patternKeys.length) {
      duplicatePatterns = true;
      issues.add('duplicate pattern keys detected');
    }

    return HumanModelAuditReport(
      passed: issues.isEmpty,
      issues: issues,
      invalidCoverage: invalidCoverage,
      invalidConfidence: invalidConfidence,
      incompleteLineage: incompleteLineage,
      orphanPatterns: orphanPatterns,
      duplicatePatterns: duplicatePatterns,
    );
  }
}
