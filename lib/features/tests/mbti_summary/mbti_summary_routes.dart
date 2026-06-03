import 'package:flutter/material.dart';

import 'presentation/mbti_summary_fusion_page.dart';
import 'presentation/mbti_summary_gate_page.dart';

abstract final class MbtiSummaryRoutes {
  static const fusion = '/tests/mbti/summary';
  static const gate = '/tests/mbti/summary/gate';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case fusion:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MbtiSummaryFusionPage(),
        );
      case gate:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MbtiSummaryGatePage(),
        );
      default:
        return null;
    }
  }

  static Route<void> fusionRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: fusion),
      builder: (_) => const MbtiSummaryFusionPage(),
    );
  }

  static Route<void> gateRoute({MbtiSummaryGateArgs? args}) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: gate),
      builder: (_) => MbtiSummaryGatePage(args: args),
    );
  }
}
