/// Canon Knowledge Extraction Workspace V4 — review report.
///
/// A single deterministic, structured report that is the reviewer's decision
/// surface before import: session summary, knowledge units, validation, diff,
/// coverage delta, warnings and a ready-for-import verdict. No narrative, no AI.
/// Pure Dart over the workspace + atomic + ontology layers.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/canon_completeness_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/completeness_delta.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_diff.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_extraction_session.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/workspace_validator.dart';

class ReviewReport {
  const ReviewReport({
    required this.sessionId,
    required this.state,
    required this.unitCount,
    required this.validation,
    required this.diff,
    required this.completeness,
    required this.readyForImport,
  });

  final String sessionId;
  final SessionState state;
  final int unitCount;
  final WorkspaceValidationReport validation;
  final KnowledgeDiff diff;
  final CompletenessDelta completeness;

  /// Ready for import only when validation has no errors AND the diff has no
  /// unresolved conflicts. Canon is never overwritten blindly.
  final bool readyForImport;

  List<String> get warnings => [
        for (final w in validation.warnings) w.toString(),
        if (diff.hasConflict)
          'Diff has ${diff.count(DiffKind.conflict)} conflict(s) needing review.',
      ];

  /// A deterministic, structured (non-narrative) rendering of the report.
  String render() {
    final b = StringBuffer()
      ..writeln('# Canon Review Report')
      ..writeln('session: $sessionId')
      ..writeln('state: ${state.name}')
      ..writeln('units: $unitCount')
      ..writeln('')
      ..writeln('## Validation')
      ..writeln('errors: ${validation.errors.length}  '
          'warnings: ${validation.warnings.length}');
    for (final i in validation.issues) {
      b.writeln('- $i');
    }
    b
      ..writeln('')
      ..writeln('## Diff')
      ..writeln(diff.summary);
    for (final e in diff.entries) {
      b.writeln('- $e');
    }
    b
      ..writeln('')
      ..writeln('## Coverage delta')
      ..writeln(completeness.summary)
      ..writeln('')
      ..writeln('## Warnings');
    if (warnings.isEmpty) {
      b.writeln('- none');
    } else {
      for (final w in warnings) {
        b.writeln('- $w');
      }
    }
    b
      ..writeln('')
      ..writeln('## Ready for import')
      ..writeln(readyForImport ? 'YES' : 'NO');
    return b.toString().trimRight();
  }

  /// Build the full review report for a session. Deterministic.
  static ReviewReport build(
    KnowledgeExtractionSession session,
    CanonicalOntology ontology, {
    Iterable<AtomicKnowledgeUnit> baseline = const [],
    CanonCompletenessSpec spec = CanonCompletenessSpec.structural,
  }) {
    final baselineList = baseline.toList();
    final validation = WorkspaceValidator.validate(session, ontology,
        baseline: baselineList);
    final diff = KnowledgeDiff.compute(
        baseline: baselineList, incoming: session.units);
    final completeness = CompletenessDelta.forImport(
      baseline: baselineList,
      incoming: session.units,
      diff: diff,
      spec: spec,
    );
    final ready = validation.isValid && !diff.hasConflict;
    return ReviewReport(
      sessionId: session.id,
      state: session.state,
      unitCount: session.units.length,
      validation: validation,
      diff: diff,
      completeness: completeness,
      readyForImport: ready,
    );
  }
}
