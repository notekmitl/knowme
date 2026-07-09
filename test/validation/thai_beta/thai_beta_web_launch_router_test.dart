import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/web/web_launch_router.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/presentation/pages/auth/auth_gate.dart';

void main() {
  group('WebLaunchRouter.resolveLaunchWidget', () {
    test('/beta/thai/capture resolves to ThaiBetaCapturePage', () {
      final widget = WebLaunchRouter.resolveLaunchWidget('/beta/thai/capture');
      expect(widget, isA<ThaiBetaCapturePage>());
    });

    test('/beta/thai resolves to ThaiBetaLandingPage', () {
      final widget = WebLaunchRouter.resolveLaunchWidget('/beta/thai');
      expect(widget, isA<ThaiBetaLandingPage>());
    });

    test('unknown route returns null (falls back to AuthGate)', () {
      expect(WebLaunchRouter.resolveLaunchWidget('/unknown'), isNull);
    });
  });

  group('WebLaunchRouter widget', () {
    testWidgets('/beta/thai/capture shows capture banner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebLaunchRouter(launchRouteName: '/beta/thai/capture'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ThaiBetaCapturePage), findsOneWidget);
      expect(find.text('Thai Beta Capture Mode Active'), findsOneWidget);
      expect(find.byType(AuthGate), findsNothing);
    });
  });
}
