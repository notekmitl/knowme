import 'package:flutter/material.dart';

import 'domain/personality_mirror_narrative_view.dart';
import 'presentation/personality_mirror_entry_page.dart';
import 'presentation/personality_mirror_gate_page.dart';
import 'presentation/personality_mirror_result_page.dart';

/// Personality Mirror routes (entry, gate, result).
abstract final class PersonalityMirrorRoutes {
  static const String entryPath = '/personality-mirror';
  static const String gatePath = '/personality-mirror/gate';
  static const String resultPath = '/personality-mirror/result';

  static Route<void> entryRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: entryPath),
      builder: (_) => const PersonalityMirrorEntryPage(),
    );
  }

  static Route<void> gateRoute({PersonalityMirrorGateArgs? args}) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: gatePath),
      builder: (_) => PersonalityMirrorGatePage(args: args),
    );
  }

  static Route<void> resultRoute({
    required PersonalityMirrorNarrativeView narrative,
    bool showFullExperience = true,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: resultPath),
      builder: (_) => PersonalityMirrorResultPage(
        narrative: narrative,
        showFullExperience: showFullExperience,
      ),
    );
  }

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(entryRoute());
  }

  static bool _nameMatches(String? name, String path) {
    if (name == null) return false;
    if (name == path) return true;
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    return name == trimmed;
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (_nameMatches(name, entryPath)) return entryRoute();
    if (_nameMatches(name, gatePath)) {
      return gateRoute(
        args: settings.arguments is PersonalityMirrorGateArgs
            ? settings.arguments as PersonalityMirrorGateArgs
            : null,
      );
    }
    return null;
  }
}
