import 'package:flutter/material.dart';

import 'presentation/mbti_mini_test_page.dart';

/// MBTI progressive entry (`mbti_mini` Firestore session, 16 → 40 → 80).
abstract final class MbtiRoutes {
  static const String miniPath = '/tests/mbti/mini';

  static Route<void> miniTestRoute() {
    return MaterialPageRoute<void>(
      builder: (_) => const MbtiMiniTestPage(),
      settings: const RouteSettings(name: miniPath),
    );
  }

  /// Optional hook for [MaterialApp.onGenerateRoute] (not wired by default).
  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;
    if (name == miniPath || name == '/$miniPath') {
      return miniTestRoute();
    }
    return null;
  }
}
