import 'package:flutter/material.dart';

import 'thai_mirror_population_qa_screen.dart';

/// Internal Population QA routes for Thai Mirror statistical validation.
abstract final class ThaiMirrorPopulationQaRoutes {
  static const String populationQaPath = '/thai-mirror/population-qa';

  static Route<void> populationQa() {
    return MaterialPageRoute<void>(
      builder: (_) => const ThaiMirrorPopulationQaScreen(),
      settings: const RouteSettings(name: populationQaPath),
    );
  }

  static Future<void> openPopulationQa(BuildContext context) {
    return Navigator.of(context).push(populationQa());
  }

  static bool _nameMatches(String? name, String path) {
    if (name == null) return false;
    if (name == path) return true;
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    return name == trimmed;
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    if (_nameMatches(settings.name, populationQaPath)) {
      return populationQa();
    }
    return null;
  }
}
