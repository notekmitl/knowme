import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/consensus/knowledge_consensus_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge_importer.dart';
import 'package:knowme/features/astrology/thai/knowledge/review/matrix_review_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/sources/knowledge_source_engine.dart';

/// Thai Astrology Source Collection (V7) + Consensus Engine (V8) + Matrix
/// Review (V9). Knowledge-only; nothing reads or writes the matrix/engine.

String _source({
  required String id,
  String school = 'thaiClassical',
  String author = 'Author',
  required List<Map<String, String?>> assertions,
}) {
  final a = assertions.map((m) {
    final fields = <String>[
      '"from": "${m['from']}"',
      '"to": "${m['to']}"',
      '"relation": "${m['relation']}"',
      if (m.containsKey('page'))
        '"page": ${m['page'] == null ? 'null' : '"${m['page']}"'}',
      if (m.containsKey('quote'))
        '"quote": ${m['quote'] == null ? 'null' : '"${m['quote']}"'}',
    ];
    return '{ ${fields.join(', ')} }';
  }).join(',');
  return '''
  { "id": "$id", "title": "T", "author": "$author", "school": "$school",
    "language": "th", "assertions": [$a] }''';
}

void main() {
  // ===========================================================================
  // V7 — Source Collection
  // ===========================================================================
  group('V7 KnowledgeSourceEngine', () {
    test('parses sources + assertions', () {
      final engine = KnowledgeSourceEngine.loadAll([
        _source(id: 's1', assertions: [
          {'from': 'venus', 'to': 'saturn', 'relation': 'friend', 'page': '128', 'quote': 'q'},
        ]),
      ]);
      expect(engine.sources.single.id, 's1');
      expect(engine.assertions.single.pairKey, 'venus->saturn');
    });

    test('validation flags duplicate/conflicting/missing/broken', () {
      final engine = KnowledgeSourceEngine.loadAll([
        // duplicate (friend twice), missing page+quote on the dupes
        _source(id: 'dup', assertions: [
          {'from': 'venus', 'to': 'saturn', 'relation': 'friend', 'page': '1', 'quote': 'q'},
          {'from': 'venus', 'to': 'saturn', 'relation': 'friend'},
        ]),
        // conflicting (friend + enemy for same pair)
        _source(id: 'conf', assertions: [
          {'from': 'sun', 'to': 'moon', 'relation': 'friend', 'page': '1', 'quote': 'q'},
          {'from': 'sun', 'to': 'moon', 'relation': 'enemy', 'page': '2', 'quote': 'q'},
        ]),
        // broken reference (unknown planet)
        _source(id: 'broke', assertions: [
          {'from': 'pluto', 'to': 'saturn', 'relation': 'friend', 'page': '1', 'quote': 'q'},
        ]),
      ]);
      final codes = engine.validate().map((i) => i.code).toSet();
      expect(codes, containsAll(<String>{
        'duplicate_assertion',
        'conflicting_assertion',
        'missing_page',
        'missing_quote',
        'broken_reference',
      }));
    });

    test('duplicate source id is an error', () {
      final engine = KnowledgeSourceEngine.loadAll([
        _source(id: 'same', assertions: const []),
        _source(id: 'same', assertions: const []),
      ]);
      expect(
        engine.validate().any((i) => i.code == 'duplicate_source' && i.isError),
        isTrue,
      );
    });

    test('coverage report counts books/schools/authors/assertions/pairs', () {
      final engine = KnowledgeSourceEngine.loadAll([
        _source(id: 's1', school: 'thaiClassical', author: 'A', assertions: [
          {'from': 'venus', 'to': 'saturn', 'relation': 'friend', 'page': '1', 'quote': 'q'},
        ]),
        _source(id: 's2', school: 'vedic', author: 'B', assertions: [
          {'from': 'saturn', 'to': 'venus', 'relation': 'enemy', 'page': '1', 'quote': 'q'},
        ]),
      ]);
      final c = engine.coverage();
      expect(c.books, 2);
      expect(c.schools, 2);
      expect(c.authors, 2);
      expect(c.assertions, 2);
      expect(c.relationshipsCovered, 2);
      expect(c.relationshipsMissing, 54);
      expect(c.relationshipUniverse, 56);
    });

    test('empty corpus baseline', () {
      final c = KnowledgeSourceEngine(const []).coverage();
      expect(c.books, 0);
      expect(c.relationshipsCovered, 0);
      expect(c.relationshipsMissing, 56);
    });

    test('template + index are valid assets', () {
      final tpl = File('knowledge/sources/sources.template.json').readAsStringSync();
      expect(KnowledgeSourceEngine.sourceFromJson(tpl)!.id, 'thai_classical_x');
      final index = File('knowledge/sources/sources.index.json').readAsStringSync();
      expect(index.contains('"sources"'), isTrue);
    });
  });

  // ===========================================================================
  // V8 — Consensus Engine
  // ===========================================================================
  group('V8 KnowledgeConsensusEngine', () {
    test('matches the spec example: friend 4 / enemy 2 / neutral 1 → majority, medium', () {
      final sources = <String>[
        for (var i = 0; i < 4; i++)
          _source(id: 'f$i', assertions: [
            {'from': 'venus', 'to': 'saturn', 'relation': 'friend', 'page': '1', 'quote': 'q'},
          ]),
        for (var i = 0; i < 2; i++)
          _source(id: 'e$i', assertions: [
            {'from': 'venus', 'to': 'saturn', 'relation': 'enemy', 'page': '1', 'quote': 'q'},
          ]),
        _source(id: 'n0', assertions: [
          {'from': 'venus', 'to': 'saturn', 'relation': 'neutral', 'page': '1', 'quote': 'q'},
        ]),
      ];
      final engine =
          KnowledgeConsensusEngine.fromSourceEngine(KnowledgeSourceEngine.loadAll(sources));
      final e = engine.entryFor('venus', 'saturn');
      expect(e.friend, 4);
      expect(e.enemy, 2);
      expect(e.neutral, 1);
      expect(e.sourceCount, 7);
      expect(e.consensusRelation, 'friend');
      expect(e.classification, ConsensusClass.majority);
      expect(e.confidence, ConsensusConfidence.medium);
    });

    test('unanimous → consensus; tie → split (confidence downgraded)', () {
      final consensusEngine = KnowledgeConsensusEngine.fromSourceEngine(
        KnowledgeSourceEngine.loadAll([
          for (var i = 0; i < 3; i++)
            _source(id: 'u$i', assertions: [
              {'from': 'sun', 'to': 'mars', 'relation': 'friend', 'page': '1', 'quote': 'q'},
            ]),
        ]),
      );
      final unanimous = consensusEngine.entryFor('sun', 'mars');
      expect(unanimous.classification, ConsensusClass.consensus);
      expect(unanimous.confidence, ConsensusConfidence.medium);

      final split = KnowledgeConsensusEngine.fromSourceEngine(
        KnowledgeSourceEngine.loadAll([
          _source(id: 'a', assertions: [
            {'from': 'mars', 'to': 'sun', 'relation': 'friend', 'page': '1', 'quote': 'q'},
          ]),
          _source(id: 'b', assertions: [
            {'from': 'mars', 'to': 'sun', 'relation': 'enemy', 'page': '1', 'quote': 'q'},
          ]),
        ]),
      ).entryFor('mars', 'sun');
      expect(split.classification, ConsensusClass.split);
      expect(split.consensusRelation, isNull);
      // base low (2 sources) stays low after split downgrade
      expect(split.confidence, ConsensusConfidence.low);
    });

    test('report summarises the universe', () {
      final r = KnowledgeConsensusEngine(const []).report();
      expect(r.total, 56);
      expect(r.uncovered, 56);
      expect(r.covered, 0);
    });
  });

  // ===========================================================================
  // V9 — Matrix Review
  // ===========================================================================
  group('V9 MatrixReviewEngine', () {
    final knowledge = PlanetRelationshipKnowledgeImporter.importJson(
      File('knowledge/planet_relationships/planet_relationships.knowme.json')
          .readAsStringSync(),
    ).knowledge;

    test('empty evidence → all 56 Keep, no engine impact', () {
      final report = MatrixReviewEngine.review(
        knowledge: knowledge,
        consensus: KnowledgeConsensusEngine(const []),
        sources: KnowledgeSourceEngine(const []),
      );
      expect(report.rows.length, 56);
      expect(report.keep, 56);
      expect(report.review, 0);
      expect(report.replace, 0);
      expect(report.impact.hasProposedChanges, isFalse);
    });

    test('strong clear disagreement → Replace; supporting/conflicting tracked', () {
      // Find a pair whose current matrix value we can read, then flood sources
      // with a DIFFERENT relation at high confidence (8+ unanimous sources).
      final sampleRow = MatrixReviewEngine.review(
        knowledge: knowledge,
        consensus: KnowledgeConsensusEngine(const []),
        sources: KnowledgeSourceEngine(const []),
      ).rows.first;
      final from = sampleRow.from;
      final to = sampleRow.to;
      final current = sampleRow.currentMatrix;
      final other = current == 'friend' ? 'enemy' : 'friend';

      final sources = KnowledgeSourceEngine.loadAll([
        for (var i = 0; i < 9; i++)
          _source(id: 'src$i', assertions: [
            {'from': from, 'to': to, 'relation': other, 'page': '1', 'quote': 'q'},
          ]),
        // one supporting source (asserts the current value)
        _source(id: 'support', assertions: [
          {'from': from, 'to': to, 'relation': current, 'page': '1', 'quote': 'q'},
        ]),
      ]);
      final report = MatrixReviewEngine.review(
        knowledge: knowledge,
        consensus: KnowledgeConsensusEngine.fromSourceEngine(sources),
        sources: sources,
      );
      final row = report.rows.firstWhere((r) => r.from == from && r.to == to);
      expect(row.consensus.classification, ConsensusClass.majority);
      expect(row.consensus.confidence, ConsensusConfidence.high);
      expect(row.recommendation, MatrixRecommendation.replace);
      expect(row.conflictingSourceIds, contains('src0'));
      expect(row.supportingSourceIds, contains('support'));
      expect(report.impact.hasProposedChanges, isTrue);
    });

    test('weak disagreement → Keep (insufficient evidence)', () {
      final sampleRow = MatrixReviewEngine.review(
        knowledge: knowledge,
        consensus: KnowledgeConsensusEngine(const []),
        sources: KnowledgeSourceEngine(const []),
      ).rows.first;
      final other = sampleRow.currentMatrix == 'friend' ? 'enemy' : 'friend';
      final sources = KnowledgeSourceEngine.loadAll([
        _source(id: 'lonely', assertions: [
          {'from': sampleRow.from, 'to': sampleRow.to, 'relation': other, 'page': '1', 'quote': 'q'},
        ]),
      ]);
      final row = MatrixReviewEngine.review(
        knowledge: knowledge,
        consensus: KnowledgeConsensusEngine.fromSourceEngine(sources),
        sources: sources,
      ).rows.firstWhere((r) => r.from == sampleRow.from && r.to == sampleRow.to);
      // 1 source → low confidence → keep
      expect(row.recommendation, MatrixRecommendation.keep);
    });
  });

  // ===========================================================================
  // Decoupling — no engine / matrix dependency
  // ===========================================================================
  group('Decoupling', () {
    test('V7/V8/V9 source files import neither the engine nor the matrix', () {
      const files = [
        'lib/features/astrology/thai/knowledge/sources/source_record.dart',
        'lib/features/astrology/thai/knowledge/sources/knowledge_source_engine.dart',
        'lib/features/astrology/thai/knowledge/consensus/knowledge_consensus_engine.dart',
        'lib/features/astrology/thai/knowledge/review/matrix_review_engine.dart',
      ];
      for (final path in files) {
        final src = File(path).readAsStringSync();
        expect(src.contains('planet_relationship_matrix'), isFalse, reason: path);
        expect(src.contains('core/life_period'), isFalse, reason: path);
        expect(src.contains('core/runtime'), isFalse, reason: path);
        expect(src.contains('core/prediction'), isFalse, reason: path);
      }
    });
  });
}
