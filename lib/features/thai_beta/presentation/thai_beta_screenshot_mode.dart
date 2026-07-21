/// Detects full-page screenshot / GoFullPage capture mode from the launch URL.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'thai_beta_routes.dart';

/// Propagates screenshot intent through the beta navigation stack.
class ThaiBetaScreenshotScope extends InheritedWidget {
  const ThaiBetaScreenshotScope({
    super.key,
    required this.active,
    required super.child,
  });

  final bool active;

  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ThaiBetaScreenshotScope>()
            ?.active ??
        ThaiBetaScreenshotMode.isActive;
  }

  @override
  bool updateShouldNotify(ThaiBetaScreenshotScope oldWidget) {
    return oldWidget.active != active;
  }
}

abstract final class ThaiBetaScreenshotMode {
  static bool? _testOverride;
  static bool? _sessionActive;
  static String? _launchRouteName;

  /// Call once at startup with [webLaunchRouteName] before [runApp].
  static void configureFromLaunchRoute(String? launchRouteName) {
    _launchRouteName = launchRouteName;
    if (launchRouteName != null && launchRouteName.isNotEmpty) {
      final normalized =
          launchRouteName.startsWith('/') ? launchRouteName : '/$launchRouteName';
      _sessionActive = _fromUri(Uri.parse('https://local$normalized'));
      return;
    }
    _sessionActive = _fromUri(Uri.base);
  }

  /// Active when `?screenshot=1`, `?capture=1`, or path is `/beta/thai/capture`.
  static bool get isActive => _testOverride ?? _sessionActive ?? _fromUri(Uri.base);

  static String? get launchRouteName => _launchRouteName;

  static Uri get diagnosticUri {
    if (_launchRouteName != null && _launchRouteName!.isNotEmpty) {
      final normalized = _launchRouteName!.startsWith('/')
          ? _launchRouteName!
          : '/$_launchRouteName';
      return Uri.parse('https://local$normalized');
    }
    return Uri.base;
  }

  @visibleForTesting
  static set testOverride(bool? value) => _testOverride = value;

  @visibleForTesting
  static void resetForTest() {
    _testOverride = null;
    _sessionActive = null;
    _launchRouteName = null;
  }

  static bool _fromUri(Uri uri) {
    if (_queryIndicatesScreenshot(uri.queryParameters)) return true;
    if (ThaiBetaRoutes.isCapturePath(uri.path)) return true;

    final fragment = uri.fragment;
    if (fragment.isEmpty) return false;

    final fragmentPath = fragment.startsWith('/') ? fragment : '/$fragment';
    final fragmentUri = Uri.parse('https://local$fragmentPath');
    if (_queryIndicatesScreenshot(fragmentUri.queryParameters)) return true;
    if (ThaiBetaRoutes.isCapturePath(fragmentUri.path)) return true;
    return false;
  }

  static bool _queryIndicatesScreenshot(Map<String, String> query) {
    return query['screenshot'] == '1' || query['capture'] == '1';
  }
}
