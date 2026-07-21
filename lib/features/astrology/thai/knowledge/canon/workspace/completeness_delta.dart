/// Canon Knowledge Extraction Workspace V4 — completeness integration.
///
/// Every import updates the Canon Completeness Report. This computes the
/// deterministic delta between the report *before* and *after* applying a
/// session's diff, so reviewers immediately see coverage change, new unknowns and
/// newly verified knowledge. Pure Dart over the atomic completeness layer.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/canon_completeness_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_diff.dart';

class DomainCoverageDelta {
  const DomainCoverageDelta({
    required this.domain,
    required this.presentBefore,
    required this.presentAfter,
  });

  final KnowledgeDomain domain;
  final int presentBefore;
  final int presentAfter;

  int get delta => presentAfter - presentBefore;
  bool get increased => delta > 0;
}

class CompletenessDelta {
  const CompletenessDelta({
    required this.before,
    required this.after,
    required this.domains,
  });

  final CanonCompletenessReport before;
  final CanonCompletenessReport after;
  final List<DomainCoverageDelta> domains;

  int get totalUnitsDelta => after.totalUnits - before.totalUnits;
  int get verifiedRelationshipsDelta =>
      after.verifiedRelationships - before.verifiedRelationships;

  /// Positive when more relationships are now verified (unknowns shrink);
  /// negative if new unknowns appear.
  int get unknownRelationshipsDelta =>
      after.unknownRelationships - before.unknownRelationships;

  bool get coverageIncreased =>
      after.unitsWithEvidence > before.unitsWithEvidence ||
      totalUnitsDelta > 0 ||
      verifiedRelationshipsDelta > 0;

  String get summary {
    final b = StringBuffer()
      ..writeln('Units: ${before.totalUnits} → ${after.totalUnits} '
          '(${_signed(totalUnitsDelta)})')
      ..writeln('Verified relationships: ${before.verifiedRelationships} → '
          '${after.verifiedRelationships} (${_signed(verifiedRelationshipsDelta)})')
      ..writeln('Unknown relationships: ${before.unknownRelationships} → '
          '${after.unknownRelationships} (${_signed(unknownRelationshipsDelta)})');
    for (final d in domains.where((d) => d.delta != 0)) {
      b.writeln('${d.domain.label}: ${d.presentBefore} → ${d.presentAfter} '
          '(${_signed(d.delta)})');
    }
    return b.toString().trimRight();
  }

  /// Apply a session [diff] to the [baseline] and compute the completeness delta.
  /// NEW + UPDATED units replace/add by id; DEPRECATED units are removed;
  /// UNCHANGED units stay. Deterministic.
  static CompletenessDelta forImport({
    required Iterable<AtomicKnowledgeUnit> baseline,
    required Iterable<AtomicKnowledgeUnit> incoming,
    required KnowledgeDiff diff,
    CanonCompletenessSpec spec = CanonCompletenessSpec.structural,
  }) {
    final beforeUnits = baseline.toList();
    final beforeReport = CanonCompletenessReport.generate(beforeUnits, spec: spec);

    final incomingById = {for (final u in incoming) u.id: u};
    final afterById = {for (final u in beforeUnits) u.id: u};
    for (final e in diff.entries) {
      switch (e.kind) {
        case DiffKind.added:
        case DiffKind.updated:
          final u = incomingById[e.unitId];
          if (u != null) afterById[e.unitId] = u;
        case DiffKind.deprecated:
          afterById.remove(e.unitId);
        case DiffKind.conflict:
        case DiffKind.unchanged:
          break; // conflicts are NOT applied; unchanged already present
      }
    }
    final afterReport =
        CanonCompletenessReport.generate(afterById.values, spec: spec);

    final beforeByDomain = _present(beforeUnits);
    final afterByDomain = _present(afterById.values);
    final domainKeys = <KnowledgeDomain>{
      ...beforeByDomain.keys,
      ...afterByDomain.keys,
    }.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final domains = [
      for (final d in domainKeys)
        DomainCoverageDelta(
          domain: d,
          presentBefore: beforeByDomain[d] ?? 0,
          presentAfter: afterByDomain[d] ?? 0,
        ),
    ];

    return CompletenessDelta(
        before: beforeReport, after: afterReport, domains: domains);
  }

  static Map<KnowledgeDomain, int> _present(Iterable<AtomicKnowledgeUnit> units) {
    final m = <KnowledgeDomain, int>{};
    for (final u in units) {
      m[u.domain] = (m[u.domain] ?? 0) + 1;
    }
    return m;
  }

  static String _signed(int v) => v >= 0 ? '+$v' : '$v';
}
