import '../builder/human_model_foundation_builder.dart';
import '../contracts/human_model_input.dart';
import '../domain/human_model_snapshot.dart';
import '../lineage/human_lineage_trace.dart';
import '../validation/human_model_validation.dart';

class HumanModelValidationHarnessResult {
  const HumanModelValidationHarnessResult({
    required this.passed,
    required this.issues,
    required this.snapshot,
  });

  final bool passed;
  final List<String> issues;
  final HumanModelSnapshot snapshot;
}

abstract final class HumanModelValidationHarness {
  static HumanModelValidationHarnessResult run(HumanModelInput input) {
    final issues = <String>[];

    final first = HumanModelFoundationBuilder.build(
      input,
      createdAt: DateTime.utc(2026, 6, 21),
    );
    final second = HumanModelFoundationBuilder.build(
      input,
      createdAt: DateTime.utc(2026, 12, 31),
    );

    if (first.snapshotId != second.snapshotId) {
      issues.add('determinism: snapshotId mismatch across createdAt values');
    }
    if (first.structuralHash != second.structuralHash) {
      issues.add('determinism: structuralHash mismatch across createdAt values');
    }

    if (first.confidence.composite == input.fusionSnapshot.confidence.composite) {
      issues.add('confidence must not equal fusion composite passthrough');
    }

    final audit = HumanModelValidation.audit(first);
    if (!audit.passed) {
      issues.addAll(audit.issues);
    }

    if (!HumanLineageTrace.hasCompleteLineage(first)) {
      issues.add('lineage completeness check failed');
    }

    return HumanModelValidationHarnessResult(
      passed: issues.isEmpty,
      issues: issues,
      snapshot: first,
    );
  }
}
