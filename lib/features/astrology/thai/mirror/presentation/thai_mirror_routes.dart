import 'package:flutter/material.dart';

import 'pages/thai_mirror_consumer_preview_page.dart';
import 'pages/thai_mirror_entry_page.dart';

/// Production routes for Thai Astrology — wired from Home (not QA/demo).
abstract final class ThaiMirrorRoutes {
  static const String resultRouteName = '/thai-astrology';
  static const String consumerPreviewRouteName =
      ThaiMirrorConsumerPreviewPage.routeName;

  static Route<void> resultRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: resultRouteName),
      builder: (_) => const ThaiMirrorEntryPage(),
    );
  }

  static Future<void> openResult(BuildContext context) {
    return Navigator.of(context).push(resultRoute());
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == consumerPreviewRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: consumerPreviewRouteName),
        builder: (_) => const ThaiMirrorConsumerPreviewPage(),
      );
    }

    if (settings.name == '/thai-mirror/consumer-preview-no-time') {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/thai-mirror/consumer-preview-no-time'),
        builder: (_) => const ThaiMirrorConsumerPreviewPage(
          profileId: 'A',
          hasBirthTime: false,
        ),
      );
    }

    if (settings.name != resultRouteName) return null;

    return resultRoute();
  }
}
