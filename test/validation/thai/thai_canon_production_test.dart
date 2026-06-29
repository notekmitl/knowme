import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/production/production.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/workspace.dart';

/// Canon Knowledge Production V1. These tests use **fixtures** to prove the
/// production guarantees end-to-end; they are NOT real Canon knowledge. The real
/// Canon knowledge base stays Unknown until the source book is provided — facts
/// are never invented. Pure knowledge layer; no engine/runtime dependency.

final _ontology = CanonOntologyData.standard();

AtomicKnowledgeUnit _u(
  String id,
  String subject,
  AtomicRelation rel,
  String object, {
  AtomicEntityKind subjectKind = AtomicEntityKind.planet,
  AtomicEntityKind objectKind = AtomicEntityKind.domain,
  KnowledgeDomain domain = KnowledgeDomain.planetLibrary,
  KnowledgeConfidence confidence = KnowledgeConfidence.high,
  AtomicEvidenceRef? evidence,
}) =>
    AtomicKnowledgeUnit(
      id: id,
      subject: subject,
      subjectKind: subjectKind,
      relation: rel,
      object: object,
      objectKind: objectKind,
      domain: domain,
      confidence: confidence,
      evidence: evidence ??
          const AtomicEvidenceRef(bookId: 'mahabhut', chapter: '2', page: '40'),
    );

/// A small, fully ontology-resolved fixture set (uses canonical ids that exist
/// in the standard ontology).
List<AtomicKnowledgeUnit> _fixture() => [
      _u('f1', 'planet.jupiter', AtomicRelation.owns, 'domain.finance',
          objectKind: AtomicEntityKind.domain),
      _u('f2', 'planet.jupiter', AtomicRelation.relatesTo, 'element.fire',
          objectKind: AtomicEntityKind.element),
      _u('f3', 'planet.sun', AtomicRelation.owns, 'domain.career',
          objectKind: AtomicEntityKind.domain),
    ];

void main() {
  group('Real Canon knowledge base is empty (no fabrication)', () {
    test('source text is absent — only the drop-folder README exists', () {
      final dir = Directory('knowledge/canon/sources/mahabhut');
      final files =
          dir.listSync().whereType<File>().map((f) => f.uri.pathSegments.last);
      expect(files, contains('README.md'));
      expect(files.where((n) => n != 'README.md'), isEmpty,
          reason: 'no source chapters present — knowledge must stay Unknown');
    });

    test('production report over an empty import is all-Unknown but valid', () {
      final report = KnowledgeProductionReport.build(const [], _ontology);
      expect(report.totalUnits, 0);
      expect(report.allAtomic, isTrue);
      expect(report.provenanceComplete, isTrue);
      for (final d in ProductionDomain.values) {
        expect(report.domain(d)!.status, ProductionStatus.unknown);
      }
      // Structural scaffolding exists even with zero knowledge.
      expect(report.planetEntities, 9);
      expect(report.houseEntities, 12);
    });
  });

  group('Production guarantees (fixtures)', () {
    test('every imported fact is atomic', () {
      final report = KnowledgeProductionReport.build(_fixture(), _ontology);
      expect(report.allAtomic, isTrue, reason: report.atomicIssues.join('\n'));
    });

    test('every entity exists in ontology and every relationship is registered',
        () {
      for (final u in _fixture()) {
        expect(_ontology.entity(u.subject), isNotNull, reason: u.subject);
        expect(_ontology.entity(u.object), isNotNull, reason: u.object);
        expect(_ontology.isRegisteredRelationship(u.relation.wire), isTrue);
      }
      // The workspace validator agrees there are no errors.
      final session = KnowledgeExtractionSession(
        id: 'prod',
        source: const ExtractionSource(
            bookId: 'mahabhut', chapter: '2', pageStart: 40, pageEnd: 41),
        units: _fixture(),
      );
      final v = WorkspaceValidator.validate(session, _ontology);
      expect(v.isValid, isTrue, reason: v.issues.join('\n'));
    });

    test('no duplicated knowledge', () {
      final session = KnowledgeExtractionSession(
        id: 'dup',
        source: const ExtractionSource(bookId: 'mahabhut', pageStart: 1),
        units: [
          _u('d1', 'planet.mars', AtomicRelation.owns, 'domain.health',
              objectKind: AtomicEntityKind.domain),
          _u('d2', 'planet.mars', AtomicRelation.owns, 'domain.health',
              objectKind: AtomicEntityKind.domain),
        ],
      );
      expect(WorkspaceValidator.validate(session, _ontology)
          .hasCode('duplicate_knowledge'), isTrue);
    });

    test('provenance exists for every imported fact', () {
      final report = KnowledgeProductionReport.build(_fixture(), _ontology);
      expect(report.provenanceComplete, isTrue);
      expect(report.unitsWithProvenance, report.totalUnits);

      // A unit with no reference breaks provenance completeness.
      final noProv = [
        ..._fixture(),
        _u('np', 'planet.venus', AtomicRelation.owns, 'domain.relationship',
            objectKind: AtomicEntityKind.domain,
            evidence: const AtomicEvidenceRef(bookId: 'mahabhut')),
      ];
      expect(KnowledgeProductionReport.build(noProv, _ontology)
          .provenanceComplete, isFalse);
    });

    test('completeness increases deterministically as knowledge is produced', () {
      final before = KnowledgeProductionReport.build(const [], _ontology)
          .completeness;
      final r1 = KnowledgeProductionReport.build(_fixture(), _ontology);
      final r2 = KnowledgeProductionReport.build(_fixture(), _ontology);
      // Deterministic.
      expect(r1.render(), r2.render());
      // Monotonic increase.
      expect(r1.completeness.totalUnits,
          greaterThan(before.totalUnits));
      expect(r1.completeness.unitsWithEvidence, 3);
    });

    test('domains classify produced units correctly', () {
      final report = KnowledgeProductionReport.build([
        ..._fixture(),
        _u('m1', 'planet.jupiter', AtomicRelation.owns, 'meaning.wisdom',
            objectKind: AtomicEntityKind.meaning),
        _u('k1', 'planet.jupiter', AtomicRelation.owns, 'keyword.expansion',
            objectKind: AtomicEntityKind.keyword),
      ], _ontology);
      expect(report.domain(ProductionDomain.planetDomains)!.produced, 2);
      expect(report.domain(ProductionDomain.planetElements)!.produced, 1);
      expect(report.domain(ProductionDomain.planetMeanings)!.produced, 1);
      expect(report.domain(ProductionDomain.planetKeywords)!.produced, 1);
      expect(report.domain(ProductionDomain.planetLibrary)!.subjectsCovered, 2);
    });
  });

  group('Ontology expansion (V1 scope)', () {
    test('twelve houses are seeded and the ontology stays valid', () {
      expect(_ontology.entitiesOf(OntologyCategory.house).length, 12);
      expect(_ontology.entity('house.1'), isNotNull);
      expect(_ontology.resolve('House 1')?.id, 'house.1');
      expect(_ontology.resolve('ภพที่ 1')?.id, 'house.1');
      expect(_ontology.validate().isValid, isTrue,
          reason: _ontology.validate().summary);
    });

    test('new vocabulary categories are available', () {
      expect(OntologyCategory.values, contains(OntologyCategory.meaning));
      expect(OntologyCategory.values, contains(OntologyCategory.role));
      expect(OntologyCategory.values, contains(OntologyCategory.keyword));
    });
  });

  group('Decoupling — no runtime dependency', () {
    test('production layer imports no engine/runtime/matrix/mirror/fusion/flutter',
        () {
      final dir = Directory(
          'lib/features/astrology/thai/knowledge/canon/production');
      for (final f in dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final imports = f
            .readAsLinesSync()
            .where((l) => l.trimLeft().startsWith('import '))
            .join('\n');
        for (final forbidden in const [
          'package:flutter/',
          'planet_relationship_matrix',
          'core/life_period',
          '/runtime/',
          '/mirror/',
          '/fusion/',
          '/narrative',
        ]) {
          expect(imports.contains(forbidden), isFalse,
              reason: '${f.path} must not import $forbidden');
        }
      }
    });
  });
}
