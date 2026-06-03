import 'package:flutter/material.dart';

import 'domain/eq_test_type.dart';
import 'presentation/eq_home_page.dart';
import 'presentation/eq_summary_page.dart';
import 'presentation/eq_test_page.dart';

/// EQ feature routes (home + one route per mini test).
abstract final class EqRoutes {
  static const String homePath = '/tests/eq';

  static const String awarenessPath = '/tests/eq/awareness';
  static const String regulationPath = '/tests/eq/regulation';
  static const String empathyPath = '/tests/eq/empathy';
  static const String socialPath = '/tests/eq/social';
  static const String decisionPath = '/tests/eq/decision';
  static const String stressPath = '/tests/eq/stress';
  static const String summaryPath = '/tests/eq/summary';

  static Route<void> home() {
    return MaterialPageRoute<void>(
      builder: (_) => const EqHomePage(),
      settings: const RouteSettings(name: homePath),
    );
  }

  static Route<void> awareness() => _route(EqTestType.awareness, awarenessPath);
  static Route<void> regulation() =>
      _route(EqTestType.regulation, regulationPath);
  static Route<void> empathy() => _route(EqTestType.empathy, empathyPath);
  static Route<void> social() => _route(EqTestType.social, socialPath);
  static Route<void> decision() => _route(EqTestType.decision, decisionPath);
  static Route<void> stress() => _route(EqTestType.stress, stressPath);

  static Route<void> summary() {
    return MaterialPageRoute<void>(
      builder: (_) => const EqSummaryPage(),
      settings: const RouteSettings(name: summaryPath),
    );
  }

  static Route<void> _route(EqTestType type, String path) {
    return MaterialPageRoute<void>(
      builder: (_) => EqTestPage(testType: type),
      settings: RouteSettings(name: path),
    );
  }

  static bool _nameMatches(String? name, String path) {
    if (name == null) return false;
    if (name == path) return true;
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    return name == trimmed;
  }

  static Route<void>? routeForTestType(EqTestType type) => switch (type) {
        EqTestType.awareness => awareness(),
        EqTestType.regulation => regulation(),
        EqTestType.empathy => empathy(),
        EqTestType.social => social(),
        EqTestType.decision => decision(),
        EqTestType.stress => stress(),
      };

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (_nameMatches(name, homePath)) return home();
    if (_nameMatches(name, awarenessPath)) return awareness();
    if (_nameMatches(name, regulationPath)) return regulation();
    if (_nameMatches(name, empathyPath)) return empathy();
    if (_nameMatches(name, socialPath)) return social();
    if (_nameMatches(name, decisionPath)) return decision();
    if (_nameMatches(name, stressPath)) return stress();
    if (_nameMatches(name, summaryPath)) return summary();
    return null;
  }

  static Route<void>? routeForModuleId(String moduleId) => switch (moduleId) {
        'eq_awareness' => awareness(),
        'eq_regulation' => regulation(),
        'eq_empathy' => empathy(),
        'eq_social' => social(),
        'eq_decision' => decision(),
        'eq_stress' => stress(),
        _ => null,
      };
}
