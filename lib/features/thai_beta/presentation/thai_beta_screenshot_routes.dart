import 'package:knowme/core/web/web_launch_route_uri.dart';

import 'thai_beta_routes.dart';

/// Deep-link detection for Thai Beta screenshot / capture URLs.
abstract final class ThaiBetaScreenshotRoutes {
  static bool isDeepLink(Uri uri) {
    if (ThaiBetaRoutes.isCapturePath(uri.path)) return true;
    if (!ThaiBetaRoutes.isBetaPath(uri.path)) return false;
    return _queryIndicatesScreenshot(uri.queryParameters);
  }

  static bool isDeepLinkName(String routeName) {
    return isDeepLink(routeUriFromName(routeName));
  }

  static bool _queryIndicatesScreenshot(Map<String, String> query) {
    return query['screenshot'] == '1' || query['capture'] == '1';
  }
}
