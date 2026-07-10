import 'package:flutter/material.dart';

import '../../qa/harness/thai_qa_harness_spec.dart';
import 'pages/thai_mirror_consumer_preview_page.dart';
import 'pages/thai_mirror_entry_page.dart';

/// Production routes for Thai Astrology — wired from Home (not QA/demo).
abstract final class ThaiMirrorRoutes {
  static const String resultRouteName = '/thai-astrology';
  static const String consumerPreviewRouteName =
      ThaiMirrorConsumerPreviewPage.routeName;
  static const String consumerPreviewNoTimeRouteName =
      '/thai-mirror/consumer-preview-no-time';

  static Route<void> resultRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: resultRouteName),
      builder: (_) => const ThaiMirrorEntryPage(),
    );
  }

  static Future<void> openResult(BuildContext context) {
    return Navigator.of(context).push(resultRoute());
  }

  static Uri _routeUri(String name) {
    final normalized = name.startsWith('/') ? name : '/$name';
    return Uri.parse('https://local$normalized');
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final path = _routeUri(name).path;

    if (path == consumerPreviewRouteName) {
      final spec = ThaiQaHarnessSpec.fromQueryParameters(
        _routeUri(name).queryParameters,
      );
      return MaterialPageRoute<void>(
        settings: RouteSettings(name: name),
        builder: (_) => ThaiMirrorConsumerPreviewPage(spec: spec),
      );
    }

    if (path == consumerPreviewNoTimeRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: consumerPreviewNoTimeRouteName),
        builder: (_) => const ThaiMirrorConsumerPreviewPage(
          profileId: 'A',
          hasBirthTime: false,
        ),
      );
    }

    if (path == resultRouteName) {
      return resultRoute();
    }

    return null;
  }
}
