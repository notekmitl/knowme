import 'package:flutter/material.dart';

import 'pages/thai_mirror_entry_page.dart';

/// Production routes for Thai Astrology — wired from Home (not QA/demo).
abstract final class ThaiMirrorRoutes {
  static const String resultRouteName = '/thai-astrology';

  static Route<void> resultRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: resultRouteName),
      builder: (_) => const ThaiMirrorEntryPage(),
    );
  }

  static Future<void> openResult(BuildContext context) {
    return Navigator.of(context).push(resultRoute());
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    if (settings.name != resultRouteName) return null;

    return resultRoute();
  }
}
