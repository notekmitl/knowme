import 'package:flutter/material.dart';

import 'domain/mbti_cognitive_models.dart';
import 'presentation/mbti_cognitive_result_page.dart';
import 'presentation/mbti_cognitive_test_page.dart';

abstract final class MbtiCognitiveRoutes {
  static const test = '/tests/mbti/cognitive';
  static const result = '/tests/mbti/cognitive/result';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case test:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MbtiCognitiveTestPage(),
        );
      case result:
        final summary = settings.arguments;
        if (summary is! MbtiCognitiveResultSummary) {
          return null;
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MbtiCognitiveResultPage(summary: summary),
        );
      default:
        return null;
    }
  }

  static Route<void> testRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: test),
      builder: (_) => const MbtiCognitiveTestPage(),
    );
  }
}
