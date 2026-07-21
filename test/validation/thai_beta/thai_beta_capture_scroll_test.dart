import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/web/screenshot_friendly_scroll.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_current_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_qa_sample_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_mode.dart';

/// Regression: `/beta/thai/capture` and `/beta/thai/capture-qa` must scroll
/// end-to-end for reading. PDF section title "ข้อจำกัด" maps to on-page
/// footer disclaimers under [Key('thai_consumer_footer')].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiBetaAnalysis analysis;

  /// Stable on-page bottom disclaimer (PDF export groups these under "ข้อจำกัด").
  const bottomDisclaimer =
      'ผลลัพธ์นี้เป็นมุมมองเพื่อทำความเข้าใจตัวเอง ไม่ใช่คำทำนาย';

  setUpAll(() {
    analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Test',
        lastName: 'User',
        birthDate: DateTime(1972, 4, 4),
        birthHour: 10,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
    );
  });

  tearDown(() {
    ThaiBetaScreenshotMode.resetForTest();
    ThaiBetaCurrentAnalysis.clear();
  });

  Future<void> pumpCaptureReport(
    WidgetTester tester, {
    required Widget home,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: home));
    await tester.pumpAndSettle();
  }

  Finder captureScrollableFinder() {
    return find
        .descendant(
          of: find.byKey(const Key('thai_beta_report_screenshot_layout')),
          matching: find.byType(Scrollable),
        )
        .first;
  }

  ScrollableState captureScrollState(WidgetTester tester) {
    return tester.state<ScrollableState>(captureScrollableFinder());
  }

  testWidgets('capture page is vertically scrollable', (tester) async {
    ThaiBetaCurrentAnalysis.set(analysis);
    await pumpCaptureReport(tester, home: const ThaiBetaCapturePage());

    final scroll = captureScrollState(tester);
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    expect(
      tester.widget<SingleChildScrollView>(
        find.byKey(const Key('thai_beta_report_screenshot_layout')),
      ).physics,
      isNot(isA<NeverScrollableScrollPhysics>()),
    );
  });

  testWidgets('drag upward reveals content near the bottom', (tester) async {
    ThaiBetaCurrentAnalysis.set(analysis);
    await pumpCaptureReport(tester, home: const ThaiBetaCapturePage());

    final scrollable = captureScrollableFinder();
    final scroll = tester.state<ScrollableState>(scrollable);
    expect(scroll.position.maxScrollExtent, greaterThan(500));

    // Disclaimer is below the first viewport before scrolling.
    expect(find.text(bottomDisclaimer).hitTestable(), findsNothing);

    await tester.drag(scrollable, const Offset(0, -4000));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(0));

    await tester.drag(scrollable, Offset(0, -(scroll.position.maxScrollExtent)));
    await tester.pumpAndSettle();

    expect(
      scroll.position.pixels,
      closeTo(scroll.position.maxScrollExtent, 1),
    );
    expect(find.text(bottomDisclaimer).hitTestable(), findsOneWidget);
  });

  testWidgets('bottom disclaimer can be reached', (tester) async {
    ThaiBetaCurrentAnalysis.set(analysis);
    await pumpCaptureReport(tester, home: const ThaiBetaCapturePage());

    await tester.scrollUntilVisible(
      find.text(bottomDisclaimer),
      400,
      scrollable: captureScrollableFinder(),
    );
    await tester.pumpAndSettle();

    expect(find.text(bottomDisclaimer).hitTestable(), findsOneWidget);
  });

  testWidgets('download button remains tappable', (tester) async {
    ThaiBetaCurrentAnalysis.set(analysis);
    await pumpCaptureReport(tester, home: const ThaiBetaCapturePage());

    final download = find.text('ดาวน์โหลดรายงานเต็ม');
    expect(download, findsOneWidget);
    expect(download.hitTestable(), findsOneWidget);
    expect(find.textContaining('เปิดหน้าพิมพ์'), findsOneWidget);
    expect(find.textContaining('เปิดหน้าพิมพ์').hitTestable(), findsOneWidget);
  });

  testWidgets('QA capture page is vertically scrollable', (tester) async {
    await pumpCaptureReport(
      tester,
      home: const ThaiBetaQaSampleCapturePage(),
    );

    final scroll = captureScrollState(tester);
    expect(scroll.position.maxScrollExtent, greaterThan(0));

    await tester.scrollUntilVisible(
      find.text(bottomDisclaimer),
      400,
      scrollable: captureScrollableFinder(),
    );
    expect(find.text(bottomDisclaimer).hitTestable(), findsOneWidget);
  });

  testWidgets('leaving capture page does not leave browser scroll locked', (
    tester,
  ) async {
    ThaiBetaCurrentAnalysis.set(analysis);
    await pumpCaptureReport(tester, home: const ThaiBetaCapturePage());
    expect(
      find.byKey(const Key('thai_beta_report_screenshot_layout')),
      findsOneWidget,
    );

    // Navigate away — dispose must clear screenshot host styles (web).
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            key: const Key('post_capture_scroll'),
            children: List.generate(
              40,
              (i) => SizedBox(height: 80, child: Text('row-$i')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Stub/web APIs: applied host height must be cleared after dispose.
    expect(readAppliedHostHeightPx(), 0);

    final postScroll = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('post_capture_scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(postScroll.position.maxScrollExtent, greaterThan(0));
    await tester.drag(
      find.byKey(const Key('post_capture_scroll')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(postScroll.position.pixels, greaterThan(0));
  });

  testWidgets('normal Thai Beta report behavior unchanged', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: analysis,
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
          screenshotModeOverride: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thai_beta_report_page_scroll')), findsOneWidget);
    expect(
      find.byKey(const Key('thai_beta_report_screenshot_layout')),
      findsNothing,
    );
    expect(find.text('ให้ความคิดเห็นต่อผลวิเคราะห์'), findsOneWidget);
    expect(find.text('ดาวน์โหลดรายงานเต็ม'), findsNothing);

    final scroll = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('thai_beta_report_page_scroll')),
        matching: find.byType(Scrollable),
      ).first,
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
  });
}
