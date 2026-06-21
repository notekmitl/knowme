import 'package:flutter/material.dart';

import 'thai_mirror_qa_screen.dart';

/// Internal QA routes for Thai Mirror batch validation.
abstract final class ThaiMirrorQaRoutes {
  static const String qaPath = '/thai-mirror/qa';

  static Route<void> qa() {
    return MaterialPageRoute<void>(
      builder: (_) => const ThaiMirrorQaScreen(),
      settings: const RouteSettings(name: qaPath),
    );
  }

  static Future<void> openQa(BuildContext context) {
    return Navigator.of(context).push(qa());
  }

  static bool _nameMatches(String? name, String path) {
    if (name == null) return false;
    if (name == path) return true;
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    return name == trimmed;
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    if (_nameMatches(settings.name, qaPath)) {
      return qa();
    }
    return null;
  }
}
