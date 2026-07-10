import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_polish.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_safety.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_export_print_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_mode.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_report_export_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiBetaAnalysis analysis;

  setUpAll(() {
    analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Export',
        lastName: 'Test',
        birthDate: DateTime(1972, 4, 4),
        birthHour: 10,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
    );
  });

  tearDown(ThaiBetaScreenshotMode.resetForTest);

  group('ThaiBetaReportExportSafety', () {
    test('detects forbidden tokens', () {
      expect(ThaiBetaReportExportSafety.containsForbidden('ดวงขึ้น'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('ดวงตก'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('Taksa'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('ทักษา'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('Khumsap'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('คุ้มทรัพย์'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('remedy'), isTrue);
      expect(ThaiBetaReportExportSafety.containsForbidden('ontology:foo'), isTrue);
      expect(
        ThaiBetaReportExportSafety.containsForbidden('unit.remedy.1'),
        isTrue,
      );
      expect(
        ThaiBetaReportExportSafety.containsForbidden('คุณมีบุคลิกที่น่าสนใจ'),
        isFalse,
      );
    });

    test('scrub removes forbidden fragments', () {
      final scrubbed = ThaiBetaReportExportSafety.scrub(
        'ข้อความปกติ. มีดวงขึ้นปน. อีกประโยค',
      );
      expect(scrubbed.contains('ดวงขึ้น'), isFalse);
      expect(scrubbed.contains('ข้อความปกติ'), isTrue);
    });
  });

  group('ThaiBetaReportExportDocument', () {
    test('builds from existing analysis view state', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      expect(doc.sections, isNotEmpty);
      expect(doc.title, contains('KnowMe'));
      final text = doc.fullPlainText;
      expect(text, isNotEmpty);
      // Uses existing consumer copy — hero headline from presenter.
      expect(
        text.contains(analysis.consumerViewState!.hero.headline),
        isTrue,
      );
    });

    test('export text has no forbidden content', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final text = doc.fullPlainText;
      expect(ThaiBetaReportExportSafety.containsForbidden(text), isFalse);
      expect(text.contains('ดวงขึ้น'), isFalse);
      expect(text.contains('ดวงตก'), isFalse);
      expect(text.toLowerCase().contains('taksa'), isFalse);
      expect(text.toLowerCase().contains('khumsap'), isFalse);
      expect(text.toLowerCase().contains('remedy'), isFalse);
      expect(text.toLowerCase().contains('ontology'), isFalse);
      expect(RegExp(r'\bunit\.[a-zA-Z0-9_.-]+').hasMatch(text), isFalse);
    });

    test('does not invent new prediction copy beyond view state', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final view = analysis.consumerViewState!;
      // Every section title/paragraph should come from scrubbed view fields —
      // at minimum hero + birth confidence must be present.
      expect(doc.fullPlainText, contains(view.hero.headline));
      expect(doc.fullPlainText, contains(view.birthDataConfidence.title));
    });

    test('PDF polish removes duplicate neighbour prefixes and zero timing', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final text = doc.fullPlainText;
      expect(ThaiBetaReportExportPolish.findForbidden(text), isEmpty);
    });

    test('export prefers full insight bodies over UI ellipsis truncations', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final text = doc.fullPlainText;
      // No mid-card truncated ellipsis leftovers from UI maxChars cuts.
      expect(RegExp(r'[ก-๙A-Za-z]…').hasMatch(text), isFalse);
    });
  });

  group('Real PDF exporter path regression', () {
    test('download-button path polishes polluted document before PDF text', () async {
      const polluted = ThaiBetaReportExportDocument(
        title: 'KnowMe — รายงานโหราไทย',
        subtitle: 'probe',
        filenameStem: 'knowme-thai-report',
        sections: [
          ThaiBetaReportExportSection(
            title: 'เส้นทางชีวิต',
            kind: ThaiBetaReportExportSectionKind.timeline,
            paragraphs: [
              'อิทธิพลดาวพฤหัสบดี • การเติบโต',
              'การเติบโต',
              'อิทธิพลดาวพุธ • การเรียนรู้',
              'การเรียนรู้',
              'อิทธิพลดาวเสาร์ • ความมั่นคง',
              'ความมั่นคง',
              'ช่วงก่อนหน้า: ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
              'ช่วงถัดไป: ช่วงถัดไป: ช่วงพลิกผัน (55–66)',
              'เหลืออีกประมาณ 0 ปีก่อนเปลี่ยนช่วง',
              'อีกประมาณ 0 เดือนจะเริ่มก้าวสู่จังหวะใหม่',
              'ดี(ผ่านรู้สึก…)',
              'ผ่านคิดละเอ…',
              'เนื้อหาที่ต้องเหลืออยู่',
            ],
          ),
        ],
      );

      // Same exporter entry used by ThaiBetaReportExportButton._exportPdf.
      final rendered = await ThaiBetaReportPdfExporter.build(polluted);
      expect(rendered.bytes, isNotEmpty);
      expect(rendered.plainText, contains('เนื้อหาที่ต้องเหลืออยู่'));
      expect(ThaiBetaReportExportPolish.findForbidden(rendered.plainText), isEmpty);
      expect(rendered.plainText.contains('ผ่านรู้สึก…'), isFalse);
      expect(rendered.plainText.contains('ผ่านคิดละเอ…'), isFalse);
      expect(rendered.plainText.contains('ดี(ผ่าน'), isFalse);
      expect(rendered.plainText.contains('• การเติบโต\nการเติบโต'), isFalse);
      expect(rendered.plainText.contains('ช่วงก่อนหน้า: ช่วงก่อนหน้า'), isFalse);
      expect(RegExp(r'(?<![0-9])0\s*ปี').hasMatch(rendered.plainText), isFalse);
    });

    test('real analysis download path PDF text has no forbidden regressions', () async {
      final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final rendered = await ThaiBetaReportPdfExporter.build(document);
      expect(rendered.bytes.length, greaterThan(1000));
      expect(ThaiBetaReportExportPolish.findForbidden(rendered.plainText), isEmpty);
      expect(ThaiBetaReportExportSafety.containsForbidden(rendered.plainText), isFalse);
    });
  });

  group('ThaiBetaReportExportPolish', () {
    test('neighbourLabel does not double prefix', () {
      expect(
        ThaiBetaReportExportPolish.neighbourLabel(
          'ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
          prefix: 'ช่วงก่อนหน้า: ',
        ),
        'ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
      );
      expect(
        ThaiBetaReportExportPolish.neighbourLabel(
          'ช่วงก่อนหน้า: ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
          prefix: 'ช่วงก่อนหน้า: ',
        ),
        'ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
      );
      expect(
        ThaiBetaReportExportPolish.neighbourLabel(
          'ช่วงวางรากฐาน (1–10)',
          prefix: 'ช่วงก่อนหน้า: ',
        ),
        'ช่วงก่อนหน้า: ช่วงวางรากฐาน (1–10)',
      );
    });

    test('polishTimingCopy rewrites zero remaining years', () {
      final polished = ThaiBetaReportExportPolish.polishTimingCopy(
        'ตอนนี้คุณอายุ 54 ปี กำลังอยู่ในช่วงเก็บเกี่ยว '
        'และจะอยู่ในจังหวะนี้ไปอีกประมาณ 0 ปี',
      );
      expect(RegExp(r'(?<![0-9])0\s*ปี').hasMatch(polished), isFalse);
      expect(polished.contains('กำลังอยู่ช่วงปลายของจังหวะนี้'), isTrue);
      // Must not destroy legitimate ages like 10/20/54.
      expect(
        ThaiBetaReportExportPolish.polishTimingCopy('อายุ 10 ปีในวัยเด็ก'),
        'อายุ 10 ปีในวัยเด็ก',
      );
    });

    test('normalizeSpacing adds space before parentheses', () {
      expect(
        ThaiBetaReportExportPolish.normalizeSpacing('ดี(ผ่านช่วงนี้)'),
        'ดี (ผ่านช่วงนี้)',
      );
    });

    test('dedupeParagraphs drops title echo, keyword echo, truncated UI lines', () {
      final lines = ThaiBetaReportExportPolish.dedupeParagraphs(
        'การเติบโต',
        [
          'การเติบโต',
          'อิทธิพลดาวพฤหัสบดี • การเติบโต',
          'การเติบโต',
          'คำสำคัญ: การเติบโต',
          'เนื้อหาเต็ม',
          'เนื้อหาเต็ม',
          'ผ่านรู้สึก…',
          'ดี(ผ่านคิดละเอ…)',
        ],
      );
      expect(lines, [
        'อิทธิพลดาวพฤหัสบดี • การเติบโต',
        'เนื้อหาเต็ม',
      ]);
    });
  });

  group('Export button visibility', () {
    Future<void> pumpReport(
      WidgetTester tester, {
      required bool screenshotMode,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ThaiBetaScreenshotScope(
            active: screenshotMode,
            child: child ?? const SizedBox.shrink(),
          ),
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            screenshotModeOverride: screenshotMode,
            showCaptureModeBanner: screenshotMode,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('export button appears only in screenshot/capture mode', (
      tester,
    ) async {
      await pumpReport(tester, screenshotMode: true);
      expect(find.byKey(const Key('thai_beta_report_export_bar')), findsOneWidget);
      expect(find.byKey(const Key('thai_beta_report_export_button')), findsOneWidget);
      expect(find.byKey(const Key('thai_beta_report_export_print_button')), findsOneWidget);
      expect(find.text('ดาวน์โหลดรายงานเต็ม'), findsOneWidget);
      expect(find.text('เปิดหน้าพิมพ์ / Save as PDF'), findsOneWidget);
    });

    testWidgets('export button visible on ThaiBetaCapturePage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ThaiBetaCapturePage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Thai Beta Capture Mode Active'), findsOneWidget);
      expect(find.byKey(const Key('thai_beta_report_export_button')), findsOneWidget);
      expect(find.text('ดาวน์โหลดรายงานเต็ม'), findsOneWidget);
    });

    testWidgets('export button not gated by evidence badge flag off', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            screenshotModeOverride: true,
            showCaptureModeBanner: true,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.off,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('thai_beta_report_export_button')), findsOneWidget);
    });

    testWidgets('export button hidden in normal beta report mode', (
      tester,
    ) async {
      await pumpReport(tester, screenshotMode: false);
      expect(find.byKey(const Key('thai_beta_report_export_button')), findsNothing);
      expect(find.byKey(const Key('thai_beta_report_export_bar')), findsNothing);
    });

    testWidgets('ThaiMirrorResultPage alone has no export button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiMirrorResultPage(
            consumerState: analysis.consumerViewState!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaReportExportButton), findsNothing);
      expect(find.byKey(const Key('thai_beta_report_export_button')), findsNothing);
    });
  });

  group('Print fallback page', () {
    testWidgets('renders export document without progress/feedback chrome', (
      tester,
    ) async {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      await tester.pumpWidget(
        MaterialApp(home: ThaiBetaExportPrintPage(document: doc)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('thai_beta_export_print_page')), findsOneWidget);
      expect(find.text('อ่านผล'), findsNothing);
      expect(find.text('ให้ความคิดเห็นต่อผลวิเคราะห์'), findsNothing);
      expect(find.textContaining('KnowMe'), findsWidgets);
    });
  });
}
