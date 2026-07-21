import 'package:flutter/material.dart';

import 'pages/astrology_fusion_demo_page.dart';

abstract final class AstrologyFusionDemoRoutes {
  static const routeName = '/astrology-fusion-demo';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name != routeName) return null;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const AstrologyFusionDemoPage(),
    );
  }
}
