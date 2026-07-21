import '../builder/global_fusion_foundation_builder.dart';
import '../contracts/global_fusion_input.dart';
import '../domain/global_fusion_snapshot.dart';
import '../lineage/global_fusion_lineage_trace.dart';

/// GF10 validation harness for global fusion foundation.
class GlobalFusionValidationHarnessResult {
  const GlobalFusionValidationHarnessResult({
    required this.passed,
    required this.issues,
    required this.snapshot,
  });

  final bool passed;
  final List<String> issues;
  final GlobalFusionSnapshot snapshot;
}

abstract final class GlobalFusionValidationHarness {
  static GlobalFusionValidationHarnessResult run(GlobalFusionInput input) {
    final issues = <String>[];

    final first = GlobalFusionFoundationBuilder.build(
      input,
      createdAt: DateTime.utc(2026, 6, 21),
    );
    final second = GlobalFusionFoundationBuilder.build(
      input,
      createdAt: DateTime.utc(2026, 12, 31),
    );

    if (first.snapshotId != second.snapshotId) {
      issues.add('determinism: snapshotId mismatch across createdAt values');
    }
    if (first.structuralHash != second.structuralHash) {
      issues.add('determinism: structuralHash mismatch across createdAt values');
    }

    _verifyConfidenceMonotonicity(input, issues);
    _verifyLineageCompleteness(first, issues);

    return GlobalFusionValidationHarnessResult(
      passed: issues.isEmpty,
      issues: issues,
      snapshot: first,
    );
  }

  static void _verifyConfidenceMonotonicity(
    GlobalFusionInput input,
    List<String> issues,
  ) {
    if (input.mirrorCount < 2) return;

    final partial = GlobalFusionInput(
      mirrors: input.mirrors.sublist(0, input.mirrorCount - 1),
    );
    final baseline = GlobalFusionFoundationBuilder.build(
      partial,
      createdAt: DateTime.utc(2026, 6, 21),
    );
    final expanded = GlobalFusionFoundationBuilder.build(
      input,
      createdAt: DateTime.utc(2026, 6, 21),
    );

    if (expanded.confidence.composite < baseline.confidence.composite) {
      issues.add(
        'confidence monotonicity: expanded mirror set lowered composite confidence',
      );
    }
  }

  static void _verifyLineageCompleteness(
    GlobalFusionSnapshot snapshot,
    List<String> issues,
  ) {
    if (!GlobalFusionLineageTrace.hasCompleteLineage(snapshot)) {
      issues.add('lineage completeness: finding without preserved evidence');
    }

    for (final row in snapshot.evidence) {
      if (row.mirrorSnapshotId.isEmpty || row.sourceThemeId.isEmpty) {
        issues.add('lineage completeness: evidence row missing trace fields');
        break;
      }
    }
  }
}
