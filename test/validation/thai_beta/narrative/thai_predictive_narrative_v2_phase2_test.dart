import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_narrative_plan.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../synthetic_audit/thai_beta_synthetic_matrix_300.dart';

const _forbiddenReaderPhrases = <String>[
  'อาจ',
  'มีแนวโน้มว่าอาจ',
  'ลองนึกย้อน',
  'ลองทบทวน',
];

void main() {
  group('Predictive Narrative V2 accepted Candidate 0011', () {
    test('Known normalized output exactly matches accepted fixture oracle', () {
      final analysis = _owner(known: true, minute: 3);
      final document = ThaiBetaReportExportDocument.candidate(analysis);
      final plan = document.narrativePlan!;

      expect(plan.contextId, 'mahabhut2537.rem0.saturday');
      expect(plan.monthlyTimelineAvailable, isFalse);
      expect(plan.atoms.whereType<PredictionAtom>(), hasLength(22));
      expect(
        _normalizedDocumentLines(document),
        _acceptedMarkdownLines(
          'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md',
        ),
      );
    });

    test('Unknown normalized output exactly matches fail-closed oracle', () {
      final analysis = _owner(known: false);
      final document = ThaiBetaReportExportDocument.candidate(analysis);
      final plan = document.narrativePlan!;

      expect(plan.contextId, 'unknown-time');
      expect(plan.isKnownTime, isFalse);
      expect(plan.atoms.whereType<OmissionAtom>(), hasLength(1));
      expect(plan.atoms.whereType<DisclosureAtom>(), hasLength(1));
      expect(plan.atoms.whereType<PredictionAtom>(), isEmpty);
      expect(
        _normalizedDocumentLines(document),
        _acceptedMarkdownLines(
          'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011_UNKNOWN.md',
        ),
      );
    });

    test('semantic owners are unique and advice stays outside prediction', () {
      final plan = PredictiveNarrativePlan.fromAnalysis(
        _owner(known: true, minute: 3),
      );
      final ownerIds = plan.atoms.map((atom) => atom.owner.id).toList();
      expect(ownerIds.toSet(), hasLength(ownerIds.length));
      expect(
        plan.sections
            .where((section) => section.role != NarrativeSectionRole.advice)
            .expand((section) => section.atoms)
            .whereType<AdviceAtom>(),
        isEmpty,
      );
      expect(plan.atoms.whereType<DisclosureAtom>(), hasLength(1));
    });

    test(
      'forbidden hedging, past-question and methodology copy stays absent',
      () {
        for (final known in [true, false]) {
          final document = ThaiBetaReportExportDocument.candidate(
            _owner(known: known, minute: 3),
          );
          for (final phrase in _forbiddenReaderPhrases) {
            expect(document.fullPlainText, isNot(contains(phrase)));
          }
          expect(document.fullPlainText, isNot(contains('วิธีคำนวณ')));
          expect(document.fullPlainText, isNot(contains('?')));
        }
      },
    );
  });

  group('fixture separation and surface parity', () {
    test('00:03 and 00:35 retain distinct canonical ascendants', () {
      final known0003 = ThaiBetaReportExportDocument.candidate(
        _owner(known: true, minute: 3),
      );
      final known0035 = ThaiBetaReportExportDocument.candidate(
        _owner(known: true, minute: 35),
      );
      expect(known0003.subtitle, contains('ลัคนาราศีกุมภ์ 9°24′'));
      expect(known0035.subtitle, contains('ลัคนาราศีกุมภ์ 19°19′'));
      expect(known0003.subtitle, isNot(equals(known0035.subtitle)));
      expect(known0003.subtitle, contains('วันเสาร์'));
      expect(known0035.subtitle, contains('วันเสาร์'));
    });

    test('Unknown leaks no ascendant, house, Thai day or Known atom', () {
      final known = PredictiveNarrativePlan.fromAnalysis(
        _owner(known: true, minute: 3),
      );
      final unknown = PredictiveNarrativePlan.fromAnalysis(
        _owner(known: false),
      );
      final unknownText = [
        unknown.title,
        unknown.subtitle,
        ...unknown.atoms.map((atom) => atom.readerText),
      ].join('\n');
      expect(unknownText, isNot(contains('ลัคนา')));
      expect(unknownText, isNot(contains('เรือน')));
      expect(unknownText, isNot(contains('วันทางโหราศาสตร์')));
      expect(
        unknown.atoms
            .map((atom) => atom.owner.id)
            .toSet()
            .intersection(known.atoms.map((atom) => atom.owner.id).toSet()),
        isEmpty,
      );
    });

    test(
      'all rendered document fields and infographic trace back to one plan',
      () {
        for (final known in [true, false]) {
          final document = ThaiBetaReportExportDocument.candidate(
            _owner(known: known, minute: 3),
          );
          final plan = document.narrativePlan!;
          final projected = <String>[
            for (final section in plan.sections) ...[
              section.title,
              for (final block in section.blocks) ...[
                ?block.heading,
                ...block.atoms.map((atom) => atom.readerText),
              ],
            ],
          ];
          final rendered = <String>[
            for (final section in document.sections) ...[
              section.title,
              ...section.paragraphs,
            ],
          ];
          expect(rendered, projected);
          expect(document.infographic, isNotNull);
          expect(document.infographic!.monthlyTimelineAvailable, isFalse);
          final ownerIds = plan.atoms.map((atom) => atom.owner.id).toSet();
          expect(
            document.infographic!.traceIds.where(ownerIds.contains).toSet(),
            ownerIds,
          );
        }
      },
    );
  });

  test(
    '300 profiles are deterministic and targeted audit covers 49 contexts',
    () {
      final contexts = <String>{};
      for (final synthetic in ThaiBetaSyntheticMatrix.build()) {
        final first = PredictiveNarrativePlan.fromAnalysis(
          ThaiBetaAnalysisRunner.run(
            synthetic.input,
            asOf: DateTime(2026, 8, 29),
          ),
        );
        final second = PredictiveNarrativePlan.fromAnalysis(
          ThaiBetaAnalysisRunner.run(
            synthetic.input,
            asOf: DateTime(2026, 8, 29),
          ),
        );
        expect(second.toMap(), first.toMap(), reason: synthetic.id);
        if (first.isKnownTime) contexts.add(first.contextId);
        expect(first.monthlyTimelineAvailable, isFalse);
        expect(
          first.atoms.map((atom) => atom.owner.id).toSet(),
          hasLength(first.atoms.length),
        );
      }
      // The canonical 300 matrix reaches 48/49 contexts. This source-derived
      // remainder-4 Friday case closes the one missing selector without changing
      // the shared population matrix or duplicating its 300-profile audit.
      final targeted = PredictiveNarrativePlan.fromAnalysis(
        ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'Context',
            lastName: 'Coverage',
            birthDate: DateTime(1986, 4, 18),
            birthHour: 12,
            province: 'กรุงเทพมหานคร',
            provinceKey: 'bangkok',
          ),
          asOf: DateTime(2026, 8, 29),
        ),
      );
      contexts.add(targeted.contextId);
      final expectedContexts = <String>{
        for (var remainder = 0; remainder < 7; remainder++)
          for (final weekday in const [
            'sunday',
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
          ])
            'mahabhut2537.rem$remainder.$weekday',
      };
      expect(
        expectedContexts.difference(contexts),
        isEmpty,
        reason: 'every one of the 49 runtime context selectors must be reached',
      );
    },
  );
}

ThaiBetaAnalysis _owner({required bool known, int minute = 3}) =>
    ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Acceptance',
        lastName: 'Fixture',
        birthDate: DateTime(1982, 6, 6),
        birthHour: known ? 0 : null,
        birthMinute: known ? minute : 0,
        birthTimeUnknown: !known,
        province: 'เชียงใหม่',
        provinceKey: 'chiang mai',
        gender: 'ชาย',
      ),
      asOf: DateTime(2026, 8, 29),
    );

List<String> _normalizedDocumentLines(ThaiBetaReportExportDocument document) =>
    [
      document.title,
      ...document.subtitle.split('\n'),
      for (final section in document.sections) ...[
        section.title,
        ...section.paragraphs,
      ],
    ].map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

List<String> _acceptedMarkdownLines(String path) {
  final source = File(path).readAsStringSync();
  final start = source.indexOf('Reader-facing candidate begins below.');
  final end = source.indexOf('Reader-facing candidate ends above.');
  expect(start, greaterThanOrEqualTo(0), reason: path);
  expect(end, greaterThan(start), reason: path);
  return source
      .substring(start, end)
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where(
        (line) =>
            line.isNotEmpty &&
            line != 'Reader-facing candidate begins below.' &&
            !line.startsWith('<!--'),
      )
      .map((line) => line.replaceFirst(RegExp(r'^#{1,6}\s+'), ''))
      .map((line) => line.replaceAll('<br>', ''))
      .toList(growable: false);
}
