import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
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
      startedAt: DateTime.utc(year, 8, 7),
      asOf: DateTime.utc(year, 8, 7),
    );

ThaiBetaAnalysis _regression1972() => ThaiBetaAnalysisRunner.run(
  ThaiBetaInput(
    firstName: 'Regression',
    lastName: '1972',
    birthDate: DateTime(1972, 4, 4),
    birthHour: 10,
    birthMinute: 30,
    province: 'กรุงเทพมหานคร',
    provinceKey: 'bangkok',
  ),
  startedAt: DateTime.utc(2026, 8, 7),
  asOf: DateTime.utc(2026, 8, 7),
);

ThaiBetaAnalysis _fixtureAnalysis(String fixtureId) {
  ThaiBetaInput input;
  switch (fixtureId) {
    case 'known':
      return _analysis(knownTime: true);
    case 'unknown':
      return _analysis(knownTime: false);
    case 'owner-known-0035':
      input = ThaiBetaInput(
        firstName: 'Acceptance',
        lastName: 'Fixture',
        birthDate: DateTime(1982, 6, 6),
        birthHour: 0,
        birthMinute: 35,
        province: 'เชียงใหม่',
        provinceKey: 'chiang_mai',
      );
      break;
    case 'owner-unknown':
      input = ThaiBetaInput(
        firstName: 'Acceptance',
        lastName: 'Fixture',
        birthDate: DateTime(1982, 6, 6),
        birthTimeUnknown: true,
        province: 'เชียงใหม่',
        provinceKey: 'chiang_mai',
      );
      break;
    case 'regression-known-0003':
      input = ThaiBetaInput(
        firstName: 'Acceptance',
        lastName: 'Fixture',
        birthDate: DateTime(1982, 6, 6),
        birthHour: 0,
        birthMinute: 3,
        province: 'เชียงใหม่',
        provinceKey: 'chiang_mai',
      );
      break;
    case 'comparison-known-bangkok':
      input = ThaiBetaInput(
        firstName: 'Comparison',
        lastName: 'Fixture',
        birthDate: DateTime(1991, 11, 18),
        birthHour: 14,
        birthMinute: 20,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      );
      break;
    case 'comparison-known-khon-kaen':
      input = ThaiBetaInput(
        firstName: 'Comparison',
        lastName: 'Fixture',
        birthDate: DateTime(1974, 2, 27),
        birthHour: 6,
        birthMinute: 45,
        province: 'ขอนแก่น',
        provinceKey: 'khon_kaen',
      );
      break;
    default:
      throw ArgumentError.value(fixtureId, 'fixtureId');
  }
  return ThaiBetaAnalysisRunner.run(
    input,
    startedAt: DateTime.utc(2026, 8, 7),
    asOf: DateTime.utc(2026, 8, 7),
  );
}

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
          matches(RegExp(r'^report-(chapter|body|timeline|disclaimer)-')),
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
      'all seven PDF fixtures preserve the page-one and semantic contract',
      () async {
        for (final fixtureId in const [
          'known',
          'unknown',
          'owner-known-0035',
          'owner-unknown',
          'regression-known-0003',
          'comparison-known-bangkok',
          'comparison-known-khon-kaen',
        ]) {
          final document = ThaiBetaReportExportDocument.candidate(
            _fixtureAnalysis(fixtureId),
          );
          final pdf = await ThaiBetaReportPdfExporter.build(document);
          final markup = browserPrintMarkup(document);
          expect(pdf.plainText, document.fullPlainText, reason: fixtureId);
          expect(markup, startsWith('<article class="knowme-print-report">'));
          final header = markup.indexOf('<header>');
          final title = markup.indexOf('<h1>');
          final subtitle = markup.indexOf('<p class="subtitle">');
          final firstSection = markup.indexOf(
            'data-section-id="${document.sections.first.id}"',
          );
          expect(
            header,
            greaterThan(0),
            reason: '$fixtureId header must follow the article wrapper',
          );
          expect(title, greaterThanOrEqualTo(header), reason: fixtureId);
          expect(subtitle, greaterThan(title), reason: fixtureId);
          expect(firstSection, greaterThan(subtitle), reason: fixtureId);
          expect(document.sections.first.title, isNotEmpty, reason: fixtureId);
          expect(
            document.sections.first.paragraphs.first,
            isNotEmpty,
            reason: fixtureId,
          );
          var cursor = firstSection - 1;
          for (final section in document.sections) {
            final next = markup.indexOf('data-section-id="${section.id}"');
            expect(
              next,
              greaterThan(cursor),
              reason: '$fixtureId/${section.id}',
            );
            cursor = next;
            expect(
              markup,
              contains(const HtmlEscape().convert(section.title)),
              reason: '$fixtureId/${section.id}',
            );
            for (final paragraph in section.paragraphs) {
              expect(
                markup,
                contains(const HtmlEscape().convert(paragraph)),
                reason: '$fixtureId/${section.id}',
              );
            }
          }
        }
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test('candidate is opt-in and leaves the accepted factory unchanged', () {
      final analysis = _analysis(knownTime: true);
      final before = ThaiBetaReportExportDocument.beforeReaderCopy(analysis);
      final after = ThaiBetaReportExportDocument.candidate(analysis);
      expect(
        before.sections.any(
          (section) => section.kind == ThaiBetaReportExportSectionKind.chapter,
        ),
        isFalse,
      );
      expect(before.fullPlainText, contains('แปลเป็นภาษาคน'));
      expect(
        after.sections.where(
          (section) => section.kind == ThaiBetaReportExportSectionKind.chapter,
        ),
        hasLength(4),
      );
      expect(after.fullPlainText, isNot(contains('แปลเป็นภาษาคน')));
      expect(after.fullPlainText, isNot(contains('จุดกระตุ้น')));
      expect(after.fullPlainText, isNot(contains('ธาตุขัดกัน')));
    });

    test('four reader chapters appear once and in a stable order', () {
      for (final knownTime in [true, false]) {
        final document = ThaiBetaReportExportDocument.candidate(
          _analysis(knownTime: knownTime),
        );
        const titles = [
          'ส่วนที่ 1 · พื้นดวงของคุณ',
          'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
          'ส่วนที่ 3 · แนวโน้มข้างหน้า',
          'ส่วนที่ 4 · ที่มาและข้อจำกัด',
        ];
        final chapterSections = document.sections
            .where(
              (section) =>
                  section.kind == ThaiBetaReportExportSectionKind.chapter,
            )
            .toList(growable: false);
        expect(chapterSections.map((section) => section.title), titles);
        var previous = -1;
        for (final title in titles) {
          final index = document.sections.indexWhere(
            (section) => section.title == title,
          );
          expect(index, greaterThan(previous));
          previous = index;
        }
        final markup = browserPrintMarkup(document);
        expect(
          'class="report-section chapter"'.allMatches(markup),
          hasLength(4),
        );
      }
    });

    test('Known and Unknown place the image after its 12-month narrative', () {
      for (final knownTime in [true, false]) {
        final document = ThaiBetaReportExportDocument.candidate(
          _analysis(knownTime: knownTime),
        );
        final insertion = document.infographicInsertionSectionIndex;
        expect(document.sections[insertion].title, 'แนวโน้ม 12 เดือนข้างหน้า');
        final markup = browserPrintMarkup(
          document,
          infographicPng: Uint8List.fromList([1, 2, 3]),
        );
        final before = markup.indexOf(
          'data-section-id="${document.sections[insertion].id}"',
        );
        final image = markup.indexOf('class="infographic-page"');
        final after = markup.indexOf(
          'data-section-id="${document.sections[insertion + 1].id}"',
        );
        expect(before, lessThan(image));
        expect(image, lessThan(after));
      }
    });
  });

  group('rolling 12-month infographic evidence contract', () {
    test(
      'period is exact, rolling, and never presented as a calendar year',
      () {
        final year2569 = ThaiBetaReportExportDocument.candidate(
          _analysis(knownTime: true, year: 2026),
        ).infographic!;
        final year2570 = ThaiBetaReportExportDocument.candidate(
          _analysis(knownTime: true, year: 2027),
        ).infographic!;
        expect(year2569.buddhistYear, 2569);
        expect(year2570.buddhistYear, 2570);
        expect(year2569.title, 'แนวโน้ม 12 เดือนข้างหน้า');
        expect(year2569.periodLabel, '7 ส.ค. 2569 – 6 ส.ค. 2570');
        expect(year2570.periodLabel, '7 ส.ค. 2570 – 6 ส.ค. 2571');
        expect(year2569.overview, startsWith(year2569.periodLabel));
        expect(year2569.title, isNot(contains('ปี 2569')));
      },
    );

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
          for (final knownTime in [true, false]) {
            final key = GlobalKey();
            final document = ThaiBetaReportExportDocument.candidate(
              _analysis(knownTime: knownTime),
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
            if (!knownTime) {
              expect(find.text('คำทำนายอดีต'), findsOneWidget);
              expect(find.text('คำทำนายปัจจุบัน — อายุ 44 ปี'), findsOneWidget);
              expect(find.text('ช่วงชีวิตถัดไป'), findsOneWidget);
              expect(find.text('อดีตของคุณ'), findsNothing);
              expect(find.text('ช่วงปัจจุบัน'), findsNothing);
              expect(find.text('จังหวะชีวิตระยะต่อไป'), findsNothing);
              expect(find.text('เรื่องสำคัญของช่วงนี้'), findsNothing);
            }
            expect(
              find.byKey(const Key('thai_annual_infographic_save')),
              findsOneWidget,
            );
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(key),
            );
            expect(boundary.size, ThaiBetaAnnualInfographicCapture.logicalSize);
            _expectAllInfographicSectionsInsideCanvas(
              tester,
              document.infographic!,
            );
            final firstPng = await tester.runAsync(
              () => ThaiBetaAnnualInfographicCapture.png(key),
            );
            final secondPng = await tester.runAsync(
              () => ThaiBetaAnnualInfographicCapture.png(key),
            );
            expect(firstPng, isNotNull);
            expect(secondPng, firstPng);
            final surfaceOutput =
                Platform.environment['KNOWME_INFOGRAPHIC_SURFACE_OUTPUT'];
            if (surfaceOutput != null && surfaceOutput.isNotEmpty) {
              final directory = Directory(surfaceOutput)
                ..createSync(recursive: true);
              File(
                '${directory.path}${Platform.pathSeparator}'
                'annual-infographic-surface-${width.toInt()}-'
                '${knownTime ? 'known' : 'unknown'}.png',
              ).writeAsBytesSync(firstPng!, flush: true);
            }
            expect(ThaiBetaAnnualInfographicCapture.pixelRatio, 3);
            expect(ThaiBetaAnnualInfographicCapture.targetWidth, 1080);
            expect(ThaiBetaAnnualInfographicCapture.targetHeight, 1920);
            final repeated = ThaiBetaReportExportDocument.candidate(
              _analysis(knownTime: knownTime),
            ).infographic!;
            expect(
              jsonEncode(_identity(document.infographic!)),
              jsonEncode(_identity(repeated)),
            );
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
          }
        },
      );

      testWidgets('regression 1972 fits mobile $width without overflow', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final document = ThaiBetaReportExportDocument.candidate(
          _regression1972(),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ThaiBetaAnnualInfographicPanel(
                  data: document.infographic!,
                  boundaryKey: GlobalKey(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        _expectAllInfographicSectionsInsideCanvas(
          tester,
          document.infographic!,
        );
      });
    }
  });
}

void _expectAllInfographicSectionsInsideCanvas(
  WidgetTester tester,
  ThaiBetaAnnualInfographicData data,
) {
  final canvas = tester.getRect(
    find.byKey(const Key('thai_annual_infographic_canvas')),
  );
  final finders = <Finder>[
    find.byKey(ThaiBetaAnnualInfographicLayoutKeys.title),
    find.byKey(ThaiBetaAnnualInfographicLayoutKeys.theme),
    find.byKey(ThaiBetaAnnualInfographicLayoutKeys.overview),
    for (final category in data.categories)
      find.byKey(ThaiBetaAnnualInfographicLayoutKeys.category(category.id)),
    find.byKey(ThaiBetaAnnualInfographicLayoutKeys.opportunity),
    find.byKey(ThaiBetaAnnualInfographicLayoutKeys.caution),
    find.byKey(ThaiBetaAnnualInfographicLayoutKeys.advice),
    find.byKey(ThaiBetaAnnualInfographicLayoutKeys.disclaimer),
  ];
  for (final finder in finders) {
    expect(finder, findsOneWidget);
    final rect = tester.getRect(finder);
    expect(rect.left, greaterThanOrEqualTo(canvas.left));
    expect(rect.top, greaterThanOrEqualTo(canvas.top));
    expect(rect.right, lessThanOrEqualTo(canvas.right));
    expect(rect.bottom, lessThanOrEqualTo(canvas.bottom));
  }
  final ornament = tester.getRect(
    find.byKey(ThaiBetaAnnualInfographicLayoutKeys.ornament),
  );
  expect(ornament.overlaps(canvas), isTrue);
}

Map<String, Object?> _identity(ThaiBetaAnnualInfographicData data) => {
  'year': data.buddhistYear,
  'periodLabel': data.periodLabel,
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
