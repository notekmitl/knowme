import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:knowme/core/web/web_intended_route.dart';
import 'package:knowme/core/web/web_launch_route_uri.dart';
import 'package:knowme/presentation/pages/auth/login_page.dart';

import 'pages/thai_beta_capture_page.dart';
import 'pages/thai_beta_landing_page.dart';
import 'thai_beta_routes.dart';
import 'thai_beta_screenshot_mode.dart';

/// Auth-gated entry for Thai Beta screenshot / capture deep links.
///
/// Unauthenticated users see [LoginPage]; after login the intended capture or
/// screenshot beta route renders without falling through to Home.
class ThaiBetaScreenshotEntry extends StatelessWidget {
  const ThaiBetaScreenshotEntry({
    super.key,
    required this.routeName,
    this.authStateStream,
    this.authenticatedOverride,
  });

  final String routeName;

  /// Injectable for tests.
  final Stream<User?>? authStateStream;

  /// When set, skips Firebase and uses this auth state.
  final bool? authenticatedOverride;

  @visibleForTesting
  static void activateScreenshotSession(String routeName) {
    WebIntendedRoute.configure(routeName);
    ThaiBetaScreenshotMode.configureFromLaunchRoute(routeName);
  }

  @override
  Widget build(BuildContext context) {
    activateScreenshotSession(routeName);

    if (authenticatedOverride != null) {
      if (!authenticatedOverride!) {
        return const LoginPage();
      }
      return _buildDestination();
    }

    return StreamBuilder<User?>(
      stream: authStateStream ?? FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return const LoginPage();
        }
        activateScreenshotSession(routeName);
        return _buildDestination();
      },
    );
  }

  Widget _buildDestination() {
    final uri = routeUriFromName(routeName);
    final child = ThaiBetaRoutes.isCapturePath(uri.path)
        ? const ThaiBetaCapturePage()
        : const ThaiBetaLandingPage();

    return ThaiBetaScreenshotScope(
      active: ThaiBetaScreenshotMode.isActive,
      child: child,
    );
  }
}
