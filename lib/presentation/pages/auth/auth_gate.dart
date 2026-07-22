import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import '../profile/profile_gate.dart';
import 'package:knowme/core/web/web_intended_route.dart';
import 'package:knowme/core/web/web_launch_router.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_routes.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_entry.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.authStateStream});

  /// Injectable for tests.
  final Stream<User?>? authStateStream;

  /// Public Beta landing must never paint Login — even if boot fell through
  /// to the authenticated shell (null first launch-route read on web).
  static bool get isPublicBetaLandingActive {
    return ThaiBetaRoutes.isAnonymousPublicLandingRoute(
      WebLaunchRouter.effectiveLaunchRoute(null),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPublicBetaLandingActive) {
      return const ThaiBetaLandingPage();
    }

    return StreamBuilder<User?>(
      stream: authStateStream ?? FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // login แล้ว
        if (snapshot.hasData) {
          final intended = WebIntendedRoute.peekThaiBetaScreenshot();
          if (intended != null) {
            return ThaiBetaScreenshotEntry(
              routeName: intended,
              authenticatedOverride: true,
            );
          }
          return const ProfileGate();
        }

        // ยังไม่ login — last-chance public-beta guard (live re-read).
        if (isPublicBetaLandingActive) {
          return const ThaiBetaLandingPage();
        }
        return const LoginPage();
      },
    );
  }
}
