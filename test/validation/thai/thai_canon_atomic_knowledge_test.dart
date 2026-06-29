import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;

/// Canon Atomic Knowledge V2. The canonical object is one atomic fact
/// (subject → relation → object). Narrative is never Canon. Pure knowledge
/// layer — no engine/runtime/matrix/mirror/fusion dependency.

AtomicKnowledgeUnit _unit(
  String id,
  String subject,
  AtomicRelation rel,
  String object, {
  AtomicEntityKind subjectKind = AtomicEntityKind.planet,
  AtomicEntityKind objectKind = AtomicEntityKind.domain,
  KnowledgeDomain domain = KnowledgeDomain.planetLibrary,
  String? condition,
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
      condition: condition,
      confidence: confidence,
      evidence: evidence ??
          const AtomicEvidenceRef(bookId: 'mahabhut', chapter: '1', page: '12'),
    );

void main() {
  group('Atomicity', () {
    test('a one-fact unit is atomic and traceable', () {
      final u = _unit('u1', 'jupiter', AtomicRelation.owns, 'wealth');
      expect(AtomicExtractionRules.isAtomic(u), isTrue);
      expect(u.label, 'jupiter owns wealth');
      expect(u.isVerified, isTrue);
    });

    test('a narrative object makes a unit non-atomic', () {
      final bad = _unit('u2', 'jupiter', AtomicRelation.produces,
          'usually brings financial success to the native.');
      final issues = AtomicExtractionRules.validateUnit(bad);
      expect(issues.map((i) => i.code), contains('non_atomic_object'));
      expect(AtomicExtractionRules.isAtomic(bad), isFalse);
    });

    test('a unit without a book reference is rejected', () {
      final noRef = _unit('u3', 'mars', AtomicRelation.owns, 'energy',
          evidence: const AtomicEvidenceRef(bookId: 'mahabhut'));
      expect(AtomicExtractionRules.validateUnit(noRef).map((i) => i.code),
          contains('missing_reference'));
    });

    test('validateAll flags duplicate ids', () {
      final a = _unit('dup', 'sun', AtomicRelation.owns, 'authority');
      final b = _unit('dup', 'moon', AtomicRelation.owns, 'mind');
      expect(AtomicExtractionRules.validateAll([a, b]).map((i) => i.code),
          contains('duplicate_id'));
    });
  });

  group('Extraction rejects narrative', () {
    test('paragraphs and interpretation are rejected; atomic tokens accepted', () {
      const narrative =
          'Jupiter in House 2 usually brings financial success and growth.';
      expect(AtomicExtractionRules.classify(narrative).isAtomic, isFalse);
      expect(AtomicExtractionRules.classify('Jupiter in House 2 indicates that wealth').isAtomic,
          isFalse);
      expect(AtomicExtractionRules.classify('wealth').isAtomic, isTrue);
      expect(AtomicExtractionRules.classify('financial_growth').isAtomic, isTrue);
      expect(AtomicExtractionRules.classify('jupiter').isAtomic, isTrue);
    });

    test('multi-idea conjunctions are rejected', () {
      expect(AtomicExtractionRules.classify('wealth and health').isAtomic, isFalse);
    });
  });

  group('Knowledge graph', () {
    test('builds nodes/edges and answers relationship queries', () {
      final units = [
        _unit('u1', 'jupiter', AtomicRelation.owns, 'wealth'),
        _unit('u2', 'jupiter', AtomicRelation.supports, 'sun',
            objectKind: AtomicEntityKind.planet,
            domain: KnowledgeDomain.planetRelationships),
        _unit('u3', 'house_2', AtomicRelation.belongsTo, 'wealth',
            subjectKind: AtomicEntityKind.house,
            domain: KnowledgeDomain.houseLibrary),
      ];
      final g = AtomicKnowledgeGraph.build(units);
      expect(g.isValid, isTrue, reason: g.validate().join('\n'));
      expect(g.nodeCount, 4); // jupiter, wealth, sun, house_2
      final jid = AtomicNode.makeId(AtomicEntityKind.planet, 'jupiter');
      expect(g.neighbours(jid),
          containsAll([
            AtomicNode.makeId(AtomicEntityKind.domain, 'wealth'),
            AtomicNode.makeId(AtomicEntityKind.planet, 'sun'),
          ]));
      expect(g.relationsBetween(jid, AtomicNode.makeId(AtomicEntityKind.planet, 'sun')),
          [AtomicRelation.supports]);
    });

    test('contradictory supports/opposes is flagged', () {
      final units = [
        _unit('s', 'mars', AtomicRelation.supports, 'venus',
            objectKind: AtomicEntityKind.planet),
        _unit('o', 'mars', AtomicRelation.opposes, 'venus',
            objectKind: AtomicEntityKind.planet),
      ];
      final g = AtomicKnowledgeGraph.build(units);
      expect(g.validate().map((i) => i.code), contains('contradiction'));
    });
  });

  group('Completeness report', () {
    List<AtomicKnowledgeUnit> sample() => [
          _unit('p1', 'jupiter', AtomicRelation.owns, 'wealth'),
          _unit('p2', 'sun', AtomicRelation.owns, 'authority'),
          _unit('r1', 'jupiter', AtomicRelation.supports, 'sun',
              objectKind: AtomicEntityKind.planet,
              domain: KnowledgeDomain.planetRelationships),
          _unit('r2', 'mars', AtomicRelation.opposes, 'saturn',
              objectKind: AtomicEntityKind.planet,
              domain: KnowledgeDomain.planetRelationships,
              confidence: KnowledgeConfidence.none),
        ];

    test('is deterministic and domain-based', () {
      final a = CanonCompletenessReport.generate(sample());
      final b = CanonCompletenessReport.generate(sample());
      expect(a.summary, b.summary);
      expect(a.domains.map((d) => d.domain).toList(),
          b.domains.map((d) => d.domain).toList());

      final planet = a.domain(KnowledgeDomain.planetLibrary)!;
      expect(planet.present, 2);
      expect(planet.expected, 9);
      // Only r1 is verified (r2 has confidence none).
      expect(a.verifiedRelationships, 1);
      expect(a.unknownRelationships, 72 - 1);
      expect(a.evidenceCoverage, closeTo(1.0, 0.001));
    });

    test('empty knowledge base yields zero coverage deterministically', () {
      final r = CanonCompletenessReport.generate(const []);
      expect(r.totalUnits, 0);
      expect(r.domain(KnowledgeDomain.planetLibrary)!.coverage, 0);
      expect(r.unknownRelationships, 72);
    });
  });

  group('Serialization round-trip', () {
    test('atomic unit JSON round-trips', () {
      final u = _unit('u1', 'jupiter', AtomicRelation.owns, 'wealth',
          condition: 'jupiter_in_house_2');
      final back = AtomicKnowledgeUnit.fromJson(u.toJson());
      expect(back, isNotNull);
      expect(back!.subject, 'jupiter');
      expect(back.relation, AtomicRelation.owns);
      expect(back.condition, 'jupiter_in_house_2');
      expect(back.evidence.page, '12');
    });
  });

  group('Decoupling — no runtime dependency', () {
    test('atomic layer imports no engine/runtime/matrix/mirror/fusion/flutter', () {
      final dir = Directory(
          'lib/features/astrology/thai/knowledge/canon/atomic');
      for (final f in dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        // Inspect only import directives — not doc-comment prose.
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
