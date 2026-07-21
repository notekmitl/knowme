/// Mahabhut Ingestion Toolchain V1 — Canon QA Tools.
///
/// Standalone reports over a candidate store: Missing Citation, Duplicate Rule,
/// Orphan Rule, Broken Cross Reference, Empty Concept. Pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';

class CanonQaFinding {
  const CanonQaFinding(this.candidateId, this.detail);
  final String candidateId;
  final String detail;
}

class CanonQaReport {
  const CanonQaReport(this.name, this.findings);
  final String name;
  final List<CanonQaFinding> findings;

  bool get isClean => findings.isEmpty;
  int get count => findings.length;

  @override
  String toString() => '$name: ${findings.length} finding(s)';
}

abstract final class CanonQaTools {
  static CanonQaReport missingCitation(CanonCandidateStore store) =>
      CanonQaReport('Missing Citation', [
        for (final c in store.candidates)
          if (!c.hasCitation || !c.hasPage)
            CanonQaFinding(
                c.id,
                'quote=${c.hasCitation ? 'ok' : 'missing'}, '
                'page=${c.hasPage ? 'ok' : 'missing'}'),
      ]);

  static CanonQaReport duplicateRule(CanonCandidateStore store) {
    final seen = <String, String>{};
    final findings = <CanonQaFinding>[];
    for (final c in store.candidates) {
      if (c.type != CanonUnitType.rule) continue;
      final key = '${c.subjectKey}|${c.statement.trim()}';
      final prior = seen[key];
      if (prior != null) {
        findings.add(CanonQaFinding(c.id, 'duplicate rule of "$prior"'));
      } else {
        seen[key] = c.id;
      }
    }
    return CanonQaReport('Duplicate Rule', findings);
  }

  /// Rules that neither point to anything nor are pointed at — isolated.
  static CanonQaReport orphanRule(CanonCandidateStore store) {
    final referenced = <String>{};
    for (final c in store.candidates) {
      for (final x in c.crossRefs) {
        referenced.add(x.toId);
      }
    }
    final findings = <CanonQaFinding>[];
    for (final c in store.candidates) {
      if (c.type != CanonUnitType.rule) continue;
      final pointsOut = c.crossRefs.isNotEmpty;
      final pointedAt = referenced.contains(c.id);
      if (!pointsOut && !pointedAt) {
        findings.add(CanonQaFinding(c.id, 'rule has no cross-references'));
      }
    }
    return CanonQaReport('Orphan Rule', findings);
  }

  static CanonQaReport brokenCrossReference(
    CanonCandidateStore store, {
    Set<String> knownIds = const {},
  }) {
    final ids = {...store.candidates.map((c) => c.id), ...knownIds};
    final findings = <CanonQaFinding>[];
    for (final c in store.candidates) {
      for (final x in c.crossRefs) {
        if (!ids.contains(x.toId)) {
          findings.add(CanonQaFinding(c.id, 'target "${x.toId}" not found'));
        }
      }
    }
    return CanonQaReport('Broken Cross Reference', findings);
  }

  static CanonQaReport emptyConcept(CanonCandidateStore store) =>
      CanonQaReport('Empty Concept', [
        for (final c in store.candidates)
          if (c.type == CanonUnitType.concept && c.statement.trim().isEmpty)
            CanonQaFinding(c.id, 'concept has no statement'),
      ]);

  /// Run all reports.
  static List<CanonQaReport> all(
    CanonCandidateStore store, {
    Set<String> knownIds = const {},
  }) =>
      [
        missingCitation(store),
        duplicateRule(store),
        orphanRule(store),
        brokenCrossReference(store, knownIds: knownIds),
        emptyConcept(store),
      ];
}
