import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_database.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_ingestion.dart';

/// Mahabhut Ingestion Toolchain V1. The toolchain only restructures provided
/// text into candidates; it never invents knowledge and never auto-approves.
/// Pure knowledge layer; nothing imports the calculation engine.

const _sampleText = '''
บทที่ 1 ปฐมบท
[หน้า 1]
ความรู้ข้อแรกของหนังสือ ย่อหน้าที่หนึ่ง

ย่อหน้าที่สองในหัวข้อเดียวกัน
## หัวข้อ ความสัมพันธ์ดาว
[หน้า 2]
ศุกร์เป็นมิตรกับเสาร์ ตามตำรา
''';

void main() {
  group('Toolchain — import pipeline (parse)', () {
    test('segments chapters, sections, pages and paragraphs verbatim', () {
      final doc = CanonSourceDocument.parse(_sampleText, bookId: 'mahabhut');
      expect(doc.chapters.length, 1);
      expect(doc.chapters.first.title, contains('ปฐมบท'));
      // Two sections: implicit (before ##) + "ความสัมพันธ์ดาว".
      expect(doc.chapters.first.sections.length, 2);
      expect(doc.paragraphs.length, 3);
      expect(doc.paragraphs.first.page, '1');
      expect(doc.paragraphs.last.page, '2');
      expect(doc.paragraphs.last.text, contains('ศุกร์เป็นมิตรกับเสาร์'));
    });

    test('text before any chapter is noted, not dropped', () {
      final doc = CanonSourceDocument.parse('ข้อความนำก่อนบท', bookId: 'b');
      expect(doc.paragraphs.length, 1);
      expect(doc.notes, isNotEmpty);
    });
  });

  group('Toolchain — extraction engine (candidates only)', () {
    test('produces verbatim candidates with no semantic interpretation', () {
      final result =
          CanonExtractionEngine.extractText(_sampleText, bookId: 'mahabhut');
      expect(result.candidates.length, 3);
      for (final c in result.candidates) {
        // Verbatim statement is working material; provenance is by reference
        // (page + chapter/section). No copyrighted quote is stored.
        expect(c.statement, isNotEmpty);
        expect(c.evidenceQuote, isNull);
        expect(c.hasCitation, isTrue); // reference present (page/chapter/section)
        expect(c.status, CanonCandidateStatus.candidate);
        expect(c.type, isNull);
        expect(c.topic, isEmpty);
        expect(c.subject, isEmpty);
      }
      expect(result.chapters.length, 1);
      expect(result.sections.length, 2);
    });
  });

  group('Toolchain — validation engine', () {
    CanonCandidateStore storeWith(void Function(CanonCandidateUnit) annotate) {
      final result =
          CanonExtractionEngine.extractText(_sampleText, bookId: 'mahabhut');
      final store = result.toStore();
      for (final c in store.candidates) {
        annotate(c);
      }
      return store;
    }

    test('flags required fields / missing type until annotated', () {
      final store = storeWith((_) {});
      final report = CanonCandidateValidator.validate(store);
      expect(report.isClean, isFalse);
      expect(report.countsByCode['required_fields'], greaterThan(0));
    });

    test('clean once type/topic/subject + citation + page are present', () {
      final store = storeWith((c) {
        c.type = CanonUnitType.concept;
        c.topic = 'planet_relationship';
        c.subject = 'venus->saturn';
      });
      final report = CanonCandidateValidator.validate(store);
      expect(report.isClean, isTrue, reason: report.errors.join('\n'));
    });

    test('detects duplicate, empty rule, missing page, broken cross-ref', () {
      final a = CanonCandidateUnit(
        id: 'a', bookId: 'b', statement: '', page: null,
        type: CanonUnitType.rule, topic: 't', subject: 's',
        evidenceQuote: null,
        crossRefs: [const CanonCandidateCrossRef(
            toId: 'ghost', type: CanonCrossReferenceType.ruleToRule)],
      );
      final dup1 = CanonCandidateUnit(
        id: 'd1', bookId: 'b', statement: 'same', page: '1',
        type: CanonUnitType.concept, topic: 't', subject: 's',
        evidenceQuote: 'same');
      final dup2 = CanonCandidateUnit(
        id: 'd2', bookId: 'b', statement: 'same', page: '1',
        type: CanonUnitType.concept, topic: 't', subject: 's',
        evidenceQuote: 'same');
      final store = CanonCandidateStore(bookId: 'b', candidates: [a, dup1, dup2]);
      final codes = CanonCandidateValidator.validate(store)
          .issues
          .map((i) => i.code)
          .toSet();
      expect(codes, contains('empty_rule'));
      expect(codes, contains('missing_page'));
      expect(codes, contains('missing_citation'));
      expect(codes, contains('broken_reference'));
      expect(codes, contains('duplicate'));
    });
  });

  group('Toolchain — approval workflow (state machine)', () {
    CanonCandidateStore annotated() {
      final store =
          CanonExtractionEngine.extractText(_sampleText, bookId: 'mahabhut')
              .toStore();
      var i = 0;
      for (final c in store.candidates) {
        c.type = CanonUnitType.concept;
        c.topic = 'planet_relationship';
        c.subject = 'subj$i';
        c.confidence = KnowledgeConfidence.high;
        i++;
      }
      return store;
    }

    test('enforces candidate→validated→reviewed→canonApproved order', () {
      final store = annotated();
      final id = store.candidates.first.id;
      // Cannot skip straight to approve.
      expect(CanonApprovalWorkflow.approve(store, id).ok, isFalse);
      expect(CanonApprovalWorkflow.validate(store, id).ok, isTrue);
      expect(store.byId(id)!.status, CanonCandidateStatus.validated);
      expect(CanonApprovalWorkflow.review(store, id).ok, isTrue);
      expect(CanonApprovalWorkflow.approve(store, id).ok, isTrue);
      expect(store.byId(id)!.status, CanonCandidateStatus.canonApproved);
    });

    test('validation gate blocks promotion of un-annotated candidates', () {
      final store =
          CanonExtractionEngine.extractText(_sampleText, bookId: 'mahabhut')
              .toStore();
      final id = store.candidates.first.id;
      expect(CanonApprovalWorkflow.validate(store, id).ok, isFalse);
    });
  });

  group('Toolchain — promotion feeds the Canon Database', () {
    test('approved candidates promote into a valid DB patch', () {
      final result =
          CanonExtractionEngine.extractText(_sampleText, bookId: 'mahabhut');
      final store = result.toStore();
      var i = 0;
      for (final c in store.candidates) {
        c.type = CanonUnitType.rule;
        c.topic = 'planet_relationship';
        c.subject = 'subj$i';
        c.value = 'friend';
        i++;
        CanonApprovalWorkflow.validate(store, c.id);
        CanonApprovalWorkflow.review(store, c.id);
        CanonApprovalWorkflow.approve(store, c.id);
      }
      final patch = CanonApprovalWorkflow.promote(store, extraction: result);
      expect(patch.units, isNotEmpty);
      expect(patch.evidence.length, patch.units.length);

      // The patch loads into the Canon Database and validates, with a real
      // book entity supplied alongside.
      final dbJson = '''
      { "version": 1,
        "books": [ { "id": "mahabhut", "sourceId": "mahabhut", "title": "หลักมหาภูต" } ],
        "chapters": ${_arr(patch.toJson()['chapters'])},
        "sections": ${_arr(patch.toJson()['sections'])},
        "units": ${_arr(patch.toJson()['units'])},
        "evidence": ${_arr(patch.toJson()['evidence'])},
        "crossReferences": ${_arr(patch.toJson()['crossReferences'])} }''';
      final loaded = CanonDatabase.load(dbJson);
      expect(loaded.hasErrors, isFalse, reason: loaded.issues.join('\n'));
      expect(loaded.database.units.length, patch.units.length);
      // Traceability survives the round-trip.
      final anyUnit = loaded.database.units.first;
      expect(loaded.database.trace(anyUnit.id)!.book!.id, 'mahabhut');
    });
  });

  group('Toolchain — diff engine', () {
    test('reports added/removed/changed incl. rule + citation changes', () {
      final v1 = CanonCandidateStore(bookId: 'b', candidates: [
        CanonCandidateUnit(
            id: 'u1', bookId: 'b', statement: 'old', page: '1',
            type: CanonUnitType.rule, value: 'friend', evidenceQuote: 'old'),
        CanonCandidateUnit(id: 'u2', bookId: 'b', statement: 'stays'),
      ]);
      final v2 = CanonCandidateStore(bookId: 'b', candidates: [
        CanonCandidateUnit(
            id: 'u1', bookId: 'b', statement: 'new', page: '2',
            type: CanonUnitType.rule, value: 'enemy', evidenceQuote: 'new'),
        CanonCandidateUnit(id: 'u3', bookId: 'b', statement: 'fresh'),
      ]);
      final report = CanonDiffEngine.diff(v1, v2);
      expect(report.added, contains('u3'));
      expect(report.removed, contains('u2'));
      final u1 = report.changed.firstWhere((d) => d.id == 'u1');
      expect(u1.ruleChanged, isTrue);
      expect(u1.citationChanged, isTrue);
      expect(u1.statementChanged, isTrue);
    });
  });

  group('Toolchain — QA tools', () {
    test('missing citation, duplicate rule, orphan rule, empty concept', () {
      final store = CanonCandidateStore(bookId: 'b', candidates: [
        CanonCandidateUnit(id: 'noCite', bookId: 'b', statement: 'x',
            type: CanonUnitType.rule, topic: 't', subject: 's',
            evidenceQuote: null, page: null),
        CanonCandidateUnit(id: 'r1', bookId: 'b', statement: 'dup',
            type: CanonUnitType.rule, topic: 't', subject: 's',
            evidenceQuote: 'dup', page: '1'),
        CanonCandidateUnit(id: 'r2', bookId: 'b', statement: 'dup',
            type: CanonUnitType.rule, topic: 't', subject: 's',
            evidenceQuote: 'dup', page: '1'),
        CanonCandidateUnit(id: 'emptyC', bookId: 'b', statement: '',
            type: CanonUnitType.concept, topic: 't', subject: 's'),
      ]);
      expect(CanonQaTools.missingCitation(store).count, greaterThan(0));
      expect(CanonQaTools.duplicateRule(store).count, 1);
      expect(CanonQaTools.orphanRule(store).count, greaterThan(0));
      expect(CanonQaTools.emptyConcept(store).count, 1);
    });

    test('broken cross reference report', () {
      final store = CanonCandidateStore(bookId: 'b', candidates: [
        CanonCandidateUnit(id: 'a', bookId: 'b', statement: 'x', crossRefs: [
          const CanonCandidateCrossRef(
              toId: 'ghost', type: CanonCrossReferenceType.seeAlso),
        ]),
      ]);
      expect(CanonQaTools.brokenCrossReference(store).count, 1);
    });
  });

  group('Toolchain — extraction metrics', () {
    test('counts statuses, coverage and progress', () {
      final store =
          CanonExtractionEngine.extractText(_sampleText, bookId: 'mahabhut')
              .toStore();
      var i = 0;
      for (final c in store.candidates) {
        c.type = CanonUnitType.concept;
        c.topic = 't';
        c.subject = 'subj$i';
        i++;
      }
      // Approve exactly one.
      final first = store.candidates.first.id;
      CanonApprovalWorkflow.validate(store, first);
      CanonApprovalWorkflow.review(store, first);
      CanonApprovalWorkflow.approve(store, first);

      final m = CanonExtractionMetrics.of(store);
      expect(m.extracted, 3);
      expect(m.approved, 1);
      expect(m.coverage, closeTo(1 / 3, 0.001));
      expect(m.chapters, 1);
    });
  });

  group('Toolchain — round-trip + decoupling', () {
    test('candidate store serialises and reloads', () {
      final store =
          CanonExtractionEngine.extractText(_sampleText, bookId: 'mahabhut')
              .toStore();
      final reloaded = CanonCandidateStore.fromJsonString(store.toJsonString());
      expect(reloaded.length, store.length);
      expect(reloaded.bookId, 'mahabhut');
    });

    test('ingestion layer never imports the engine / matrix / flutter', () {
      final dir = Directory(
          'lib/features/astrology/thai/knowledge/canon/ingestion');
      for (final f in dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final src = f.readAsStringSync();
        expect(src.contains('planet_relationship_matrix'), isFalse);
        expect(src.contains('core/life_period'), isFalse);
        expect(src.contains("package:flutter/"), isFalse,
            reason: '${f.path} must stay pure Dart for the CLI');
      }
    });
  });
}

String _arr(Object? v) {
  // Compact JSON array for embedding in the test DB string.
  return _encode(v);
}

String _encode(Object? v) {
  if (v is List) return '[${v.map(_encode).join(',')}]';
  if (v is Map) {
    final entries =
        v.entries.map((e) => '${_encode(e.key.toString())}:${_encode(e.value)}');
    return '{${entries.join(',')}}';
  }
  if (v is String) return '"${v.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
  if (v == null) return 'null';
  return v.toString();
}
