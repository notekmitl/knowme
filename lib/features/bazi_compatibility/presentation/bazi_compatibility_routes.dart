import 'package:flutter/material.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/presentation/bazi_compatibility_owner_page.dart';

abstract final class BaziCompatibilityRoutes {
  static const String ownerRouteName = '/beta/chinese';

  static bool isOwnerPath(String path) => path == ownerRouteName;

  static Widget? resolve(Uri uri) {
    if (!isOwnerPath(uri.path)) return null;
    return BaziCompatibilityOwnerPage(
      initialCase: BaziCompatibilityOwnerFixtures.parse(
        uri.queryParameters['case'],
      ),
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final widget = resolve(Uri.parse(settings.name ?? ''));
    if (widget == null) return null;
    return MaterialPageRoute<void>(settings: settings, builder: (_) => widget);
  }
}
