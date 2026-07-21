/// Stores the browser launch route for post-auth redirect on web.
library;

import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_routes.dart';

import 'web_launch_route_uri.dart';

abstract final class WebIntendedRoute {
  static String? _stored;

  /// Call once at startup with the captured browser launch route.
  static void configure(String? routeName) {
    if (routeName == null || routeName.isEmpty) {
      _stored = null;
      return;
    }
    _stored = routeName.startsWith('/') ? routeName : '/$routeName';
  }

  static String? get stored => _stored;

  /// Returns a pending Thai Beta screenshot deep link without clearing storage.
  static String? peekThaiBetaScreenshot() {
    final route = _stored;
    if (route == null) return null;
    if (!ThaiBetaScreenshotRoutes.isDeepLinkName(route)) return null;
    return route;
  }

  /// Returns and clears a pending Thai Beta screenshot deep link, if any.
  static String? consumeThaiBetaScreenshot() {
    final route = peekThaiBetaScreenshot();
    if (route == null) return null;
    _stored = null;
    return route;
  }

  /// Visible for tests.
  static void resetForTest() => _stored = null;
}
