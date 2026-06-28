import 'package:flutter/material.dart';

import 'mirror_experience_entry_page.dart';

/// P3 — routing for the Global Mirror Experience.
///
/// Additive only: this plugs into the app's existing `onGenerateRoute` chain
/// without touching the production AuthGate → ProfileGate → HomePage flow.
abstract final class MirrorExperienceRoutes {
  static const String homeRouteName = '/mirror-experience';

  static Route<void> homeRoute() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: homeRouteName),
        builder: (_) => const MirrorExperienceEntryPage(),
      );

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(homeRoute());

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final path = Uri.tryParse(name)?.path ?? name;
    if (path == homeRouteName) {
      return homeRoute();
    }
    return null;
  }
}
