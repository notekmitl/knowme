import 'package:flutter/material.dart';

import 'pages/astrology_fusion_entry_page.dart';

abstract final class AstrologyFusionRoutes {
  static const resultRouteName = '/astrology-fusion';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name != resultRouteName) return null;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const AstrologyFusionEntryPage(),
    );
  }

  static Future<void> openResult(BuildContext context) {
    return Navigator.of(context).pushNamed(resultRouteName);
  }
}
