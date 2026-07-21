import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_routes.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_mode.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(ThaiBetaScreenshotMode.resetForTest);

  group('ThaiBetaRoutes', () {
    test('isCapturePath matches capture route', () {
      expect(ThaiBetaRoutes.isCapturePath('/beta/thai/capture'), isTrue);
      expect(ThaiBetaRoutes.isCapturePath('/beta/thai/capture/'), isTrue);
      expect(ThaiBetaRoutes.isCapturePath('/beta/thai'), isFalse);
    });

    test('onGenerateRoute resolves capture before beta landing', () {
      final capture = ThaiBetaRoutes.onGenerateRoute(
        const RouteSettings(name: '/beta/thai/capture'),
      );
      expect(capture, isNotNull);

      final beta = ThaiBetaRoutes.onGenerateRoute(
        const RouteSettings(name: '/beta/thai'),
      );
      expect(beta, isNotNull);
    });

    testWidgets('capture route builds ThaiBetaCapturePage empty state without session',
        (tester) async {
      final route = ThaiBetaRoutes.onGenerateRoute(
        const RouteSettings(name: '/beta/thai/capture'),
      )!;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ThaiBetaScreenshotScope(
            active: true,
            child: child ?? const SizedBox.shrink(),
          ),
          onGenerateRoute: (_) => route,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ThaiBetaCapturePage), findsOneWidget);
      expect(find.text('ยังไม่มีรายงานสำหรับส่งออก'), findsOneWidget);
      expect(find.text('Thai Beta Capture Mode Active'), findsNothing);
      expect(find.byType(ThaiBetaLandingPage), findsNothing);
    });
  });

  group('ThaiBetaScreenshotMode.configureFromLaunchRoute', () {
    test('?screenshot=1 enables screenshot mode', () {
      ThaiBetaScreenshotMode.configureFromLaunchRoute('/beta/thai?screenshot=1');
      expect(ThaiBetaScreenshotMode.isActive, isTrue);
      expect(ThaiBetaScreenshotMode.diagnosticUri.queryParameters['screenshot'], '1');
    });

    test('?capture=1 enables screenshot mode', () {
      ThaiBetaScreenshotMode.configureFromLaunchRoute('/beta/thai?capture=1');
      expect(ThaiBetaScreenshotMode.isActive, isTrue);
      expect(ThaiBetaScreenshotMode.diagnosticUri.queryParameters['capture'], '1');
    });

    test('/beta/thai/capture enables screenshot mode', () {
      ThaiBetaScreenshotMode.configureFromLaunchRoute('/beta/thai/capture');
      expect(ThaiBetaScreenshotMode.isActive, isTrue);
      expect(ThaiBetaScreenshotMode.diagnosticUri.path, '/beta/thai/capture');
    });

    test('plain /beta/thai does not enable screenshot mode', () {
      ThaiBetaScreenshotMode.configureFromLaunchRoute('/beta/thai');
      expect(ThaiBetaScreenshotMode.isActive, isFalse);
    });
  });

  group('ThaiBetaScreenshotScope', () {
    testWidgets('propagates active flag to descendants', (tester) async {
      ThaiBetaScreenshotMode.configureFromLaunchRoute('/beta/thai?screenshot=1');

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ThaiBetaScreenshotScope(
            active: ThaiBetaScreenshotMode.isActive,
            child: child ?? const SizedBox.shrink(),
          ),
          home: Builder(
            builder: (context) {
              return Text(
                ThaiBetaScreenshotScope.of(context) ? 'active' : 'inactive',
              );
            },
          ),
        ),
      );

      expect(find.text('active'), findsOneWidget);
    });
  });
}
