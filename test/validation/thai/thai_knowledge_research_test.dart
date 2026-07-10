import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_record.dart';

/// Thai Astrology Knowledge Research (V3) — evidence-linked model (V4).
///
/// Research records now carry `evidenceIds` instead of bibliographic fields; the
/// relationship + status logic is unchanged and stays engine/matrix-independent.

const _sampleJson = '''
{
  "schemaVersion": "1.0",
  "domain": "knowledge_research",
  "records": [
    {
      "id": "RR-0001",
      "topic": "planet_relationship",
      "entity": "Saturn–Venus",
      "interpretation": "Saturn and Venus are friends.",
      "relationship": [
        { "from": "saturn", "to": "venus", "relation": "friend" },
        { "from": "venus", "to": "saturn", "relation": "friend" }
      ],
      "evidenceIds": ["EV-0001"],
      "confidence": "high",
      "reviewedBy": "Reviewer X",
      "status": "verified",
      "notes": "n/a"
    },
    {
      "id": "RR-0002",
      "topic": "planet_relationship",
      "entity": "Saturn–Venus",
      "interpretation": "Some Vedic texts treat Saturn–Venus as enemies.",
      "relationship": [
        { "from": "saturn", "to": "venus", "relation": "enemy" }
      ],
      "evidenceIds": ["EV-0002"],
      "confidence": "low",
      "status": "candidate"
    }
  ]
}
''';

void main() {
  group('KnowledgeResearchEngine — load + model', () {
    test('loads records with multiple relationships and evidence links', () {
      final engine = KnowledgeResearchEngine.load(_sampleJson);
      expect(engine.records.length, 2);
      final rr1 = engine.records.firstWhere((r) => r.id == 'RR-0001');
      expect(rr1.relationship.length, 2);
      expect(rr1.evidenceIds, ['EV-0001']);
      expect(rr1.status, ResearchStatus.verified);
      expect(rr1.confidence, ResearchConfidence.high);
    });

    test('bad JSON / missing required fields are skipped, not thrown', () {
      expect(KnowledgeResearchEngine.load('nope').records, isEmpty);
      final partial = KnowledgeResearchEngine.load('{"records":[{"id":"x"}]}');
      expect(partial.records, isEmpty);
    });
  });

  group('KnowledgeResearchEngine — evidence + conflicts', () {
    final engine = KnowledgeResearchEngine.load(_sampleJson);

    test('findSupportingEvidence returns matching records', () {
      expect(engine.findSupportingEvidence('saturn', 'venus').length, 2);
      expect(
        engine
            .findSupportingEvidence('saturn', 'venus', relation: 'friend')
            .single
            .id,
        'RR-0001',
      );
      expect(engine.findSupportingEvidence('sun', 'moon'), isEmpty);
    });

    test('findConflicts detects disagreeing relations for a pair', () {
      final c = engine
          .findConflicts()
          .singleWhere((x) => x.pairKey == 'saturn->venus');
      expect(c.relations, containsAll(<String>{'friend', 'enemy'}));
      expect(c.recordIds, containsAll(<String>['RR-0001', 'RR-0002']));
    });
  });

  group('KnowledgeResearchEngine — coverage', () {
    test('coverage counts status split + supported pairs', () {
      final c = KnowledgeResearchEngine.load(_sampleJson).coverage();
      expect(c.totalRecords, 2);
      expect(c.verified, 1);
      expect(c.candidate, 1);
      expect(c.relationshipsSupported, 2);
      expect(c.relationshipUniverse, 56);
      expect(c.relationshipsWithoutEvidence, 54);
    });

    test('empty corpus baseline', () {
      final c = KnowledgeResearchEngine(const []).coverage();
      expect(c.totalRecords, 0);
      expect(c.relationshipsSupported, 0);
      expect(c.relationshipsWithoutEvidence, 56);
    });
  });

  group('Knowledge research data files', () {
    test('template parses against the engine', () {
      final json =
          File('knowledge/research/research.template.json').readAsStringSync();
      final engine = KnowledgeResearchEngine.load(json);
      expect(engine.records.single.id, 'RR-0001');
      expect(engine.records.single.evidenceIds, ['EV-0001']);
    });
  });

  group('Decoupling — no engine / no matrix dependency', () {
    test('research source files import neither the engine nor the matrix', () {
      const files = [
        'lib/features/astrology/thai/knowledge/research/knowledge_research_record.dart',
        'lib/features/astrology/thai/knowledge/research/knowledge_research_engine.dart',
      ];
      for (final path in files) {
        final src = File(path).readAsStringSync();
        expect(src.contains('core/life_period'), isFalse);
        expect(src.contains('planet_relationship_matrix'), isFalse);
        expect(src.contains('life_planet'), isFalse);
      }
    });
  });
}
