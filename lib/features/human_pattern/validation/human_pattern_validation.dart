import '../domain/human_pattern_snapshot.dart';
import '../lineage/pattern_lineage_trace.dart';
import '../registry/human_pattern_registry.dart';

class HumanPatternAuditReport {
  const HumanPatternAuditReport({
    required this.passed,
    required this.issues,
    required this.duplicatePatterns,
    required this.conflictingPatterns,
    required this.orphanPatterns,
    required this.invalidActivations,
  });

  final bool passed;
  final List<String> issues;
  final bool duplicatePatterns;
  final bool conflictingPatterns;
  final bool orphanPatterns;
  final bool invalidActivations;
}

/// HP7 — validates human pattern snapshot integrity.
abstract final class HumanPatternValidation {
  static HumanPatternAuditReport audit(HumanPatternSnapshot snapshot) {
    final issues = <String>[];
    var duplicatePatterns = false;
    var conflictingPatterns = false;
    var orphanPatterns = false;
    var invalidActivations = false;

    final patternIds =
        snapshot.activations.map((item) => item.patternId).toList();
    if (patternIds.toSet().length != patternIds.length) {
      duplicatePatterns = true;
      issues.add('duplicate pattern activations detected');
    }

    final activeIds = patternIds.toSet();
    for (final pair in HumanPatternConflictCatalog.pairs) {
      if (activeIds.contains(pair.$1) && activeIds.contains(pair.$2)) {
        conflictingPatterns = true;
        issues.add('conflicting patterns active: ${pair.$1} vs ${pair.$2}');
      }
    }

    final evidencePatternIds =
        snapshot.evidence.map((row) => row.registryPatternId).toSet();
    for (final activation in snapshot.activations) {
      if (!evidencePatternIds.contains(activation.patternId)) {
        orphanPatterns = true;
        issues.add('orphan pattern activation: ${activation.patternId}');
      }

      if (activation.activationStrength < 0 ||
          activation.activationStrength > 1 ||
          activation.confidence.composite < 0 ||
          activation.confidence.composite > 1) {
        invalidActivations = true;
        issues.add('invalid activation values: ${activation.patternId}');
      }

      if (HumanPatternRegistry.byId(activation.patternId) == null) {
        invalidActivations = true;
        issues.add('unknown registry pattern: ${activation.patternId}');
      }
    }

    if (snapshot.coverage.weightedCoverage < 0 ||
        snapshot.coverage.weightedCoverage > 1) {
      invalidActivations = true;
      issues.add('invalid coverage: ${snapshot.coverage.weightedCoverage}');
    }

    if (!PatternLineageTrace.hasCompleteLineage(snapshot)) {
      issues.add('incomplete lineage chain');
    }

    return HumanPatternAuditReport(
      passed: issues.isEmpty,
      issues: issues,
      duplicatePatterns: duplicatePatterns,
      conflictingPatterns: conflictingPatterns,
      orphanPatterns: orphanPatterns,
      invalidActivations: invalidActivations,
    );
  }
}
