import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/web/web_intended_route.dart';
import 'package:knowme/core/web/web_launch_route_uri.dart';
import 'package:knowme/core/web/web_launch_router.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_entry.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_mode.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_routes.dart';
import 'package:knowme/presentation/pages/auth/auth_gate.dart';
import 'package:knowme/presentation/pages/auth/login_page.dart';
import 'package:knowme/presentation/pages/home/home_page.dart';
import 'package:knowme/presentation/pages/profile/profile_gate.dart';

class _FakeUser extends Fake implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    WebIntendedRoute.resetForTest();
    ThaiBetaScreenshotMode.resetForTest();
  });

  group('routeNameFromPathAndQuery', () {
    test('returns path for deep link', () {
      expect(
        routeNameFromPathAndQuery('/beta/thai/capture', ''),
        '/beta/thai/capture',
      );
    });

    test('includes query string', () {
      expect(
        routeNameFromPathAndQuery('/beta/thai', '?screenshot=1'),
        '/beta/thai?screenshot=1',
      );
      expect(
        routeNameFromPathAndQuery('/beta/thai', 'screenshot=1'),
        '/beta/thai?screenshot=1',
      );
    });

    test('returns null for root path', () {
      expect(routeNameFromPathAndQuery('/', ''), isNull);
      expect(routeNameFromPathAndQuery('', ''), isNull);
    });
  });

  group('ThaiBetaScreenshotRoutes', () {
    test('capture path is deep link', () {
      expect(
        ThaiBetaScreenshotRoutes.isDeepLinkName('/beta/thai/capture'),
        isTrue,
      );
    });

    test('screenshot query is deep link', () {
      expect(
        ThaiBetaScreenshotRoutes.isDeepLinkName('/beta/thai?screenshot=1'),
        isTrue,
      );
      expect(
        ThaiBetaScreenshotRoutes.isDeepLinkName('/beta/thai?capture=1'),
        isTrue,
      );
    });

    test('plain beta route is not deep link', () {
      expect(ThaiBetaScreenshotRoutes.isDeepLinkName('/beta/thai'), isFalse);
    });
  });

  group('WebIntendedRoute preservation', () {
    test('unauthenticated /beta/thai/capture stores intended route', () {
      WebIntendedRoute.configure('/beta/thai/capture');
      expect(WebIntendedRoute.stored, '/beta/thai/capture');
      expect(WebIntendedRoute.peekThaiBetaScreenshot(), '/beta/thai/capture');
    });

    test('unauthenticated /beta/thai?screenshot=1 stores query param', () {
      WebIntendedRoute.configure('/beta/thai?screenshot=1');
      expect(WebIntendedRoute.peekThaiBetaScreenshot(), '/beta/thai?screenshot=1');
      expect(
        routeUriFromName(WebIntendedRoute.peekThaiBetaScreenshot()!)
            .queryParameters['screenshot'],
        '1',
      );
    });

    test('peek does not clear stored route', () {
      WebIntendedRoute.configure('/beta/thai/capture');
      expect(WebIntendedRoute.peekThaiBetaScreenshot(), isNotNull);
      expect(WebIntendedRoute.stored, '/beta/thai/capture');
    });
  });

  group('WebLaunchRouter.resolveLaunchWidget', () {
    test('/beta/thai/capture resolves to ThaiBetaScreenshotEntry', () {
      final widget = WebLaunchRouter.resolveLaunchWidget('/beta/thai/capture');
      expect(widget, isA<ThaiBetaScreenshotEntry>());
    });

    test('/beta/thai?screenshot=1 resolves to ThaiBetaScreenshotEntry', () {
      final widget =
          WebLaunchRouter.resolveLaunchWidget('/beta/thai?screenshot=1');
      expect(widget, isA<ThaiBetaScreenshotEntry>());
    });

    test('/beta/thai resolves to ThaiBetaLandingPage', () {
      final widget = WebLaunchRouter.resolveLaunchWidget('/beta/thai');
      expect(widget, isA<ThaiBetaLandingPage>());
    });

    test('unknown route returns null (falls back to AuthGate)', () {
      expect(WebLaunchRouter.resolveLaunchWidget('/unknown'), isNull);
    });
  });

  group('ThaiBetaScreenshotEntry', () {
    testWidgets('unauthenticated shows LoginPage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThaiBetaScreenshotEntry(
            routeName: '/beta/thai/capture',
            authenticatedOverride: false,
          ),
        ),
      );

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ThaiBetaCapturePage), findsNothing);
      expect(WebIntendedRoute.stored, '/beta/thai/capture');
    });

    testWidgets('authenticated /beta/thai/capture resolves to capture page', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThaiBetaScreenshotEntry(
            routeName: '/beta/thai/capture',
            authenticatedOverride: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ThaiBetaCapturePage), findsOneWidget);
      expect(find.text('ยังไม่มีรายงานสำหรับส่งออก'), findsOneWidget);
      expect(find.text('Thai Beta Capture Mode Active'), findsNothing);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(HomePage), findsNothing);
      expect(ThaiBetaScreenshotMode.isActive, isTrue);
    });

    testWidgets('authenticated /beta/thai?screenshot=1 enables screenshot mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThaiBetaScreenshotEntry(
            routeName: '/beta/thai?screenshot=1',
            authenticatedOverride: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ThaiBetaLandingPage), findsOneWidget);
      expect(ThaiBetaScreenshotMode.isActive, isTrue);
      expect(
        ThaiBetaScreenshotMode.diagnosticUri.queryParameters['screenshot'],
        '1',
      );
    });

    testWidgets('screenshot mode survives login transition', (tester) async {
      final authController = StreamController<User?>();

      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaScreenshotEntry(
            routeName: '/beta/thai?screenshot=1',
            authStateStream: authController.stream,
          ),
        ),
      );

      await tester.pump();
      authController.add(null);
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(ThaiBetaScreenshotMode.isActive, isTrue);

      authController.add(_FakeUser());
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(ThaiBetaLandingPage), findsOneWidget);
      expect(ThaiBetaScreenshotMode.isActive, isTrue);
      expect(
        ThaiBetaScreenshotMode.diagnosticUri.queryParameters['screenshot'],
        '1',
      );

      await authController.close();
    });
  });

  group('AuthGate post-login redirect', () {
    testWidgets('after login redirects to /beta/thai/capture', (tester) async {
      final authController = StreamController<User?>();
      WebIntendedRoute.configure('/beta/thai/capture');

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateStream: authController.stream),
        ),
      );

      await tester.pump();
      authController.add(null);
      await tester.pump();
      expect(find.byType(LoginPage), findsOneWidget);

      authController.add(_FakeUser());
      await tester.pumpAndSettle();

      expect(find.byType(ThaiBetaCapturePage), findsOneWidget);
      expect(find.text('ยังไม่มีรายงานสำหรับส่งออก'), findsOneWidget);
      expect(find.text('Thai Beta Capture Mode Active'), findsNothing);
      expect(find.byType(ProfileGate), findsNothing);
      expect(find.byType(HomePage), findsNothing);
      expect(WebIntendedRoute.peekThaiBetaScreenshot(), '/beta/thai/capture');

      await authController.close();
    });

    testWidgets('after login redirects to /beta/thai?screenshot=1 with query', (
      tester,
    ) async {
      final authController = StreamController<User?>();
      WebIntendedRoute.configure('/beta/thai?screenshot=1');

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateStream: authController.stream),
        ),
      );

      authController.add(_FakeUser());
      await tester.pumpAndSettle();

      expect(find.byType(ThaiBetaLandingPage), findsOneWidget);
      expect(ThaiBetaScreenshotMode.isActive, isTrue);
      expect(
        ThaiBetaScreenshotMode.diagnosticUri.queryParameters['screenshot'],
        '1',
      );

      await authController.close();
    });

    test('normal login without intended beta route does not peek screenshot', () {
      WebIntendedRoute.configure('/today');
      expect(WebIntendedRoute.peekThaiBetaScreenshot(), isNull);
    });
  });

  group('WebLaunchRouter effectiveLaunchRoute', () {
    test('stored intended route resolves to screenshot entry', () {
      WebIntendedRoute.configure('/beta/thai/capture');
      final route = WebLaunchRouter.effectiveLaunchRoute(null);
      expect(route, '/beta/thai/capture');
      expect(
        WebLaunchRouter.resolveLaunchWidget(route),
        isA<ThaiBetaScreenshotEntry>(),
      );
    });
  });
}
