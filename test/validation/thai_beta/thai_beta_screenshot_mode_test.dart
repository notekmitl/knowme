import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_mode.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiBetaAnalysis analysis;

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
    ThaiBetaScreenshotMode.testOverride = null;
  });

  group('ThaiBetaScreenshotMode', () {
    test('test override enables screenshot mode', () {
      ThaiBetaScreenshotMode.testOverride = true;
      expect(ThaiBetaScreenshotMode.isActive, isTrue);
      ThaiBetaScreenshotMode.testOverride = false;
      expect(ThaiBetaScreenshotMode.isActive, isFalse);
    });

    test('detects capture path', () {
      final uri = Uri.parse('https://local/beta/thai/capture');
      expect(uri.path.endsWith('/capture'), isTrue);
    });
  });

  group('ThaiBetaReportPage screenshot mode layout', () {
    Future<void> pumpReport(
      WidgetTester tester, {
      required bool screenshotMode,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            screenshotModeOverride: screenshotMode,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('screenshot mode uses non-scrollable expand layout', (
      tester,
    ) async {
      await pumpReport(tester, screenshotMode: true);
      expect(find.byKey(const Key('thai_beta_report_page_scroll')), findsNothing);
      expect(find.byKey(const Key('thai_beta_report_screenshot_layout')), findsOneWidget);
      expect(find.byKey(const Key('thaiBetaReportCaptureContentKey')), findsOneWidget);
      final layout = tester.widget<SingleChildScrollView>(
        find.byKey(const Key('thai_beta_report_screenshot_layout')),
      );
      expect(layout.physics, isA<NeverScrollableScrollPhysics>());
      expect(layout.primary, isFalse);
    });

    testWidgets('screenshot mode has no fixed bottom navigation bar', (
      tester,
    ) async {
      await pumpReport(tester, screenshotMode: true);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
    });

    testWidgets('screenshot mode hides progress bar', (tester) async {
      await pumpReport(tester, screenshotMode: true);
      expect(find.text('อ่านผล'), findsNothing);
    });

    testWidgets('normal mode keeps parent scroll and bottom bar', (tester) async {
      await pumpReport(tester, screenshotMode: false);
      expect(find.byKey(const Key('thai_beta_report_page_scroll')), findsOneWidget);
      expect(find.text('ให้ความคิดเห็นต่อผลวิเคราะห์'), findsOneWidget);
    });

    testWidgets('embedded mirror has no inner vertical scroll in screenshot mode', (
      tester,
    ) async {
      await pumpReport(tester, screenshotMode: true);
      final verticalInnerScrolls = find.descendant(
        of: find.byType(ThaiMirrorResultPage),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.vertical,
        ),
      );
      expect(verticalInnerScrolls, findsNothing);
    });
  });
}
