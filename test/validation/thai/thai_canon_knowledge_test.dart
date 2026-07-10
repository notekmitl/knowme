import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_book_manifest.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_conflict_resolver.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_knowledge_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/knowledge_tier.dart';

/// Thai Astrology Canon V1. Pure knowledge layer — nothing here imports or
/// mutates the calculation engine / PlanetRelationshipMatrix.

const _sourcesJson = '''
{
  "version": 1,
  "sources": [
    { "id": "engine", "title": "Engine", "tier": "tier0_calculation_engine", "canonical": false },
    { "id": "mahabhut", "title": "หลักมหาภูต", "author": "ส. หยกฟ้า", "tier": "tier1_canon", "canonical": true },
    { "id": "phrommachat", "title": "พรหมชาติ", "tier": "tier2_thai_classical", "canonical": false },
    { "id": "research", "title": "Research", "tier": "tier3_research", "canonical": false },
    { "id": "web", "title": "Web", "tier": "tier4_internet", "canonical": false }
  ]
}
''';

String _node({
  required String id,
  String topic = 'planet_relationship',
  String subject = 'venus->saturn',
  String category = 'rule',
  String? value,
  required String sourceId,
  bool withQuote = true,
}) {
  return '''
  { "id": "$id", "topic": "$topic", "subject": "$subject",
    "category": "$category", "statement": "stmt $id",
    ${value == null ? '' : '"value": "$value",'}
    "sourceId": "$sourceId", "confidence": "high", "status": "reviewed",
    "evidence": [${withQuote ? '{ "page": "1", "quote": "q" }' : ''}] }''';
}

String _nodesJson(List<String> nodes) =>
    '{ "version": 1, "nodes": [${nodes.join(',')}] }';

void main() {
  group('Canon V1 — KnowledgeTier source priority', () {
    test('priority orders Tier 0 highest, Tier 4 lowest', () {
      expect(KnowledgeTier.calculationEngine.priority, 0);
      expect(KnowledgeTier.canon.priority, 1);
      expect(KnowledgeTier.thaiClassical.priority, 2);
      expect(KnowledgeTier.research.priority, 3);
      expect(KnowledgeTier.internet.priority, 4);
      expect(KnowledgeTier.canon.outranks(KnowledgeTier.thaiClassical), isTrue);
      expect(KnowledgeTier.internet.outranks(KnowledgeTier.canon), isFalse);
    });

    test('tier flags', () {
      expect(KnowledgeTier.canon.isCanon, isTrue);
      expect(KnowledgeTier.calculationEngine.isGroundTruth, isTrue);
      expect(KnowledgeTier.research.isSupporting, isTrue);
      expect(KnowledgeTier.canon.isSupporting, isFalse);
    });

    test('key round-trips', () {
      for (final t in KnowledgeTier.values) {
        expect(KnowledgeTierAuthority.fromKey(t.key), t);
      }
    });
  });

  group('Canon V1 — engine loading + validation', () {
    test('loads sources and resolves node authority from registry', () {
      final r = CanonKnowledgeEngine.load(
        sourcesJson: _sourcesJson,
        nodesJson: _nodesJson([
          _node(id: 'n1', sourceId: 'mahabhut', value: 'friend'),
        ]),
      );
      expect(r.hasErrors, isFalse, reason: r.issues.join('\n'));
      final node = r.engine.nodes.single;
      expect(node.tier, KnowledgeTier.canon);
      expect(node.canonical, isTrue);
      expect(node.isCanonical, isTrue);
    });

    test('canonical flag is coerced off when source is not Tier 1', () {
      const bad = '''
      { "version": 1, "sources": [
        { "id": "x", "title": "X", "tier": "tier2_thai_classical", "canonical": true }
      ] }''';
      final r = CanonKnowledgeEngine.load(
        sourcesJson: bad,
        nodesJson: _nodesJson(const []),
      );
      expect(r.engine.source('x')!.canonical, isFalse);
      expect(r.warnings.any((w) => w.code == 'canonical_tier_mismatch'), isTrue);
    });

    test('broken source ref is an error', () {
      final r = CanonKnowledgeEngine.load(
        sourcesJson: _sourcesJson,
        nodesJson: _nodesJson([_node(id: 'n1', sourceId: 'ghost')]),
      );
      expect(r.issues.any((i) => i.code == 'broken_source_ref'), isTrue);
    });

    test('duplicate node id is an error', () {
      final r = CanonKnowledgeEngine.load(
        sourcesJson: _sourcesJson,
        nodesJson: _nodesJson([
          _node(id: 'dup', sourceId: 'mahabhut', value: 'friend'),
          _node(id: 'dup', sourceId: 'phrommachat', value: 'friend'),
        ]),
      );
      expect(r.issues.any((i) => i.code == 'duplicate_node'), isTrue);
    });

    test('unknown tier on a source is an error', () {
      const bad = '''
      { "version": 1, "sources": [
        { "id": "x", "title": "X", "tier": "tier9_made_up", "canonical": false }
      ] }''';
      final r = CanonKnowledgeEngine.load(
        sourcesJson: bad,
        nodesJson: _nodesJson(const []),
      );
      expect(r.issues.any((i) => i.code == 'unknown_tier'), isTrue);
    });

    test('canonical node without evidence warns', () {
      final r = CanonKnowledgeEngine.load(
        sourcesJson: _sourcesJson,
        nodesJson: _nodesJson([
          _node(id: 'n1', sourceId: 'mahabhut', value: 'friend', withQuote: false),
        ]),
      );
      expect(r.warnings.any((w) => w.code == 'canon_missing_evidence'), isTrue);
    });

    test('malformed JSON degrades to an error, not a throw', () {
      final r = CanonKnowledgeEngine.load(sourcesJson: 'nope', nodesJson: 'nope');
      expect(r.hasErrors, isTrue);
      expect(r.engine.nodes, isEmpty);
    });
  });

  group('Canon V1 — conflict resolution (Canon always wins)', () {
    CanonKnowledgeEngine engineFor(List<String> nodes) => CanonKnowledgeEngine
        .load(sourcesJson: _sourcesJson, nodesJson: _nodesJson(nodes))
        .engine;

    test('canon wins and contradicting supporting node is overruled', () {
      final res = engineFor([
        _node(id: 'canon', sourceId: 'mahabhut', value: 'friend'),
        _node(id: 'support', sourceId: 'phrommachat', value: 'enemy'),
      ]).resolve('planet_relationship', 'venus->saturn')!;
      expect(res.outcome, CanonResolutionOutcome.canonical);
      expect(res.value, 'friend');
      expect(res.overruledByCanon.single.id, 'support');
      expect(res.supporting, isEmpty);
    });

    test('agreeing supporting node elaborates rather than being overruled', () {
      final res = engineFor([
        _node(id: 'canon', sourceId: 'mahabhut', value: 'friend'),
        _node(id: 'support', sourceId: 'phrommachat', value: 'friend'),
      ]).resolve('planet_relationship', 'venus->saturn')!;
      expect(res.overruledByCanon, isEmpty);
      expect(res.supporting.single.id, 'support');
    });

    test('canon vs canon disagreement needs human review', () {
      final res = engineFor([
        _node(id: 'c1', sourceId: 'mahabhut', value: 'friend'),
        _node(id: 'c2', sourceId: 'mahabhut', value: 'enemy'),
      ]).resolve('planet_relationship', 'venus->saturn')!;
      expect(res.outcome, CanonResolutionOutcome.canonInternalConflict);
      expect(res.needsHumanReview, isTrue);
      expect(res.value, isNull);
    });

    test('no canon → supporting-only is provisional, ranked by tier', () {
      final res = engineFor([
        _node(id: 'web', sourceId: 'web', value: 'enemy'),
        _node(id: 'thai', sourceId: 'phrommachat', value: 'friend'),
      ]).resolve('planet_relationship', 'venus->saturn')!;
      expect(res.outcome, CanonResolutionOutcome.supportingOnly);
      // Tier 2 (phrommachat) outranks Tier 4 (web).
      expect(res.value, 'friend');
    });

    test('coverage report counts canon vs provisional subjects', () {
      final engine = engineFor([
        _node(id: 'a', subject: 'a', sourceId: 'mahabhut', value: 'friend'),
        _node(id: 'b', subject: 'b', sourceId: 'phrommachat', value: 'enemy'),
      ]);
      final cov = engine.coverage();
      expect(cov.totalNodes, 2);
      expect(cov.totalSubjects, 2);
      expect(cov.canonicalSubjects, 1);
      expect(cov.supportingOnlySubjects, 1);
      expect(cov.canonSources, 1);
    });
  });

  group('Canon V1 — book manifest (future extraction architecture)', () {
    test('parses skeleton manifest with no extracted content', () {
      const json = '''
      { "sourceId": "mahabhut", "title": "หลักมหาภูต", "author": "ส. หยกฟ้า",
        "language": "th", "parts": [] }''';
      final m = CanonBookManifest.fromJson(json);
      expect(m.sourceId, 'mahabhut');
      final report = m.extractionReport();
      expect(report.totalSections, 0);
      expect(report.extractedSections, 0);
    });

    test('computes extraction progress when sections exist', () {
      const json = '''
      { "sourceId": "mahabhut", "title": "หลักมหาภูต", "parts": [
        { "id": "p1", "title": "Part 1", "chapters": [
          { "id": "c1", "title": "Ch 1", "number": 1, "sections": [
            { "id": "s1", "title": "S1", "topic": "planet_relationship",
              "status": "extracted", "nodeIds": ["n1", "n2"] },
            { "id": "s2", "title": "S2", "status": "notStarted" }
          ] }
        ] }
      ] }''';
      final m = CanonBookManifest.fromJson(json);
      final report = m.extractionReport();
      expect(report.totalSections, 2);
      expect(report.extractedSections, 1);
      expect(report.totalNodes, 2);
      expect(report.progress, 0.5);
    });
  });

  group('Canon V1 — shipped data files', () {
    test('canon_sources.json registers หลักมหาภูต as the Tier 1 canon', () {
      final sources = File('knowledge/canon/canon_sources.json').readAsStringSync();
      final nodes = File('knowledge/canon/canon.knowme.json').readAsStringSync();
      final r = CanonKnowledgeEngine.load(sourcesJson: sources, nodesJson: nodes);
      expect(r.hasErrors, isFalse, reason: r.issues.join('\n'));
      final canon = r.engine.canonSources;
      expect(canon.length, 1);
      expect(canon.single.id, 'mahabhut');
      expect(canon.single.tier, KnowledgeTier.canon);
      // Baseline ships no fabricated nodes.
      expect(r.engine.nodes, isEmpty);
    });

    test('shipped book manifest is a not-started skeleton', () {
      final json = File('knowledge/canon/mahabhut.manifest.json').readAsStringSync();
      final m = CanonBookManifest.fromJson(json);
      expect(m.sourceId, 'mahabhut');
      expect(m.extractionReport().totalSections, 0);
    });
  });

  group('Canon V1 — decoupling', () {
    test('canon layer never imports the engine / matrix', () {
      final dir = Directory('lib/features/astrology/thai/knowledge/canon');
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final f in files) {
        final src = f.readAsStringSync();
        expect(src.contains('planet_relationship_matrix'), isFalse,
            reason: '${f.path} must not import the matrix');
        expect(src.contains('life_planet'), isFalse,
            reason: '${f.path} must not import engine planet enums');
        expect(src.contains('core/life_period'), isFalse,
            reason: '${f.path} must not import the engine');
      }
    });
  });
}
