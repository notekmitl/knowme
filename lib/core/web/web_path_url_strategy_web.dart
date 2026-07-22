import 'package:flutter_web_plugins/url_strategy.dart';

/// Uses path-based URLs so Firebase Hosting deep links like `/beta/thai`
/// stay in [window.location.pathname] instead of being rewritten to `/`.
void configureKnowMePathUrlStrategy() {
  usePathUrlStrategy();
}
