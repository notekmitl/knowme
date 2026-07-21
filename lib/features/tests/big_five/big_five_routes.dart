import 'package:flutter/material.dart';

import 'domain/big_five_models.dart';
import 'presentation/big_five_result_page.dart';
import 'presentation/big_five_test_page.dart';

/// Big Five progressive routes (test + result).
abstract final class BigFiveRoutes {
  static const String testPath = '/tests/big-five';
  static const String resultPath = '/tests/big-five/result';

  static Route<void> testRoute({
    bool continueToStandardCheckpoint = false,
    bool continueToDeepCheckpoint = false,
    Map<String, int>? restoredAnswers,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: testPath),
      builder: (_) => BigFiveTestPage(
        continueToStandardCheckpoint: continueToStandardCheckpoint,
        continueToDeepCheckpoint: continueToDeepCheckpoint,
        restoredAnswers: restoredAnswers,
      ),
    );
  }

  static Route<void> resultRoute({
    required BigFiveResultSummary summary,
    bool canContinueToStandard = false,
    bool canContinueToDeep = false,
    Map<String, int>? pendingAnswersForContinue,
    VoidCallback? onContinueToStandard,
    VoidCallback? onContinueToDeep,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: resultPath),
      builder: (_) => BigFiveResultPage(
        summary: summary,
        canContinueToStandard: canContinueToStandard,
        canContinueToDeep: canContinueToDeep,
        pendingAnswersForContinue: pendingAnswersForContinue,
        onContinueToStandard: onContinueToStandard,
        onContinueToDeep: onContinueToDeep,
      ),
    );
  }

  static Future<void> openTest(BuildContext context) {
    return Navigator.of(context).push(testRoute());
  }

  static Future<void> openResult(
    BuildContext context, {
    required BigFiveResultSummary summary,
    bool canContinueToStandard = false,
    bool canContinueToDeep = false,
    Map<String, int>? pendingAnswersForContinue,
    VoidCallback? onContinueToStandard,
    VoidCallback? onContinueToDeep,
  }) {
    return Navigator.of(context).push(
      resultRoute(
        summary: summary,
        canContinueToStandard: canContinueToStandard,
        canContinueToDeep: canContinueToDeep,
        pendingAnswersForContinue: pendingAnswersForContinue,
        onContinueToStandard: onContinueToStandard,
        onContinueToDeep: onContinueToDeep,
      ),
    );
  }

  static bool _nameMatches(String? name, String path) {
    if (name == null) return false;
    if (name == path) return true;
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    return name == trimmed;
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (_nameMatches(name, testPath)) return testRoute();
    return null;
  }
}
