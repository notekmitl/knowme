import 'package:flutter/material.dart';

import 'presentation/fusion_result_page.dart';

/// Navigation helpers for Fusion (additive; does not alter existing routes).
abstract final class FusionRoutes {
  static const String resultPath = '/fusion/result';

  static Route<void> resultRoute() {
    return MaterialPageRoute<void>(
      builder: (_) => const FusionResultPage(),
      settings: const RouteSettings(name: resultPath),
    );
  }

  static Future<void> openResult(BuildContext context) {
    return Navigator.of(context).push(resultRoute());
  }
}
