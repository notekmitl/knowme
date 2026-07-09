import 'package:flutter/material.dart';

import 'admin/thai_research_admin_guard.dart';
import 'pages/thai_beta_capture_page.dart';
import 'pages/thai_beta_landing_page.dart';

/// Routes for the standalone Thai Astrology Beta.
abstract final class ThaiBetaRoutes {
  static const String betaRouteName = '/beta/thai';
  static const String betaCaptureRouteName = '/beta/thai/capture';
  static const String adminRouteName = '/internal/thai-beta';

  static Uri _routeUri(String name) {
    final normalized = name.startsWith('/') ? name : '/$name';
    return Uri.parse('https://local$normalized');
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final path = _routeUri(settings.name ?? '/').path;

    if (path == betaRouteName || path == '$betaRouteName/') {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: betaRouteName),
        builder: (_) => const ThaiBetaLandingPage(),
      );
    }

    if (path == betaCaptureRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: betaCaptureRouteName),
        builder: (_) => const ThaiBetaCapturePage(),
      );
    }

    if (path == adminRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: adminRouteName),
        builder: (_) => const ThaiResearchAdminGuard(),
      );
    }

    return null;
  }
}
