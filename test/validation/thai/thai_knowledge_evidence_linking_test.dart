import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/evidence/evidence_record.dart';
import 'package:knowme/features/astrology/thai/knowledge/evidence/knowledge_evidence_engine.dart';

/// Thai Astrology Knowledge Evidence Linking V4.
///
/// Research records reference citable EvidenceRecords by id. These tests cover
/// loading, the join lookups, orphan/coverage reporting, and the linkage
/// validations (duplicate, broken link, missing, unused, circular).

const _evidenceJson = '''
{
  "schemaVersion": "1.0",
  "domain": "knowledge_evidence",
  "records": [
    {
      "id": "EV-0001",
      "sourceType": "book",
      "school": "thaiTraditional",
      "author": "Author A",
      "book": "Book A",
      "edition": "1st",
      "language": "th",
      "quote": "เสาร์กับศุกร์เป็นมิตร",
      "reviewStatus": "verified",
      "createdAt": "2026-01-02T03:04:05Z"
    },
    {
      "id": "EV-0002",
      "sourceType": "book",
      "school": "vedic",
      "author": "Author B",
      "book": "Book B",
      "language": "en",
      "reviewStatus": "draft"
    },
    {
      "id": "EV-9999",
      "sourceType": "website",
      "school": "knowmeCustom",
      "author": "Author C",
      "book": "Unused Source",
      "language": "en",
      "reviewStatus": "reviewed"
    }
  ]
}
''';

const _researchJson = '''
{
  "schemaVersion": "1.0",
  "domain": "knowledge_research",
  "records": [
    {
      "id": "RR-0001",
      "topic": "planet_relationship",
      "entity": "Saturn–Venus",
      "interpretation": "Friends.",
      "relationship": [
        { "from": "saturn", "to": "venus", "relation": "friend" },
        { "from": "venus", "to": "saturn", "relation": "friend" }
      ],
      "evidenceIds": ["EV-0001"],
      "confidence": "high",
      "status": "verified"
    },
    {
      "id": "RR-0002",
      "topic": "planet_relationship",
      "entity": "Saturn–Venus",
      "interpretation": "Enemies (other source).",
      "relationship": [
        { "from": "saturn", "to": "venus", "relation": "enemy" }
      ],
      "evidenceIds": ["EV-0002", "EV-MISSING"],
      "confidence": "low",
      "status": "candidate"
    }
  ]
}
''';

KnowledgeEvidenceEngine _engine() => KnowledgeEvidenceEngine.load(
      evidenceJson: _evidenceJson,
      researchJson: _researchJson,
    );

void main() {
  group('loadEvidence', () {
    test('parses evidence records incl. dates and review status', () {
      final list = KnowledgeEvidenceEngine.loadEvidence(_evidenceJson);
      expect(list.length, 3);
      final ev1 = list.firstWhere((e) => e.id == 'EV-0001');
      expect(ev1.reviewStatus, EvidenceReviewStatus.verified);
      expect(ev1.createdAt, isNotNull);
      expect(ev1.sourceLabel, 'Book A · 1st');
    });

    test('malformed JSON is tolerated', () {
      expect(KnowledgeEvidenceEngine.loadEvidence('nope'), isEmpty);
    });
  });

  group('lookups', () {
    final e = _engine();

    test('findEvidence by id', () {
      expect(e.findEvidence('EV-0001')!.author, 'Author A');
      expect(e.findEvidence('NOPE'), isNull);
    });

    test('findResearch returns records referencing an evidence id', () {
      expect(e.findResearch('EV-0001').single.id, 'RR-0001');
      expect(e.findResearch('EV-9999'), isEmpty);
    });

    test('findRelationships returns relationships backed by an evidence id', () {
      final rels = e.findRelationships('EV-0001');
      expect(rels.length, 2);
      expect(rels.map((r) => r.pairKey),
          containsAll(<String>['saturn->venus', 'venus->saturn']));
    });

    test('findOrphans returns unreferenced evidence', () {
      expect(e.findOrphans().single.id, 'EV-9999');
    });
  });

  group('validation', () {
    test('detects broken link, missing/unused evidence', () {
      final r = _engine().validate();
      final codes = r.issues.map((i) => i.code).toSet();
      expect(codes, contains('broken_link')); // EV-MISSING
      expect(codes, contains('unused_evidence')); // EV-9999
      expect(r.ok, isFalse); // broken_link is an error
    });

    test('detects duplicate evidence ids', () {
      final dup = KnowledgeEvidenceEngine(
        evidence: KnowledgeEvidenceEngine.loadEvidence(_evidenceJson)
          ..add(KnowledgeEvidenceEngine.loadEvidence(_evidenceJson).first),
        research: const [],
      );
      expect(dup.validate().issues.any((i) => i.code == 'duplicate_evidence'),
          isTrue);
    });

    test('clean corpus (no dangling links) has no errors', () {
      const clean = '''
      { "domain": "knowledge_research", "records": [
        { "id": "RR-1", "topic": "t", "entity": "e", "interpretation": "i",
          "relationship": [{"from":"saturn","to":"venus","relation":"friend"}],
          "evidenceIds": ["EV-0001"], "confidence": "high", "status": "verified" }
      ]}''';
      final engine = KnowledgeEvidenceEngine.load(
        evidenceJson: _evidenceJson,
        researchJson: clean,
      );
      expect(engine.validate().errors, isEmpty);
    });
  });

  group('coverage', () {
    test('evidence coverage report', () {
      final c = _engine().coverage();
      expect(c.evidenceCount, 3);
      expect(c.referencedEvidence, 2); // EV-0001, EV-0002 (EV-MISSING ignored)
      expect(c.orphanEvidence, 1); // EV-9999
      expect(c.relationshipsSupported, 2); // saturn->venus, venus->saturn
      expect(c.researchRecordsSupported, 2);
    });
  });

  group('data files', () {
    test('evidence + research templates link via evidenceIds', () {
      final evidenceJson =
          File('knowledge/evidence/evidence.template.json').readAsStringSync();
      final researchJson =
          File('knowledge/research/research.template.json').readAsStringSync();
      final engine = KnowledgeEvidenceEngine.load(
        evidenceJson: evidenceJson,
        researchJson: researchJson,
      );
      expect(engine.evidence.single.id, 'EV-0001');
      expect(engine.research.single.evidenceIds, ['EV-0001']);
      // Template links resolve — no broken links.
      expect(
        engine.validate().issues.any((i) => i.code == 'broken_link'),
        isFalse,
      );
    });
  });

  group('decoupling', () {
    test('evidence layer imports no engine/matrix/runtime/prediction', () {
      const files = [
        'lib/features/astrology/thai/knowledge/evidence/evidence_record.dart',
        'lib/features/astrology/thai/knowledge/evidence/knowledge_evidence_engine.dart',
      ];
      for (final path in files) {
        final src = File(path).readAsStringSync();
        expect(src.contains('core/life_period'), isFalse);
        expect(src.contains('planet_relationship_matrix'), isFalse);
        expect(src.contains('life_planet'), isFalse);
        expect(src.contains('core/runtime'), isFalse);
        expect(src.contains('core/prediction'), isFalse);
      }
    });
  });
}
