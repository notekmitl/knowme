import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_reader_copy_repair.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/export/thai_beta_browser_print.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_shared_report_view.dart';

ThaiBetaAnalysis _analysis({required bool knownTime, int year = 2026}) =>
    ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Candidate',
        lastName: knownTime ? 'Known' : 'Unknown',
        birthDate: DateTime(1982, 6, 6),
        birthHour: knownTime ? 10 : null,
        birthMinute: knownTime ? 30 : 0,
        birthTimeUnknown: !knownTime,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
      startedAt: DateTime.utc(year, 1, 1),
      asOf: DateTime.utc(year, 1, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shared report presentation model', () {
    test('section and paragraph inventory is stable and traceable', () {
      final document = ThaiBetaReportExportDocument.candidate(
        _analysis(knownTime: true),
      );
      expect(document.sections, isNotEmpty);
      expect(
        document.sections.map((section) => section.id).toSet(),
        hasLength(document.sections.length),
      );
      for (final section in document.sections) {
        expect(
          section.id,
          matches(RegExp(r'^report-(body|timeline|disclaimer)-')),
        );
        expect(section.fieldSource, isNotEmpty);
        expect(section.visibilityRule, isNotEmpty);
        expect(section.knownUnknownRule, isNotEmpty);
        expect(section.paragraphIds, hasLength(section.paragraphs.length));
        expect(
          section.paragraphIds.toSet(),
          hasLength(section.paragraphs.length),
        );
      }
    });

    test(
      'dedicated PDF and browser print consume exact shared text and order',
      () async {
        final document = ThaiBetaReportExportDocument.candidate(
          _analysis(knownTime: true),
        );
        final pdf = await ThaiBetaReportPdfExporter.build(document);
        final markup = browserPrintMarkup(document);
        expect(pdf.plainText, document.fullPlainText);
        var cursor = -1;
        for (final section in document.sections) {
          final next = markup.indexOf('data-section-id="${section.id}"');
          expect(next, greaterThan(cursor), reason: section.id);
          cursor = next;
          for (final paragraph in section.paragraphs) {
            expect(markup, contains(const HtmlEscape().convert(paragraph)));
          }
        }
      },
    );

    test('candidate copy changes only declared reader-copy rules', () {
      final analysis = _analysis(knownTime: true);
      final before = ThaiBetaReportExportDocument.beforeReaderCopy(analysis);
      final after = ThaiBetaReportExportDocument.candidate(analysis);
      expect(before.sections.length, after.sections.length);
      for (var index = 0; index < before.sections.length; index++) {
        final left = before.sections[index];
        final right = after.sections[index];
        expect(left.id, right.id);
        expect(left.paragraphs.length, right.paragraphs.length);
        expect(ThaiBetaReaderCopyRepair.refine(left.title), right.title);
        for (var p = 0; p < left.paragraphs.length; p++) {
          expect(
            ThaiBetaReaderCopyRepair.refine(left.paragraphs[p]),
            right.paragraphs[p],
            reason: '${left.id}.p${p + 1}',
          );
        }
      }
      expect(after.fullPlainText, isNot(contains('แปลเป็นภาษาคน')));
      expect(after.fullPlainText, isNot(contains('จุดกระตุ้น')));
      expect(after.fullPlainText, isNot(contains('ธาตุขัดกัน')));
    });

    test('Known and Unknown share the summary-boundary infographic order', () {
      for (final knownTime in [true, false]) {
        final document = ThaiBetaReportExportDocument.candidate(
          _analysis(knownTime: knownTime),
        );
        expect(document.infographicInsertionSectionIndex, 2);
        final markup = browserPrintMarkup(
          document,
          infographicPng: Uint8List.fromList([1, 2, 3]),
        );
        final before = markup.indexOf(
          'data-section-id="${document.sections[2].id}"',
        );
        final image = markup.indexOf('class="infographic-page"');
        final after = markup.indexOf(
          'data-section-id="${document.sections[3].id}"',
        );
        expect(before, lessThan(image));
        expect(image, lessThan(after));
      }
    });
  });

  group('annual infographic evidence contract', () {
    test('year comes from Bangkok civil asOf and is never hard-coded', () {
      expect(
        ThaiBetaReportExportDocument.candidate(
          _analysis(knownTime: true, year: 2026),
        ).infographic!.buddhistYear,
        2569,
      );
      expect(
        ThaiBetaReportExportDocument.candidate(
          _analysis(knownTime: true, year: 2027),
        ).infographic!.buddhistYear,
        2570,
      );
    });

    test(
      'uses four evidence-backed domains and fails closed on month timeline',
      () {
        for (final knownTime in [true, false]) {
          final data = ThaiBetaReportExportDocument.candidate(
            _analysis(knownTime: knownTime),
          ).infographic!;
          expect(data.categories.map((category) => category.title), [
            'การงาน',
            'การเงิน',
            'ความรัก',
            'สุขภาพ',
          ]);
          expect(
            data.categories.every((category) => category.traceIds.isNotEmpty),
            isTrue,
          );
          expect(data.opportunity.trim(), isNotEmpty);
          expect(data.caution.trim(), isNotEmpty);
          expect(data.monthlyTimelineAvailable, isFalse);
          expect(data.monthlyGapReason, contains('ไม่มีคะแนนหรือหลักฐาน'));
          expect(data.title, isNot(contains('1982')));
          expect(data.title, isNot(contains('กรุงเทพมหานคร')));
          if (!knownTime) expect(data.disclaimer, contains('ไม่มีเวลาเกิด'));
        }
      },
    );

    for (final width in [360.0, 390.0]) {
      testWidgets(
        'mobile $width renders and exports deterministic 1080x1920 PNG',
        (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final key = GlobalKey();
          final document = ThaiBetaReportExportDocument.candidate(
            _analysis(knownTime: true),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ThaiBetaSharedReportView(
                    document: document,
                    infographicBoundaryKey: key,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            find.byKey(const Key('thai_annual_infographic_save')),
            findsOneWidget,
          );
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(key),
          );
          expect(boundary.size, ThaiBetaAnnualInfographicCapture.logicalSize);
          expect(ThaiBetaAnnualInfographicCapture.pixelRatio, 3);
          expect(ThaiBetaAnnualInfographicCapture.targetWidth, 1080);
          expect(ThaiBetaAnnualInfographicCapture.targetHeight, 1920);
          final repeated = ThaiBetaReportExportDocument.candidate(
            _analysis(knownTime: true),
          ).infographic!;
          expect(
            jsonEncode(_identity(document.infographic!)),
            jsonEncode(_identity(repeated)),
          );
        },
      );
    }
  });
}

Map<String, Object?> _identity(ThaiBetaAnnualInfographicData data) => {
  'year': data.buddhistYear,
  'theme': data.theme,
  'overview': data.overview,
  'categories': [
    for (final category in data.categories)
      {'id': category.id, 'title': category.title, 'summary': category.summary},
  ],
  'opportunity': data.opportunity,
  'caution': data.caution,
  'advice': data.primaryAdvice,
  'disclaimer': data.disclaimer,
  'traceIds': data.traceIds,
};
