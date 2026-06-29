/// Canon Atomic Knowledge V2 — Canon Completeness Report.
///
/// Measures how complete the knowledge base is, **by knowledge domain** (never by
/// file count). Deterministic: the same units + spec always yield the same
/// report. Pure Dart; no Flutter/engine/runtime imports.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';

/// Domain-based targets used to compute coverage. Targets are *structural*
/// counts (e.g. number of planets), not fabricated astrology knowledge.
class CanonCompletenessSpec {
  const CanonCompletenessSpec({
    required this.domainTargets,
    required this.relationshipPairTarget,
  });

  /// Expected number of atomic units per domain (the denominator for coverage).
  final Map<KnowledgeDomain, int> domainTargets;

  /// Expected number of distinct directed planet-relationship pairs.
  final int relationshipPairTarget;

  /// A default structural spec. The numbers count *structures* (9 grahas,
  /// 12 bhāvas, 12 rāśis, 9×8 directed planet pairs), not interpreted meanings.
  static const CanonCompletenessSpec structural = CanonCompletenessSpec(
    domainTargets: {
      KnowledgeDomain.planetLibrary: 9,
      KnowledgeDomain.houseLibrary: 12,
      KnowledgeDomain.signLibrary: 12,
      KnowledgeDomain.planetRelationships: 72,
      KnowledgeDomain.aspects: 9,
      KnowledgeDomain.remedies: 9,
      KnowledgeDomain.lifePeriodRules: 9,
    },
    relationshipPairTarget: 72,
  );
}

class CanonDomainCoverage {
  const CanonDomainCoverage({
    required this.domain,
    required this.present,
    required this.expected,
    required this.verified,
  });

  final KnowledgeDomain domain;
  final int present;
  final int expected;
  final int verified;

  double get coverage {
    if (expected <= 0) return present > 0 ? 1.0 : 0.0;
    final c = present / expected;
    return c > 1.0 ? 1.0 : c;
  }

  String get percent => '${(coverage * 100).toStringAsFixed(0)}%';
}

/// A deterministic completeness snapshot.
class CanonCompletenessReport {
  const CanonCompletenessReport({
    required this.totalUnits,
    required this.atomicUnits,
    required this.unitsWithEvidence,
    required this.verifiedRelationships,
    required this.unknownRelationships,
    required this.domains,
  });

  final int totalUnits;
  final int atomicUnits;
  final int unitsWithEvidence;
  final int verifiedRelationships;
  final int unknownRelationships;

  /// Per-domain coverage, sorted by domain enum order (deterministic).
  final List<CanonDomainCoverage> domains;

  double get evidenceCoverage =>
      totalUnits == 0 ? 0 : unitsWithEvidence / totalUnits;

  CanonDomainCoverage? domain(KnowledgeDomain d) {
    for (final c in domains) {
      if (c.domain == d) return c;
    }
    return null;
  }

  String get summary {
    final b = StringBuffer();
    for (final c in domains) {
      b.writeln('${c.domain.label}: ${c.percent} (${c.present}/${c.expected})');
    }
    b.writeln('Evidence Coverage: ${(evidenceCoverage * 100).toStringAsFixed(0)}%');
    b.writeln('Verified Relationships: $verifiedRelationships');
    b.writeln('Unknown Relationships: $unknownRelationships');
    return b.toString().trimRight();
  }

  /// Generate a report from atomic units against a [spec]. Deterministic.
  static CanonCompletenessReport generate(
    Iterable<AtomicKnowledgeUnit> units, {
    CanonCompletenessSpec spec = CanonCompletenessSpec.structural,
  }) {
    final list = units.toList();

    final byDomain = <KnowledgeDomain, List<AtomicKnowledgeUnit>>{};
    for (final u in list) {
      byDomain.putIfAbsent(u.domain, () => []).add(u);
    }

    // Domains sorted by enum order for determinism. Include every domain that
    // either has a target or has present units.
    final domainKeys = <KnowledgeDomain>{
      ...spec.domainTargets.keys,
      ...byDomain.keys,
    }.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final domains = <CanonDomainCoverage>[];
    for (final d in domainKeys) {
      final present = byDomain[d]?.length ?? 0;
      final verified =
          byDomain[d]?.where((u) => u.isVerified).length ?? 0;
      domains.add(CanonDomainCoverage(
        domain: d,
        present: present,
        expected: spec.domainTargets[d] ?? 0,
        verified: verified,
      ));
    }

    // Relationship metrics: distinct verified directed pairs vs target.
    final relUnits = list
        .where((u) => u.domain == KnowledgeDomain.planetRelationships)
        .toList();
    final verifiedPairs = relUnits
        .where((u) => u.isVerified)
        .map((u) => '${u.subject}->${u.object}')
        .toSet();
    final verifiedRelationships = verifiedPairs.length;
    final unknownRelationships =
        (spec.relationshipPairTarget - verifiedRelationships)
            .clamp(0, spec.relationshipPairTarget);

    return CanonCompletenessReport(
      totalUnits: list.length,
      atomicUnits: list.length,
      unitsWithEvidence: list.where((u) => u.evidence.hasReference).length,
      verifiedRelationships: verifiedRelationships,
      unknownRelationships: unknownRelationships,
      domains: domains,
    );
  }
}
