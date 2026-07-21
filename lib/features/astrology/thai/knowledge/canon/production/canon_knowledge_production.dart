/// Canon Knowledge Production V1 — production tracker & report.
///
/// Content-tier (not platform): a thin, deterministic aggregator over the frozen
/// atomic + ontology + workspace layers. It measures how much real Canon
/// knowledge has been produced for the V1 foundational domains and proves the
/// production guarantees (atomic, ontology-resolved, registered relations, no
/// duplicates, provenance present). It creates **no** knowledge of its own.
///
/// Pure Dart; no Flutter/engine/runtime/matrix imports.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_extraction_rules.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/canon_completeness_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology_category.dart';

/// The V1 foundational production domains. Nothing else is in scope for V1
/// (no prediction rules, age rules, remedies or narrative).
enum ProductionDomain {
  planetLibrary,
  houseLibrary,
  planetMeanings,
  planetKeywords,
  planetDomains,
  planetElements;

  String get label => switch (this) {
        ProductionDomain.planetLibrary => 'Planet Library',
        ProductionDomain.houseLibrary => 'House Library',
        ProductionDomain.planetMeanings => 'Planet → Natural Meaning',
        ProductionDomain.planetKeywords => 'Planet → Keywords',
        ProductionDomain.planetDomains => 'Planet → Domain',
        ProductionDomain.planetElements => 'Planet → Element',
      };
}

enum ProductionStatus { unknown, partial, complete }

class ProductionDomainStat {
  const ProductionDomainStat({
    required this.domain,
    required this.produced,
    required this.verified,
    required this.subjectsCovered,
    this.target,
  });

  final ProductionDomain domain;

  /// Number of atomic knowledge units produced for this domain.
  final int produced;

  /// Of those, how many are verified (reference + non-zero confidence).
  final int verified;

  /// Distinct subjects (e.g. planets/houses) touched by this domain.
  final int subjectsCovered;

  /// Structural target where one exists (e.g. 9 planets, 12 houses); null when
  /// the domain is open-ended (meanings/keywords have no fixed count).
  final int? target;

  ProductionStatus get status {
    if (produced == 0 && subjectsCovered == 0) return ProductionStatus.unknown;
    if (target != null && subjectsCovered >= target!) {
      return ProductionStatus.complete;
    }
    return ProductionStatus.partial;
  }

  double? get coverage =>
      (target != null && target! > 0) ? subjectsCovered / target! : null;

  String get coverageLabel => coverage == null
      ? '—'
      : '${(coverage! * 100).toStringAsFixed(0)}% ($subjectsCovered/$target)';
}

class KnowledgeProductionReport {
  const KnowledgeProductionReport({
    required this.totalUnits,
    required this.allAtomic,
    required this.atomicIssues,
    required this.unitsWithProvenance,
    required this.completeness,
    required this.domains,
    required this.planetEntities,
    required this.houseEntities,
  });

  final int totalUnits;
  final bool allAtomic;
  final List<AtomicIssue> atomicIssues;
  final int unitsWithProvenance;
  final CanonCompletenessReport completeness;
  final List<ProductionDomainStat> domains;

  /// Structural scaffolding present in the ontology (entities, not claims).
  final int planetEntities;
  final int houseEntities;

  bool get provenanceComplete =>
      totalUnits == 0 ? true : unitsWithProvenance == totalUnits;

  ProductionDomainStat? domain(ProductionDomain d) {
    for (final s in domains) {
      if (s.domain == d) return s;
    }
    return null;
  }

  /// Deterministic, structured (non-narrative) rendering.
  String render() {
    final b = StringBuffer()
      ..writeln('# Canon Knowledge Production Report (V1)')
      ..writeln('total knowledge units: $totalUnits')
      ..writeln('all atomic: $allAtomic')
      ..writeln('units with provenance: $unitsWithProvenance/$totalUnits')
      ..writeln('ontology scaffolding: planets=$planetEntities houses=$houseEntities')
      ..writeln('')
      ..writeln('## Domains');
    for (final s in domains) {
      b.writeln('- ${s.domain.label}: ${s.status.name} '
          '(produced=${s.produced}, verified=${s.verified}, '
          'coverage=${s.coverageLabel})');
    }
    return b.toString().trimRight();
  }

  /// Build the production report from the set of *imported* atomic units and the
  /// ontology. Deterministic. With no imported units, every domain is Unknown.
  static KnowledgeProductionReport build(
    Iterable<AtomicKnowledgeUnit> importedUnits,
    CanonicalOntology ontology, {
    CanonCompletenessSpec spec = CanonCompletenessSpec.structural,
  }) {
    final units = importedUnits.toList();
    final atomicIssues = AtomicExtractionRules.validateAll(units);

    final domains = <ProductionDomainStat>[];
    for (final d in ProductionDomain.values) {
      final matched = units.where((u) => _belongs(d, u)).toList();
      final subjects = matched.map((u) => u.subject).toSet();
      domains.add(ProductionDomainStat(
        domain: d,
        produced: matched.length,
        verified: matched.where((u) => u.isVerified).length,
        subjectsCovered: subjects.length,
        target: _target(d),
      ));
    }

    return KnowledgeProductionReport(
      totalUnits: units.length,
      allAtomic: atomicIssues.isEmpty,
      atomicIssues: atomicIssues,
      unitsWithProvenance: units.where((u) => u.evidence.hasReference).length,
      completeness: CanonCompletenessReport.generate(units, spec: spec),
      domains: domains,
      planetEntities: ontology.entitiesOf(OntologyCategory.planet).length,
      houseEntities: ontology.entitiesOf(OntologyCategory.house).length,
    );
  }

  static int? _target(ProductionDomain d) => switch (d) {
        ProductionDomain.planetLibrary => 9,
        ProductionDomain.houseLibrary => 12,
        ProductionDomain.planetDomains => 9,
        ProductionDomain.planetElements => 9,
        // Open-ended: a planet may own many meanings/keywords.
        ProductionDomain.planetMeanings => null,
        ProductionDomain.planetKeywords => null,
      };

  static bool _belongs(ProductionDomain d, AtomicKnowledgeUnit u) {
    final planetSubject = u.subjectKind == AtomicEntityKind.planet;
    final houseSubject = u.subjectKind == AtomicEntityKind.house;
    return switch (d) {
      ProductionDomain.planetLibrary => planetSubject,
      ProductionDomain.houseLibrary => houseSubject,
      ProductionDomain.planetMeanings =>
        planetSubject && u.objectKind == AtomicEntityKind.meaning,
      ProductionDomain.planetKeywords =>
        planetSubject && u.objectKind == AtomicEntityKind.keyword,
      ProductionDomain.planetDomains =>
        planetSubject && u.objectKind == AtomicEntityKind.domain,
      ProductionDomain.planetElements =>
        planetSubject && u.objectKind == AtomicEntityKind.element,
    };
  }
}
