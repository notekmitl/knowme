/// Canon Golden Dataset V1 — deterministic reports.
///
/// Structured, non-narrative renderings of golden verification: per-dataset
/// (metadata + ontology coverage + graph shape + validation + diff + completeness
/// + import verdict + expectation result) and a catalog regression summary. All
/// rendering reuses the workspace `ReviewReport`; nothing is reimplemented.
/// Deterministic; pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/golden/golden_dataset.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/golden/golden_verifier.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_diff.dart';

abstract final class GoldenReport {
  /// Full deterministic report for a single dataset.
  static String forDataset(GoldenDataset d) {
    final v = GoldenVerifier.verify(d);
    final a = v.actual;
    final b = StringBuffer()
      ..writeln('# Golden Dataset Report')
      ..writeln('dataset: ${d.id}')
      ..writeln('version: ${d.versionTag}')
      ..writeln('fingerprint: ${d.fingerprint}')
      ..writeln('sourceType: ${d.sourceType.name}')
      ..writeln('description: ${d.description}')
      ..writeln('')
      ..writeln('## Ontology coverage')
      ..writeln('allResolved: ${a.allResolved}');
    if (a.unresolvedTokens.isNotEmpty) {
      b.writeln('unresolved: ${a.unresolvedTokens.join(', ')}');
    }
    b
      ..writeln('')
      ..writeln('## Graph shape')
      ..writeln('nodes: ${a.graphNodes}  edges: ${a.graphEdges}')
      ..writeln('')
      // Validation + Diff + Coverage delta + Ready-for-import, from the real
      // workspace review report (no duplicated rendering).
      ..writeln(a.review.render())
      ..writeln('')
      ..writeln('## Completeness')
      ..writeln('totalUnitsDelta: ${a.totalUnitsDelta}  '
          'verifiedRelationshipsDelta: ${a.verifiedRelationshipsDelta}')
      ..writeln('')
      ..writeln('## Expectation')
      ..writeln(v.passed ? 'PASS' : 'FAIL');
    for (final m in v.mismatches) {
      b.writeln('- $m');
    }
    return b.toString().trimRight();
  }

  /// Validation-only view.
  static String validationReport(GoldenDataset d) =>
      GoldenVerifier.run(d).review.validation.issues.map((i) => '$i').join('\n');

  /// Diff-only view.
  static String diffReport(GoldenDataset d) {
    final diff = GoldenVerifier.run(d).review.diff;
    final b = StringBuffer()..writeln(diff.summary);
    for (final e in diff.entries) {
      b.writeln('- $e');
    }
    return b.toString().trimRight();
  }

  /// Coverage / completeness-only view.
  static String coverageReport(GoldenDataset d) =>
      GoldenVerifier.run(d).review.completeness.summary;

  /// Import-result view.
  static String importReport(GoldenDataset d) {
    final a = GoldenVerifier.run(d);
    return 'readyForImport: ${a.readyForImport}\n'
        'NEW ${a.diffCount(DiffKind.added)}  '
        'UPDATED ${a.diffCount(DiffKind.updated)}  '
        'UNCHANGED ${a.diffCount(DiffKind.unchanged)}  '
        'CONFLICT ${a.diffCount(DiffKind.conflict)}  '
        'DEPRECATED ${a.diffCount(DiffKind.deprecated)}';
  }

  /// Deterministic regression summary over a whole catalog (sorted by id).
  static String forCatalog(List<GoldenDataset> datasets) {
    final sorted = [...datasets]..sort((a, b) => a.id.compareTo(b.id));
    final verifications = [for (final d in sorted) GoldenVerifier.verify(d)];
    final passed = verifications.where((v) => v.passed).length;
    final b = StringBuffer()
      ..writeln('# Golden Catalog Report')
      ..writeln('datasets: ${sorted.length}  '
          'passed: $passed  failed: ${sorted.length - passed}')
      ..writeln('');
    for (var i = 0; i < sorted.length; i++) {
      final d = sorted[i];
      final v = verifications[i];
      b.writeln('${v.passed ? 'PASS' : 'FAIL'} ${d.versionTag} '
          '[${d.fingerprint}] ${d.sourceType.name}');
      for (final m in v.mismatches) {
        b.writeln('    - $m');
      }
    }
    return b.toString().trimRight();
  }

  /// True iff every dataset reproduces its expectation exactly.
  static bool catalogPasses(List<GoldenDataset> datasets) =>
      datasets.every(GoldenVerifier.passes);
}
