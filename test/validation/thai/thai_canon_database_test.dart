import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_knowledge_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_conflict_resolver.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_database.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_extraction_pipeline.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_knowledge_index.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_library_manifest.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/knowledge_tier.dart';

/// Mahabhut Canon Database (Canon Extraction V1). Structure only — no real book
/// content. Pure knowledge layer; nothing imports the calculation engine.

/// A small, fully-wired sample corpus: book→chapter→section→topic→unit with
/// evidence, a source reference and a cross-reference.
String _sampleDbJson({
  String status = 'canonApproved',
  String value = 'friend',
}) =>
    '''
{
  "version": 1,
  "books": [
    { "id": "mahabhut", "sourceId": "mahabhut", "title": "หลักมหาภูต", "author": "ส. หยกฟ้า" }
  ],
  "chapters": [ { "id": "ch1", "bookId": "mahabhut", "number": 1, "title": "บท 1" } ],
  "sections": [ { "id": "s1", "chapterId": "ch1", "bookId": "mahabhut", "title": "หัวข้อ", "topic": "planet_relationship" } ],
  "topics": [ { "id": "t1", "sectionId": "s1", "bookId": "mahabhut", "title": "ศุกร์-เสาร์" } ],
  "units": [
    { "id": "u1", "type": "rule", "topic": "planet_relationship", "subject": "venus->saturn",
      "statement": "ศุกร์เป็นมิตรกับเสาร์", "value": "$value", "confidence": "high",
      "validationStatus": "$status",
      "location": { "bookId": "mahabhut", "chapterId": "ch1", "sectionId": "s1", "topicId": "t1", "page": "128" },
      "evidenceIds": ["e1"], "sourceReferenceIds": ["sr1"], "crossReferenceIds": ["x1"] },
    { "id": "u2", "type": "example", "topic": "planet_relationship", "subject": "venus->saturn",
      "statement": "ตัวอย่าง", "validationStatus": "$status",
      "location": { "bookId": "mahabhut", "sectionId": "s1", "page": "129" } }
  ],
  "evidence": [ { "id": "e1", "unitId": "u1", "sourceReferenceId": "sr1", "page": "128", "quote": "ศุกร์...เสาร์" } ],
  "crossReferences": [ { "id": "x1", "fromId": "u1", "toId": "u2", "type": "exampleOf" } ],
  "sourceReferences": [ { "id": "sr1", "sourceId": "mahabhut", "citation": "หลักมหาภูต น.128", "page": "128" } ]
}
''';

void main() {
  group('Canon DB — entities + loading', () {
    test('loads a fully-wired corpus without errors', () {
      final r = CanonDatabase.load(_sampleDbJson());
      expect(r.hasErrors, isFalse, reason: r.issues.join('\n'));
      final db = r.database;
      expect(db.books.length, 1);
      expect(db.units.length, 2);
      expect(db.evidence.length, 1);
      expect(db.crossReferences.length, 1);
      expect(db.sourceReferences.length, 1);
    });

    test('unit type maps to resolver category only for assertive kinds', () {
      expect(CanonUnitType.rule.resolverCategory, isNotNull);
      expect(CanonUnitType.example.resolverCategory, isNull);
      expect(CanonUnitType.condition.resolverCategory, isNull);
      expect(CanonUnitType.topic.resolverCategory, isNull);
    });

    test('validation status is monotonic', () {
      expect(CanonValidationStatus.canonApproved
          .atLeast(CanonValidationStatus.draft), isTrue);
      expect(CanonValidationStatus.draft
          .atLeast(CanonValidationStatus.canonApproved), isFalse);
    });
  });

  group('Canon DB — traceability', () {
    test('resolves full provenance chain for a unit', () {
      final db = CanonDatabase.load(_sampleDbJson()).database;
      final trace = db.trace('u1')!;
      expect(trace.book!.title, 'หลักมหาภูต');
      expect(trace.chapter!.id, 'ch1');
      expect(trace.section!.id, 's1');
      expect(trace.topic!.id, 't1');
      expect(trace.sourceReferences.single.id, 'sr1');
      expect(trace.citation, contains('หลักมหาภูต'));
      expect(trace.citation, contains('น.128'));
    });

    test('chapter is inferred from the section when omitted on the unit', () {
      final db = CanonDatabase.load(_sampleDbJson()).database;
      // u2 has no chapterId in its location but its section does.
      expect(db.trace('u2')!.chapter!.id, 'ch1');
    });
  });

  group('Canon DB — validation', () {
    test('flags broken parent / location / evidence / cross-ref', () {
      const bad = '''
      { "version": 1,
        "books": [ { "id": "b1", "sourceId": "mahabhut", "title": "B" } ],
        "chapters": [ { "id": "c1", "bookId": "ghost", "title": "C" } ],
        "units": [ { "id": "u1", "type": "rule", "topic": "x", "subject": "y",
          "statement": "s", "location": { "bookId": "b1", "sectionId": "ghost" },
          "evidenceIds": ["ghost"], "crossReferenceIds": ["ghost"] } ],
        "crossReferences": [ { "id": "x1", "fromId": "u1", "toId": "ghost", "type": "seeAlso" } ] }''';
      final issues = CanonDatabase.load(bad).issues;
      final codes = issues.map((i) => i.code).toSet();
      expect(codes, contains('broken_parent'));
      expect(codes, contains('broken_location'));
      expect(codes, contains('broken_evidence'));
      expect(codes, contains('broken_cross_ref'));
      expect(codes, contains('dangling_cross_ref'));
    });

    test('duplicate ids are errors', () {
      const dup = '''
      { "version": 1, "books": [
        { "id": "b", "sourceId": "mahabhut", "title": "A" },
        { "id": "b", "sourceId": "mahabhut", "title": "B" } ] }''';
      expect(CanonDatabase.load(dup).issues.any((i) => i.code == 'duplicate_book'),
          isTrue);
    });

    test('evidence with a page reference but no quote is allowed', () {
      // Provenance is by reference; storing a copyrighted quote is not required.
      const pageOnly = '''
      { "version": 1, "evidence": [ { "id": "e1", "page": "1" } ] }''';
      expect(CanonDatabase.load(pageOnly).warnings.any(
          (w) => w.code == 'evidence_no_quote'), isFalse);
    });

    test('evidence with neither page nor quote warns (no provenance)', () {
      const noProvenance = '''
      { "version": 1, "evidence": [ { "id": "e1" } ] }''';
      expect(CanonDatabase.load(noProvenance).warnings.any(
          (w) => w.code == 'evidence_no_quote'), isTrue);
    });

    test('malformed JSON degrades to an error', () {
      final r = CanonDatabase.load('nope');
      expect(r.hasErrors, isTrue);
      expect(r.database.units, isEmpty);
    });
  });

  group('Canon DB — coverage', () {
    test('counts entities, types and approval', () {
      final db = CanonDatabase.load(_sampleDbJson()).database;
      final cov = db.coverage();
      expect(cov.books, 1);
      expect(cov.units, 2);
      expect(cov.canonApprovedUnits, 2);
      expect(cov.unitsByType[CanonUnitType.rule], 1);
      expect(cov.unitsByType[CanonUnitType.example], 1);
    });
  });

  group('Canon DB — knowledge index (reasoning seam)', () {
    test('query returns canon-approved hits with traces', () {
      final db = CanonDatabase.load(_sampleDbJson()).database;
      final index = CanonKnowledgeIndex.build(db);
      final hits = index.approvedFor('planet_relationship', 'venus->saturn');
      expect(hits, isNotEmpty);
      expect(hits.first.citation, contains('หลักมหาภูต'));
    });

    test('non-approved units are excluded by default', () {
      final db = CanonDatabase.load(_sampleDbJson(status: 'reviewed')).database;
      final index = CanonKnowledgeIndex.build(db);
      expect(index.approvedFor('planet_relationship', 'venus->saturn'), isEmpty);
      // But relaxing minStatus surfaces them.
      final relaxed = index.query(
        topic: 'planet_relationship',
        minStatus: CanonValidationStatus.reviewed,
      );
      expect(relaxed, isNotEmpty);
    });
  });

  group('Canon DB — extraction pipeline', () {
    test('empty DB has not progressed past the first stage', () {
      final db = CanonDatabase();
      final status = CanonExtractionPipeline.statusFor(db);
      expect(status.perStage[CanonPipelineStage.book], isFalse);
      expect(status.perStage[CanonPipelineStage.reasoningEngine], isFalse);
    });

    test('fully-wired approved DB reaches the reasoning engine', () {
      final db = CanonDatabase.load(_sampleDbJson()).database;
      final status = CanonExtractionPipeline.statusFor(db);
      expect(status.reached, CanonPipelineStage.reasoningEngine);
      expect(status.perStage[CanonPipelineStage.reasoningEngine], isTrue);
      expect(status.blockingIssues, isEmpty);
      // The pipeline yields a usable index.
      final index = CanonExtractionPipeline.toKnowledgeIndex(db);
      expect(index.approvedFor('planet_relationship', 'venus->saturn'),
          isNotEmpty);
    });

    test('validation errors block the canon-database stage', () {
      const bad = '''
      { "version": 1, "books": [ { "id": "b", "sourceId": "m", "title": "B" } ],
        "chapters": [ { "id": "c", "bookId": "ghost", "title": "C" } ] }''';
      final db = CanonDatabase.load(bad).database;
      final status = CanonExtractionPipeline.statusFor(db);
      expect(status.perStage[CanonPipelineStage.canonDatabase], isFalse);
      expect(status.blockingIssues, isNotEmpty);
    });
  });

  group('Canon DB — V1 compatibility bridge', () {
    test('approved assertive units convert to CanonicalKnowledgeNodes and '
        'feed the V1 resolver (Canon wins)', () {
      final db = CanonDatabase.load(_sampleDbJson()).database;
      final nodes = db.toCanonNodes(
        tierOf: (sourceId) =>
            sourceId == 'mahabhut' ? KnowledgeTier.canon : KnowledgeTier.internet,
      );
      // Only the assertive rule converts; the example is skipped.
      expect(nodes.length, 1);
      expect(nodes.single.tier, KnowledgeTier.canon);
      expect(nodes.single.canonical, isTrue);
      final res =
          CanonConflictResolver.resolveSubject(nodes).rationale.isNotEmpty;
      expect(res, isTrue);
      final resolution = CanonConflictResolver.resolveSubject(nodes);
      expect(resolution.outcome, CanonResolutionOutcome.canonical);
      expect(resolution.value, 'friend');
    });

    test('engine loaded from canon_sources can resolve tiers for the bridge',
        () {
      final sources =
          File('knowledge/canon/canon_sources.json').readAsStringSync();
      final nodes = File('knowledge/canon/canon.knowme.json').readAsStringSync();
      final engine =
          CanonKnowledgeEngine.load(sourcesJson: sources, nodesJson: nodes)
              .engine;
      final db = CanonDatabase.load(_sampleDbJson()).database;
      final canonNodes = db.toCanonNodes(
        tierOf: (id) => engine.source(id)?.tier ?? KnowledgeTier.internet,
        isCanonOf: (id) => engine.source(id)?.isCanon ?? false,
      );
      expect(canonNodes.single.tier, KnowledgeTier.canon);
    });
  });

  group('Canon DB — library manifest (multi-book)', () {
    test('parses the shipped library manifest with หลักมหาภูต canonical', () {
      final json = File('knowledge/canon/library.manifest.json').readAsStringSync();
      final lib = CanonLibraryManifest.fromJson(json);
      expect(lib.books.length, greaterThanOrEqualTo(1));
      final mb = lib.book('mahabhut')!;
      expect(mb.canonical, isTrue);
      expect(mb.extraction, CanonBookExtractionState.notStarted);
      expect(lib.canonicalBooks, isNotEmpty);
    });

    test('supports many books and aggregates progress', () {
      const json = '''
      { "version": 1, "books": [
        { "bookId": "a", "sourceId": "mahabhut", "title": "A", "canonical": true,
          "progress": { "totalSections": 10, "extractedSections": 5 } },
        { "bookId": "b", "sourceId": "phrommachat", "title": "B",
          "progress": { "totalSections": 10, "extractedSections": 0 } }
      ] }''';
      final lib = CanonLibraryManifest.fromJson(json);
      expect(lib.books.length, 2);
      expect(lib.overallProgress, 0.25);
    });
  });

  group('Canon DB — shipped baseline is empty (no fabricated content)', () {
    test('canon_database.knowme.json is a valid empty database', () {
      final json =
          File('knowledge/canon/canon_database.knowme.json').readAsStringSync();
      final r = CanonDatabase.load(json);
      expect(r.hasErrors, isFalse, reason: r.issues.join('\n'));
      expect(r.database.units, isEmpty);
      expect(r.database.books, isEmpty);
    });
  });

  group('Canon DB — decoupling', () {
    test('database layer never imports the engine / matrix', () {
      final dir =
          Directory('lib/features/astrology/thai/knowledge/canon/database');
      for (final f in dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final src = f.readAsStringSync();
        expect(src.contains('planet_relationship_matrix'), isFalse,
            reason: '${f.path} must not import the matrix');
        expect(src.contains('core/life_period'), isFalse,
            reason: '${f.path} must not import the engine');
      }
    });
  });
}
