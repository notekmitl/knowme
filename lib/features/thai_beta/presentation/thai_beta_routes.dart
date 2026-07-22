import 'package:flutter/material.dart';

import 'admin/thai_research_admin_guard.dart';
import 'pages/thai_beta_capture_page.dart';
import 'pages/thai_beta_landing_page.dart';
import 'pages/thai_beta_qa_sample_capture_page.dart';

/// Routes for the standalone Thai Astrology Beta.
abstract final class ThaiBetaRoutes {
  static const String betaRouteName = '/beta/thai';
  static const String betaCaptureRouteName = '/beta/thai/capture';
  static const String betaQaSampleCaptureRouteName = '/beta/thai/capture-qa';
  static const String adminRouteName = '/internal/thai-beta';

  static String _normalizePath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  static bool isCapturePath(String path) {
    return _normalizePath(path) == betaCaptureRouteName;
  }

  static bool isQaSampleCapturePath(String path) {
    return _normalizePath(path) == betaQaSampleCaptureRouteName;
  }

  static bool isBetaPath(String path) {
    return _normalizePath(path) == betaRouteName;
  }

  /// True for anonymous Public Beta landing only (`/beta/thai`).
  /// Capture / screenshot deep links stay on the authenticated shell.
  static bool isAnonymousPublicLandingRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return false;
    final uri = _routeUri(routeName);
    if (isCapturePath(uri.path) || isQaSampleCapturePath(uri.path)) {
      return false;
    }
    if (!isBetaPath(uri.path)) return false;
    final query = uri.queryParameters;
    if (query['screenshot'] == '1' || query['capture'] == '1') {
      return false;
    }
    return true;
  }

  static Uri _routeUri(String name) {
    final normalized = name.startsWith('/') ? name : '/$name';
    return Uri.parse('https://local$normalized');
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final uri = _routeUri(settings.name ?? '/');
    final path = uri.path;

    // Capture route must be checked before the broader `/beta/thai` prefix.
    if (isCapturePath(path)) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: betaCaptureRouteName),
        builder: (_) => const ThaiBetaCapturePage(),
      );
    }

    if (isQaSampleCapturePath(path)) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: betaQaSampleCaptureRouteName),
        builder: (_) => const ThaiBetaQaSampleCapturePage(),
      );
    }

    if (isBetaPath(path)) {
      return MaterialPageRoute<void>(
        settings: RouteSettings(
          name: betaRouteName,
          arguments: uri.queryParameters,
        ),
        builder: (_) => const ThaiBetaLandingPage(),
      );
    }

    if (_normalizePath(path) == adminRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: adminRouteName),
        builder: (_) => const ThaiResearchAdminGuard(),
      );
    }

    return null;
  }
}
