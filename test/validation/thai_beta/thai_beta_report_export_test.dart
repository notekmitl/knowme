import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_polish.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_safety.dart';
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
      expect(text.contains('ช่วงก่อนหน้า: ช่วงก่อนหน้า'), isFalse);
      expect(text.contains('ช่วงถัดไป: ช่วงถัดไป'), isFalse);
      expect(RegExp(r'เหลืออีกประมาณ\s*0\s*ปี').hasMatch(text), isFalse);
      expect(RegExp(r'อีกประมาณ\s*0\s*ปี').hasMatch(text), isFalse);
      expect(RegExp(r'ในราว\s*0\s*ปี').hasMatch(text), isFalse);
      expect(RegExp(r'เหลืออีกประมาณ\s*0\s*เดือน').hasMatch(text), isFalse);
      expect(text.contains('ผ่านรู้สึก…'), isFalse);
      expect(text.contains('ผ่านคิดละเอ…'), isFalse);
      expect(text.contains('ดี(ผ่าน'), isFalse);
    });

    test('export prefers full insight bodies over UI ellipsis truncations', () {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final text = doc.fullPlainText;
      // No mid-card truncated ellipsis leftovers from UI maxChars cuts.
      expect(RegExp(r'[ก-๙A-Za-z]…').hasMatch(text), isFalse);
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
      expect(polished.contains('0 ปี'), isFalse);
      expect(polished.contains('กำลังอยู่ช่วงปลายของจังหวะนี้'), isTrue);
    });

    test('normalizeSpacing adds space before parentheses', () {
      expect(
        ThaiBetaReportExportPolish.normalizeSpacing('ดี(ผ่านช่วงนี้)'),
        'ดี (ผ่านช่วงนี้)',
      );
    });

    test('dedupeParagraphs drops title echo and truncated UI lines', () {
      final lines = ThaiBetaReportExportPolish.dedupeParagraphs(
        'การเติบโต',
        [
          'การเติบโต',
          'เนื้อหาเต็ม',
          'เนื้อหาเต็ม',
          'ผ่านรู้สึก…',
        ],
      );
      expect(lines, ['เนื้อหาเต็ม']);
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
