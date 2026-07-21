/// Canon Golden Dataset V1 — the official QA catalog.
///
/// Synthetic regression fixtures for the Canon Platform. **No copyrighted book
/// text and no invented astrology facts** — entities are structural placeholders
/// drawn from the standard ontology (planets/houses/elements/domains) plus a few
/// clearly-synthetic tokens (e.g. `planet.nibiru`) used only to drive negative
/// cases. Each dataset declares the exact pipeline outcome it must reproduce.
///
/// Pure Dart over the atomic + ontology + workspace layers.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/golden/golden_dataset.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/extraction_source.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_diff.dart';

abstract final class GoldenDatasets {
  static const ExtractionSource _source = ExtractionSource(
    bookId: 'golden',
    edition: 'qa',
    chapter: 'qa',
    pageStart: 1,
    pageEnd: 1,
    reviewer: 'golden.qa',
    extractionDate: '2026-06-29',
  );

  /// All golden datasets, deterministically ordered by id.
  static List<GoldenDataset> all() {
    final list = [
      minimal(),
      singlePlanet(),
      singleHouse(),
      planetHouse(),
      conflict(),
      duplicate(),
      ontologyFailure(),
      relationshipFailure(),
      coverageIncrease(),
      deprecated(),
    ];
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  static GoldenDataset? byId(String id) {
    for (final d in all()) {
      if (d.id == id) return d;
    }
    return null;
  }

  // ---- Helpers -----------------------------------------------------------

  static AtomicKnowledgeUnit _u({
    required String id,
    required AtomicEntityKind sk,
    required String s,
    required AtomicRelation r,
    required AtomicEntityKind ok,
    required String o,
    KnowledgeDomain domain = KnowledgeDomain.planetLibrary,
    String? condition,
    KnowledgeConfidence confidence = KnowledgeConfidence.medium,
  }) =>
      AtomicKnowledgeUnit(
        id: id,
        subject: s,
        subjectKind: sk,
        relation: r,
        object: o,
        objectKind: ok,
        domain: domain,
        condition: condition,
        confidence: confidence,
        evidence: const AtomicEvidenceRef(
            bookId: 'golden', chapter: 'qa', page: '1'),
      );

  // ---- Datasets ----------------------------------------------------------

  /// 1 · Minimal — the smallest corpus (empty session): nothing to import.
  static GoldenDataset minimal() => GoldenDataset(
        id: 'golden.minimal',
        description: 'Empty session — smallest corpus; nothing to import.',
        version: 1,
        sourceType: GoldenSourceType.syntheticValid,
        source: _source,
        units: const [],
        expected: const GoldenExpectation(
          unitCount: 0,
          allResolved: true,
          graphNodes: 0,
          graphEdges: 0,
          valid: true,
          errorCodes: {},
          diff: {},
          readyForImport: true,
          totalUnitsDelta: 0,
          verifiedRelationshipsDelta: 0,
        ),
      );

  /// 2 · Single Planet — several atomic facts about one planet.
  static GoldenDataset singlePlanet() => GoldenDataset(
        id: 'golden.single_planet',
        description: 'Three atomic facts about one planet (Jupiter).',
        version: 1,
        sourceType: GoldenSourceType.syntheticValid,
        source: _source,
        units: [
          _u(
              id: 'sp-1',
              sk: AtomicEntityKind.planet,
              s: 'planet.jupiter',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.finance'),
          _u(
              id: 'sp-2',
              sk: AtomicEntityKind.planet,
              s: 'planet.jupiter',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.element,
              o: 'element.fire'),
          _u(
              id: 'sp-3',
              sk: AtomicEntityKind.planet,
              s: 'planet.jupiter',
              r: AtomicRelation.locatedIn,
              ok: AtomicEntityKind.house,
              o: 'house.9'),
        ],
        expected: const GoldenExpectation(
          unitCount: 3,
          allResolved: true,
          graphNodes: 4,
          graphEdges: 3,
          valid: true,
          errorCodes: {},
          diff: {DiffKind.added: 3},
          readyForImport: true,
          totalUnitsDelta: 3,
          verifiedRelationshipsDelta: 0,
        ),
      );

  /// 3 · Single House — atomic facts about one house.
  static GoldenDataset singleHouse() => GoldenDataset(
        id: 'golden.single_house',
        description: 'Two atomic facts about one house (House 2).',
        version: 1,
        sourceType: GoldenSourceType.syntheticValid,
        source: _source,
        units: [
          _u(
              id: 'sh-1',
              sk: AtomicEntityKind.house,
              s: 'house.2',
              r: AtomicRelation.belongsTo,
              ok: AtomicEntityKind.domain,
              o: 'domain.finance',
              domain: KnowledgeDomain.houseLibrary),
          _u(
              id: 'sh-2',
              sk: AtomicEntityKind.house,
              s: 'house.2',
              r: AtomicRelation.belongsTo,
              ok: AtomicEntityKind.domain,
              o: 'domain.family',
              domain: KnowledgeDomain.houseLibrary),
        ],
        expected: const GoldenExpectation(
          unitCount: 2,
          allResolved: true,
          graphNodes: 3,
          graphEdges: 2,
          valid: true,
          errorCodes: {},
          diff: {DiffKind.added: 2},
          readyForImport: true,
          totalUnitsDelta: 2,
          verifiedRelationshipsDelta: 0,
        ),
      );

  /// 4 · Planet + House — a small mixed corpus.
  static GoldenDataset planetHouse() => GoldenDataset(
        id: 'golden.planet_house',
        description: 'A planet fact and a house fact in one session.',
        version: 1,
        sourceType: GoldenSourceType.syntheticValid,
        source: _source,
        units: [
          _u(
              id: 'ph-1',
              sk: AtomicEntityKind.planet,
              s: 'planet.mars',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.career'),
          _u(
              id: 'ph-2',
              sk: AtomicEntityKind.house,
              s: 'house.10',
              r: AtomicRelation.belongsTo,
              ok: AtomicEntityKind.domain,
              o: 'domain.career',
              domain: KnowledgeDomain.houseLibrary),
        ],
        expected: const GoldenExpectation(
          unitCount: 2,
          allResolved: true,
          graphNodes: 3,
          graphEdges: 2,
          valid: true,
          errorCodes: {},
          diff: {DiffKind.added: 2},
          readyForImport: true,
          totalUnitsDelta: 2,
          verifiedRelationshipsDelta: 0,
        ),
      );

  /// 5 · Conflict — incoming overwrites an existing fact under the same id
  /// (a diff CONFLICT). Canon is never overwritten blindly → not import-ready.
  static GoldenDataset conflict() => GoldenDataset(
        id: 'golden.conflict',
        description: 'Same unit id changes the fact vs. baseline → CONFLICT.',
        version: 1,
        sourceType: GoldenSourceType.syntheticInvalid,
        source: _source,
        baseline: [
          _u(
              id: 'cf-1',
              sk: AtomicEntityKind.planet,
              s: 'planet.mars',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.career'),
        ],
        units: [
          _u(
              id: 'cf-1',
              sk: AtomicEntityKind.planet,
              s: 'planet.mars',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.health'),
        ],
        expected: const GoldenExpectation(
          unitCount: 1,
          allResolved: true,
          graphNodes: 2,
          graphEdges: 1,
          valid: true,
          errorCodes: {},
          diff: {DiffKind.conflict: 1},
          readyForImport: false,
          totalUnitsDelta: 0,
          verifiedRelationshipsDelta: 0,
        ),
      );

  /// 6 · Duplicate — two ids assert the same fact → duplicate knowledge + a
  /// duplicate graph edge.
  static GoldenDataset duplicate() => GoldenDataset(
        id: 'golden.duplicate',
        description: 'Two units assert the same fact under different ids.',
        version: 1,
        sourceType: GoldenSourceType.syntheticInvalid,
        source: _source,
        units: [
          _u(
              id: 'dp-1',
              sk: AtomicEntityKind.planet,
              s: 'planet.venus',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.relationship'),
          _u(
              id: 'dp-2',
              sk: AtomicEntityKind.planet,
              s: 'planet.venus',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.relationship'),
        ],
        expected: const GoldenExpectation(
          unitCount: 2,
          allResolved: true,
          graphNodes: 2,
          graphEdges: 2,
          valid: false,
          errorCodes: {'duplicate_knowledge', 'graph_duplicate_edge'},
          diff: {DiffKind.added: 2},
          readyForImport: false,
          totalUnitsDelta: 2,
          verifiedRelationshipsDelta: 0,
        ),
      );

  /// 7 · Ontology Failure — a subject that is not in the ontology (a synthetic
  /// placeholder token, not an astrology claim).
  static GoldenDataset ontologyFailure() => GoldenDataset(
        id: 'golden.ontology_failure',
        description: 'Unresolved subject token (synthetic placeholder).',
        version: 1,
        sourceType: GoldenSourceType.syntheticInvalid,
        source: _source,
        units: [
          _u(
              id: 'of-1',
              sk: AtomicEntityKind.planet,
              s: 'planet.nibiru',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.finance'),
        ],
        expected: const GoldenExpectation(
          unitCount: 1,
          allResolved: false,
          graphNodes: 2,
          graphEdges: 1,
          valid: false,
          errorCodes: {'ontology_unresolved_subject'},
          diff: {DiffKind.added: 1},
          readyForImport: false,
          totalUnitsDelta: 1,
          verifiedRelationshipsDelta: 0,
        ),
      );

  /// 8 · Relationship Failure — a relationship the ontology does not register.
  /// Built against a custom ontology missing `opposes` (we never mutate the
  /// shared ontology to create a failure).
  static GoldenDataset relationshipFailure() {
    final rels = [...CanonOntologyData.relationships]..remove('opposes');
    final ontology = CanonicalOntology.build(
      entities: CanonOntologyData.allEntities(),
      relationships: rels,
    );
    return GoldenDataset(
      id: 'golden.relationship_failure',
      description: 'Relationship not registered in the (custom) ontology.',
      version: 1,
      sourceType: GoldenSourceType.syntheticInvalid,
      source: _source,
      ontology: ontology,
      units: [
        _u(
            id: 'rf-1',
            sk: AtomicEntityKind.planet,
            s: 'planet.mars',
            r: AtomicRelation.opposes,
            ok: AtomicEntityKind.planet,
            o: 'planet.saturn'),
      ],
      expected: const GoldenExpectation(
        unitCount: 1,
        allResolved: true,
        graphNodes: 2,
        graphEdges: 1,
        valid: false,
        errorCodes: {'relationship_not_registered'},
        diff: {DiffKind.added: 1},
        readyForImport: false,
        totalUnitsDelta: 1,
        verifiedRelationshipsDelta: 0,
      ),
    );
  }

  /// 9 · Coverage Increase — two verified planet-relationship facts; completeness
  /// (verified relationships) increases deterministically.
  static GoldenDataset coverageIncrease() => GoldenDataset(
        id: 'golden.coverage_increase',
        description: 'Two verified planet relationships increase coverage.',
        version: 1,
        sourceType: GoldenSourceType.syntheticValid,
        source: _source,
        units: [
          _u(
              id: 'ci-1',
              sk: AtomicEntityKind.planet,
              s: 'planet.jupiter',
              r: AtomicRelation.supports,
              ok: AtomicEntityKind.planet,
              o: 'planet.venus',
              domain: KnowledgeDomain.planetRelationships,
              confidence: KnowledgeConfidence.high),
          _u(
              id: 'ci-2',
              sk: AtomicEntityKind.planet,
              s: 'planet.venus',
              r: AtomicRelation.supports,
              ok: AtomicEntityKind.planet,
              o: 'planet.jupiter',
              domain: KnowledgeDomain.planetRelationships,
              confidence: KnowledgeConfidence.high),
        ],
        expected: const GoldenExpectation(
          unitCount: 2,
          allResolved: true,
          graphNodes: 2,
          graphEdges: 2,
          valid: true,
          errorCodes: {},
          diff: {DiffKind.added: 2},
          readyForImport: true,
          totalUnitsDelta: 2,
          verifiedRelationshipsDelta: 2,
        ),
      );

  /// 10 · Deprecated Knowledge — a baseline fact absent from the incoming session
  /// is DEPRECATED; the remaining one is UNCHANGED.
  static GoldenDataset deprecated() => GoldenDataset(
        id: 'golden.deprecated',
        description: 'A baseline fact is dropped (DEPRECATED); another UNCHANGED.',
        version: 1,
        sourceType: GoldenSourceType.syntheticValid,
        source: _source,
        baseline: [
          _u(
              id: 'dk-keep',
              sk: AtomicEntityKind.planet,
              s: 'planet.saturn',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.career'),
          _u(
              id: 'dk-drop',
              sk: AtomicEntityKind.planet,
              s: 'planet.saturn',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.health'),
        ],
        units: [
          _u(
              id: 'dk-keep',
              sk: AtomicEntityKind.planet,
              s: 'planet.saturn',
              r: AtomicRelation.owns,
              ok: AtomicEntityKind.domain,
              o: 'domain.career'),
        ],
        expected: const GoldenExpectation(
          unitCount: 1,
          allResolved: true,
          graphNodes: 2,
          graphEdges: 1,
          valid: true,
          errorCodes: {},
          diff: {DiffKind.unchanged: 1, DiffKind.deprecated: 1},
          readyForImport: true,
          totalUnitsDelta: -1,
          verifiedRelationshipsDelta: 0,
        ),
      );
}
