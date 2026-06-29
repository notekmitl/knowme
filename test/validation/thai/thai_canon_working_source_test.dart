import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/authoring/authoring.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/working_source/working_source.dart';

/// Canon Working Source Adapter — temporary source material for the Authoring
/// Studio. Pure adapter layer; no engine/runtime/ontology/workspace change.

const _ref = WorkingSourceRef(
  bookId: 'mahabhut',
  edition: '1',
  chapter: '1',
  title: 'หลักมหาภูต',
);

/// The same logical content expressed two ways.
const _markedText = '''
[page 127]
Alpha paragraph one.

Alpha paragraph two.
[page 128]
Beta paragraph.
''';

const _pageInputs = [
  WorkingPageInput(
      pageRef: '127', text: 'Alpha paragraph one.\n\nAlpha paragraph two.'),
  WorkingPageInput(pageRef: '128', text: 'Beta paragraph.'),
];

/// A reviewer-facing helper that depends ONLY on the WorkingSource interface
/// (never a concrete file type) to drive the frozen Authoring Studio.
AuthoringStudio _studioForPage(WorkingSource src, WorkingPage page) =>
    AuthoringStudio(
      id: 'ws-${page.pageRef}',
      source: src.extractionSourceForPage(page, reviewer: 'qa'),
    );

void main() {
  group('Every source type produces identical Working Pages', () {
    test('txt / ocr / pdf / image agree on equivalent content', () {
      final txt = TxtWorkingSource(ref: _ref, text: _markedText);
      final ocr = OcrWorkingSource(ref: _ref, ocrText: _markedText);
      final pdf = PdfWorkingSource(ref: _ref, pageTexts: _pageInputs);
      final img = ImageWorkingSource(ref: _ref, pageTexts: _pageInputs);

      expect(txt.pages(), ocr.pages());
      expect(txt.pages(), pdf.pages());
      expect(txt.pages(), img.pages());

      expect(txt.pages().map((p) => p.pageRef).toList(), ['127', '128']);
      expect(txt.page('127')!.paragraphs.map((p) => p.text).toList(),
          ['Alpha paragraph one.', 'Alpha paragraph two.']);
    });
  });

  group('Page references are deterministic', () {
    test('parsing the same input twice yields identical pages', () {
      final a = TxtWorkingSource(ref: _ref, text: _markedText).pages();
      final b = TxtWorkingSource(ref: _ref, text: _markedText).pages();
      expect(a, b);
      expect(a.map((p) => p.signature), b.map((p) => p.signature));
    });

    test('extraction source carries refs only — never prose', () {
      final src = PdfWorkingSource(ref: _ref, pageTexts: _pageInputs);
      final es = src.extractionSourceForPage(src.page('127')!, reviewer: 'qa');
      expect(es.bookId, 'mahabhut');
      expect(es.chapter, '1');
      expect(es.pageStart, 127);
      final json = jsonEncode(es.toJson());
      expect(json.contains('Alpha paragraph'), isFalse);
    });
  });

  group('Working Sources never reach Canon', () {
    // Author a page into atomic units whose tokens are ontology ids, then prove
    // the Canon-bound artifacts contain no working-source prose.
    AuthoringStudio authored(WorkingSource src) {
      final studio = _studioForPage(src, src.page('127')!);
      studio.addDraft(
        subject: 'planet.sun',
        object: 'domain.career',
        edit: (d) {
          d.subjectKind = AtomicEntityKind.planet;
          d.objectKind = AtomicEntityKind.domain;
          d.relation = AtomicRelation.owns;
          d.confidence = KnowledgeConfidence.high;
        },
      );
      return studio;
    }

    test('session + review output carry references, not paragraphs', () {
      final src = TxtWorkingSource(ref: _ref, text: _markedText);
      final studio = authored(src);
      final sessionJson = jsonEncode(studio.toSession().toJson());

      expect(sessionJson.contains('Alpha paragraph'), isFalse);
      expect(sessionJson.contains('Beta paragraph'), isFalse);
      // Only the page reference survives, as evidence provenance.
      expect(studio.toSession().units.single.evidence.page, '127');
      expect(studio.toSession().units.single.evidence.bookId, 'mahabhut');
    });

    test('deleting the Working Source leaves Canon intact', () {
      final src = TxtWorkingSource(ref: _ref, text: _markedText);
      final studio = authored(src);
      final before = jsonEncode(studio.toSession().toJson());

      src.dispose();

      expect(src.isDisposed, isTrue);
      expect(src.pages(), isEmpty);
      // The authored Canon material is unchanged after the source is discarded.
      final after = jsonEncode(studio.toSession().toJson());
      expect(after, before);
      expect(studio.toSession().units.single.subject, 'planet.sun');
    });

    test('dispose is idempotent', () {
      final src = OcrWorkingSource(ref: _ref, ocrText: _markedText);
      src.dispose();
      src.dispose();
      expect(src.pages(), isEmpty);
    });
  });

  group('Parsing edge cases', () {
    test('no markers → a single page "1"', () {
      final src = TxtWorkingSource(ref: _ref, text: 'one fact\n\ntwo fact');
      expect(src.pages().single.pageRef, '1');
      expect(src.pages().single.paragraphs.length, 2);
    });

    test('Thai page markers are recognised', () {
      final src = TxtWorkingSource(ref: _ref, text: '[หน้า 12]\nสาระ');
      expect(src.page('12'), isNotNull);
    });
  });

  group('Decoupling — no runtime dependency', () {
    test('working_source imports no engine/runtime/matrix/mirror/fusion/canon-db',
        () {
      final dir = Directory(
          'lib/features/astrology/thai/knowledge/canon/working_source');
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
          'canon_database',
        ]) {
          expect(imports.contains(forbidden), isFalse,
              reason: '${f.path} must not import $forbidden');
        }
      }
    });
  });
}
