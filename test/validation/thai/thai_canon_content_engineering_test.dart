import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_ingestion.dart';
import 'package:knowme/features/knowledge_workspace/canon_review/canon_reviewer_data.dart';
import 'package:knowme/features/knowledge_workspace/canon_review/canon_reviewer_workspace_page.dart';

/// Mahabhut Content Engineering V1. Reviewer aids (assistant / coverage /
/// consistency / workspace) are helpers only — they never create or alter
/// knowledge, and they compose the existing ingestion toolchain.

const _text = '''
บทที่ 1 ปฐมบท
[หน้า 1]
ย่อหน้าหนึ่ง

ย่อหน้าสอง
[หน้า 2]
ย่อหน้าสาม
''';

CanonCandidateStore _extracted() =>
    CanonExtractionEngine.extractText(_text, bookId: 'mahabhut').toStore();

void main() {
  group('Review Assistant', () {
    test('flags un-converted paragraphs until a type is assigned', () {
      final store = _extracted();
      final result = CanonReviewAssistant.review(store);
      final unconverted = result.annotations
          .where((a) => a.kind == CanonHighlightKind.unconverted)
          .length;
      expect(unconverted, store.length);
    });

    test('flags missing citation, duplicate and rule-without-cross-ref', () {
      final store = CanonCandidateStore(bookId: 'b', candidates: [
        CanonCandidateUnit(
            id: 'r1', bookId: 'b', statement: 'rule', type: CanonUnitType.rule,
            topic: 't', subject: 's', evidenceQuote: null, page: null),
        CanonCandidateUnit(
            id: 'c1', bookId: 'b', statement: 'same', type: CanonUnitType.concept,
            topic: 't', subject: 's', title: 'X', evidenceQuote: 'same', page: '1'),
        CanonCandidateUnit(
            id: 'c2', bookId: 'b', statement: 'same', type: CanonUnitType.concept,
            topic: 't', subject: 's', title: 'X', evidenceQuote: 'same', page: '1'),
      ]);
      final kinds =
          CanonReviewAssistant.review(store).annotations.map((a) => a.kind).toSet();
      expect(kinds, contains(CanonHighlightKind.missingCitation));
      expect(kinds, contains(CanonHighlightKind.duplicate));
      expect(kinds, contains(CanonHighlightKind.ruleWithoutCrossRef));
    });

    test('checklist auto-evaluates citation/page/metadata, marks manual items', () {
      final ok = CanonCandidateUnit(
        id: 'u', bookId: 'b', statement: 's', type: CanonUnitType.concept,
        topic: 't', subject: 's', title: 'T', evidenceQuote: 's', page: '1');
      final eval = CanonReviewChecklist.evaluate(ok);
      expect(eval['citation'], CanonChecklistState.pass);
      expect(eval['page'], CanonChecklistState.pass);
      expect(eval['metadata'], CanonChecklistState.pass);
      expect(eval['verbatim'], CanonChecklistState.manual);
      expect(CanonReviewChecklist.autoClean(ok), isTrue);
    });
  });

  group('Coverage Analysis', () {
    test('reports chapter/section/citation/validation coverage + density', () {
      final store = _extracted();
      var i = 0;
      for (final c in store.candidates) {
        c.type = CanonUnitType.concept;
        c.topic = 't';
        c.subject = 'subj$i';
        c.title = 'T$i';
        i++;
      }
      final first = store.candidates.first.id;
      CanonApprovalWorkflow.validate(store, first);
      CanonApprovalWorkflow.review(store, first);
      CanonApprovalWorkflow.approve(store, first);

      final r = CanonCoverageReport.analyze(store);
      expect(r.units, 3);
      expect(r.approvedUnits, 1);
      expect(r.citationCoverage, closeTo(1.0, 0.001)); // seeded quote + page
      expect(r.validationCoverage, closeTo(1.0, 0.001));
      expect(r.knowledgeDensity, greaterThan(0));
      expect(r.chapterCoverage, greaterThan(0));
    });
  });

  group('Consistency Checker', () {
    test('detects inconsistent concept naming and duplicate rule ids', () {
      final store = CanonCandidateStore(bookId: 'b', candidates: [
        CanonCandidateUnit(
            id: 'a', bookId: 'b', statement: 'x', type: CanonUnitType.concept,
            topic: 't', subject: 'venus', title: 'ดาวศุกร์',
            evidenceQuote: 'x', page: '1'),
        CanonCandidateUnit(
            id: 'b1', bookId: 'b', statement: 'y', type: CanonUnitType.concept,
            topic: 't', subject: 'venus', title: 'ศุกร์',
            evidenceQuote: 'y', page: '1'),
        CanonCandidateUnit(
            id: 'r1', bookId: 'b', statement: 'rule', type: CanonUnitType.rule,
            topic: 't', subject: 's', value: 'friend',
            evidenceQuote: 'rule', page: '1'),
        CanonCandidateUnit(
            id: 'r2', bookId: 'b', statement: 'rule', type: CanonUnitType.rule,
            topic: 't', subject: 's', value: 'friend',
            evidenceQuote: 'rule', page: '1'),
      ]);
      final report = CanonConsistencyChecker.check(store);
      expect(report.withCode('concept_naming'), isNotEmpty);
      expect(report.withCode('duplicate_rule_id'), isNotEmpty);
    });

    test('clean store has no consistency issues', () {
      final store = CanonCandidateStore(bookId: 'b', candidates: [
        CanonCandidateUnit(
            id: 'a', bookId: 'b', statement: 'x', type: CanonUnitType.concept,
            topic: 't', subject: 'venus', title: 'ศุกร์',
            evidenceQuote: 'x', page: '1'),
      ]);
      expect(CanonConsistencyChecker.check(store).isClean, isTrue);
    });
  });

  group('Reviewer Workspace UI', () {
    testWidgets('shows empty-state guidance with no candidates', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CanonReviewerWorkspacePage(data: CanonReviewerData.empty()),
      ));
      await tester.pumpAndSettle();
      expect(find.text('No candidate batch loaded'), findsOneWidget);
    });

    testWidgets('renders review/coverage/consistency tabs with candidates',
        (tester) async {
      final store = _extracted();
      for (final c in store.candidates) {
        c.type = CanonUnitType.concept;
        c.topic = 't';
        c.subject = c.id;
        c.title = c.id;
      }
      await tester.pumpWidget(MaterialApp(
        home: CanonReviewerWorkspacePage(
          data: CanonReviewerData.fromStore(store),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Coverage'), findsOneWidget);
      expect(find.text('Consistency'), findsOneWidget);
      // Selecting a candidate shows its detail.
      await tester.tap(find.text(store.candidates.first.id).first);
      await tester.pumpAndSettle();
      expect(find.text('Source text (verbatim)'), findsOneWidget);
      expect(find.text('Pre-approval checklist'), findsOneWidget);
    });
  });

  test('reviewer data round-trips from candidate JSON', () {
    final json = _extracted().toJsonString();
    final data = CanonReviewerData.fromCandidateJson(json);
    expect(data.store.length, 3);
    expect(data.isEmpty, isFalse);
  });
}
