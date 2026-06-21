import 'package:flutter/material.dart';

import '../../foundation/models/thai_birth_data.dart';
import 'thai_mirror_demo_screen.dart';

/// Internal QA routes for Thai Mirror — not wired to Home.
abstract final class ThaiMirrorDemoRoutes {
  static const String demoPath = '/thai-mirror/demo';

  static Route<void> demo({ThaiBirthData? birthData}) {
    return MaterialPageRoute<void>(
      builder: (_) => ThaiMirrorDemoScreen(birthData: birthData),
      settings: const RouteSettings(name: demoPath),
    );
  }

  static Future<void> openDemo(BuildContext context, {ThaiBirthData? birthData}) {
    return Navigator.of(context).push(demo(birthData: birthData));
  }

  static bool _nameMatches(String? name, String path) {
    if (name == null) return false;
    if (name == path) return true;
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    return name == trimmed;
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    if (_nameMatches(settings.name, demoPath)) {
      return demo();
    }
    return null;
  }
}
