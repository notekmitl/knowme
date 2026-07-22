import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/web/web_intended_route.dart';
import 'package:knowme/core/web/web_launch_route_uri.dart';
import 'package:knowme/core/web/web_launch_router.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_routes.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_entry.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_mode.dart';
import 'package:knowme/main.dart';
import 'package:knowme/presentation/pages/auth/auth_gate.dart';
import 'package:knowme/presentation/pages/auth/login_page.dart';

/// Regression: `/beta/thai` is Public Beta — anonymous must reach
/// [ThaiBetaLandingPage] without Auth Login. Seeing Login on this route is FAIL.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    WebIntendedRoute.resetForTest();
    ThaiBetaScreenshotMode.resetForTest();
  });

  group('anonymous public /beta/thai', () {
    test('resolveLaunchWidget returns ThaiBetaLandingPage (not AuthGate)', () {
      final widget = WebLaunchRouter.resolveLaunchWidget('/beta/thai');
      expect(widget, isA<ThaiBetaLandingPage>());
      expect(widget, isNot(isA<AuthGate>()));
    });

    test('query string on public beta still resolves to landing', () {
      final widget =
          WebLaunchRouter.resolveLaunchWidget('/beta/thai?nocache=1');
      expect(widget, isA<ThaiBetaLandingPage>());
    });

    test('effectiveLaunchRoute preserves captured public beta path', () {
      expect(
        WebLaunchRouter.effectiveLaunchRoute('/beta/thai'),
        '/beta/thai',
      );
      WebIntendedRoute.configure('/beta/thai');
      expect(
        WebLaunchRouter.effectiveLaunchRoute(null),
        '/beta/thai',
      );
    });

    testWidgets('WebLaunchRouter with /beta/thai does not build LoginPage', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebLaunchRouter(launchRouteName: '/beta/thai'),
        ),
      );

      expect(find.byType(ThaiBetaLandingPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(AuthGate), findsNothing);
      expect(find.textContaining('Login'), findsNothing);
    });

    testWidgets('initialRoute /beta/thai resolves landing not Login', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/beta/thai',
          onGenerateInitialRoutes: (initialRoute) {
            final page =
                WebLaunchRouter.resolveLaunchWidget(initialRoute) ??
                    const AuthGate();
            return [
              MaterialPageRoute<void>(
                settings: RouteSettings(name: initialRoute),
                builder: (_) => page,
              ),
            ];
          },
          onGenerateRoute: (settings) {
            final page = WebLaunchRouter.resolveLaunchWidget(settings.name) ??
                const AuthGate();
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => page,
            );
          },
        ),
      );

      expect(find.byType(ThaiBetaLandingPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    test('isAnonymousPublicLandingRoute accepts public beta only', () {
      expect(ThaiBetaRoutes.isAnonymousPublicLandingRoute('/beta/thai'), isTrue);
      expect(
        ThaiBetaRoutes.isAnonymousPublicLandingRoute('/beta/thai?nocache=1'),
        isTrue,
      );
      expect(
        ThaiBetaRoutes.isAnonymousPublicLandingRoute('/beta/thai/capture'),
        isFalse,
      );
      expect(
        ThaiBetaRoutes.isAnonymousPublicLandingRoute('/beta/thai?screenshot=1'),
        isFalse,
      );
      expect(ThaiBetaRoutes.isAnonymousPublicLandingRoute('/'), isFalse);
      expect(ThaiBetaRoutes.isAnonymousPublicLandingRoute(null), isFalse);
    });

    testWidgets('PublicThaiBetaApp shows landing without Login', (tester) async {
      await tester.pumpWidget(const PublicThaiBetaApp());

      expect(find.byType(ThaiBetaLandingPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(AuthGate), findsNothing);
    });

    testWidgets('AuthGate shows Landing for public /beta/thai (not Login)', (
      tester,
    ) async {
      WebIntendedRoute.configure('/beta/thai');

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateStream: Stream<User?>.value(null)),
        ),
      );
      await tester.pump();

      expect(find.byType(ThaiBetaLandingPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('AuthGate still shows Login for root when signed out', (
      tester,
    ) async {
      WebIntendedRoute.configure(null);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateStream: Stream<User?>.value(null)),
        ),
      );
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ThaiBetaLandingPage), findsNothing);
    });

    test('null/root launch does not resolve to public landing', () {
      expect(WebLaunchRouter.resolveLaunchWidget(null), isNull);
      expect(WebLaunchRouter.resolveLaunchWidget('/'), isNull);
    });

    test('routeNameFromPathAndQuery keeps /beta/thai (not rewritten to root)', () {
      expect(routeNameFromPathAndQuery('/beta/thai', ''), '/beta/thai');
      expect(routeNameFromPathAndQuery('/', ''), isNull);
    });
  });

  group('protected routes still require login', () {
    test('null launch route falls back to AuthGate (signed-out → Login)', () {
      expect(WebLaunchRouter.resolveLaunchWidget(null), isNull);
    });

    test('unknown route falls back to AuthGate', () {
      expect(WebLaunchRouter.resolveLaunchWidget('/home'), isNull);
      expect(WebLaunchRouter.resolveLaunchWidget('/profile'), isNull);
    });

    testWidgets('AuthGate without user shows LoginPage', (tester) async {
      WebIntendedRoute.configure(null);
      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateStream: Stream<User?>.value(null)),
        ),
      );
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('unauthenticated capture deep link still shows LoginPage', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThaiBetaScreenshotEntry(
            routeName: '/beta/thai/capture',
            authenticatedOverride: false,
          ),
        ),
      );

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ThaiBetaLandingPage), findsNothing);
    });

    test('capture path does not resolve to public landing', () {
      final widget =
          WebLaunchRouter.resolveLaunchWidget('/beta/thai/capture');
      expect(widget, isA<ThaiBetaScreenshotEntry>());
      expect(widget, isNot(isA<ThaiBetaLandingPage>()));
    });

    testWidgets(
      'AuthGate does not treat capture deep link as public landing',
      (tester) async {
        WebIntendedRoute.configure('/beta/thai/capture');

        await tester.pumpWidget(
          MaterialApp(
            home: AuthGate(authStateStream: Stream<User?>.value(null)),
          ),
        );
        await tester.pump();

        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.byType(ThaiBetaLandingPage), findsNothing);
      },
    );
  });
}
