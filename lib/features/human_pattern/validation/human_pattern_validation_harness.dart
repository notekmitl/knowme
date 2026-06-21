import '../builder/human_pattern_snapshot_builder.dart';
import '../contracts/human_pattern_input.dart';
import '../domain/human_pattern_snapshot.dart';
import '../lineage/pattern_lineage_trace.dart';
import '../registry/human_pattern_registry.dart';
import '../validation/human_pattern_validation.dart';

class HumanPatternValidationHarnessResult {
  const HumanPatternValidationHarnessResult({
    required this.passed,
    required this.issues,
    required this.snapshot,
  });

  final bool passed;
  final List<String> issues;
  final HumanPatternSnapshot snapshot;
}

abstract final class HumanPatternValidationHarness {
  static HumanPatternValidationHarnessResult run(HumanPatternInput input) {
    final issues = <String>[];

    final first = HumanPatternSnapshotBuilder.build(
      input,
      createdAt: DateTime.utc(2026, 6, 21),
    );
    final second = HumanPatternSnapshotBuilder.build(
      input,
      createdAt: DateTime.utc(2026, 12, 31),
    );

    if (first.snapshotId != second.snapshotId) {
      issues.add('determinism: snapshotId mismatch across createdAt values');
    }
    if (first.structuralHash != second.structuralHash) {
      issues.add('determinism: structuralHash mismatch across createdAt values');
    }

    if (HumanPatternRegistry.allPatternIds.length !=
        HumanPatternRegistry.allEntries.length) {
      issues.add('registry stability: duplicate pattern ids detected');
    }

    if (first.confidence.composite ==
        input.humanModelSnapshot.confidence.composite) {
      issues.add('confidence must not equal human model composite passthrough');
    }

    final audit = HumanPatternValidation.audit(first);
    if (!audit.passed) {
      issues.addAll(audit.issues);
    }

    if (!PatternLineageTrace.hasCompleteLineage(first)) {
      issues.add('lineage completeness check failed');
    }

    return HumanPatternValidationHarnessResult(
      passed: issues.isEmpty,
      issues: issues,
      snapshot: first,
    );
  }
}
