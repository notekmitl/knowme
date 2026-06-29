/// Canon Golden Dataset V1 — deterministic verifier.
///
/// Runs a [GoldenDataset] through the **real** Canon pipeline (the same
/// `WorkspaceValidator` / `KnowledgeDiff` / `CompletenessDelta` / `ReviewReport`
/// the workspace uses — no logic is reimplemented) and compares the observed
/// outcome against the dataset's declared expectation. The result is the Canon
/// Platform's regression signal. Deterministic; pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_graph.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/golden/golden_dataset.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_diff.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/review_report.dart';

/// The outcome observed by running the dataset through the pipeline.
class GoldenActual {
  const GoldenActual({
    required this.unitCount,
    required this.allResolved,
    required this.unresolvedTokens,
    required this.graphNodes,
    required this.graphEdges,
    required this.valid,
    required this.errorCodes,
    required this.diff,
    required this.readyForImport,
    required this.totalUnitsDelta,
    required this.verifiedRelationshipsDelta,
    required this.review,
  });

  final int unitCount;
  final bool allResolved;
  final List<String> unresolvedTokens;
  final int graphNodes;
  final int graphEdges;
  final bool valid;
  final Set<String> errorCodes;
  final Map<DiffKind, int> diff;
  final bool readyForImport;
  final int totalUnitsDelta;
  final int verifiedRelationshipsDelta;

  /// The full review report (reused for the reports layer; never reimplemented).
  final ReviewReport review;

  int diffCount(DiffKind kind) => diff[kind] ?? 0;
}

class GoldenMismatch {
  const GoldenMismatch(this.field, this.expected, this.actual);
  final String field;
  final String expected;
  final String actual;

  @override
  String toString() => '$field: expected $expected, got $actual';
}

class GoldenVerification {
  const GoldenVerification(this.datasetId, this.versionTag, this.actual, this.mismatches);

  final String datasetId;
  final String versionTag;
  final GoldenActual actual;
  final List<GoldenMismatch> mismatches;

  bool get passed => mismatches.isEmpty;
}

abstract final class GoldenVerifier {
  /// Run [d] through the real pipeline. Deterministic.
  static GoldenActual run(GoldenDataset d) {
    final ontology = d.ontology();
    final session = d.session();
    final review = ReviewReport.build(session, ontology, baseline: d.baseline);
    final graph = AtomicKnowledgeGraph.build(session.units);

    final unresolved = <String>[];
    for (final u in session.sortedUnits) {
      if (!_resolves(ontology, u.subject)) unresolved.add(u.subject);
      if (!_resolves(ontology, u.object)) unresolved.add(u.object);
    }
    final unresolvedSorted = unresolved.toSet().toList()..sort();

    return GoldenActual(
      unitCount: session.units.length,
      allResolved: unresolvedSorted.isEmpty,
      unresolvedTokens: unresolvedSorted,
      graphNodes: graph.nodeCount,
      graphEdges: graph.edgeCount,
      valid: review.validation.isValid,
      errorCodes: review.validation.errors.map((e) => e.code).toSet(),
      diff: {
        for (final k in DiffKind.values)
          if (review.diff.count(k) != 0) k: review.diff.count(k),
      },
      readyForImport: review.readyForImport,
      totalUnitsDelta: review.completeness.totalUnitsDelta,
      verifiedRelationshipsDelta: review.completeness.verifiedRelationshipsDelta,
      review: review,
    );
  }

  /// Run and compare against the declared expectation. Deterministic; mismatches
  /// are returned in a stable field order.
  static GoldenVerification verify(GoldenDataset d) {
    final a = run(d);
    final e = d.expected;
    final m = <GoldenMismatch>[];
    void check(String field, Object expected, Object actual) {
      if (expected.toString() != actual.toString()) {
        m.add(GoldenMismatch(field, expected.toString(), actual.toString()));
      }
    }

    check('unitCount', e.unitCount, a.unitCount);
    check('allResolved', e.allResolved, a.allResolved);
    check('graphNodes', e.graphNodes, a.graphNodes);
    check('graphEdges', e.graphEdges, a.graphEdges);
    check('valid', e.valid, a.valid);
    check('errorCodes', _sorted(e.errorCodes), _sorted(a.errorCodes));
    for (final k in DiffKind.values) {
      check('diff.${k.name}', e.diffCount(k), a.diffCount(k));
    }
    check('readyForImport', e.readyForImport, a.readyForImport);
    check('totalUnitsDelta', e.totalUnitsDelta, a.totalUnitsDelta);
    check('verifiedRelationshipsDelta', e.verifiedRelationshipsDelta,
        a.verifiedRelationshipsDelta);

    return GoldenVerification(d.id, d.versionTag, a, m);
  }

  static List<String> _sorted(Set<String> s) => s.toList()..sort();

  static bool _resolves(CanonicalOntology ontology, String token) =>
      ontology.entity(token) != null || ontology.canResolve(token);

  /// Convenience: true iff [d] reproduces its expectation exactly.
  static bool passes(GoldenDataset d) => verify(d).passed;
}
