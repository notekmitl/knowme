/// Detects full-page screenshot / GoFullPage capture mode from the launch URL.
library;

import 'package:flutter/foundation.dart';

abstract final class ThaiBetaScreenshotMode {
  static bool? _testOverride;

  /// Active when `?screenshot=1`, `?capture=1`, or path ends with `/capture`.
  static bool get isActive => _testOverride ?? _fromUri(Uri.base);

  @visibleForTesting
  static set testOverride(bool? value) => _testOverride = value;

  static bool _fromUri(Uri uri) {
    final screenshot = uri.queryParameters['screenshot'];
    final capture = uri.queryParameters['capture'];
    if (screenshot == '1' || capture == '1') return true;

    final path = uri.path;
    if (path.endsWith('/capture') || path.contains('/beta/thai/capture')) {
      return true;
    }

    final fragment = uri.fragment;
    if (fragment.isEmpty) return false;
    final fragmentUri = Uri.parse(
      fragment.startsWith('/') ? fragment : '/$fragment',
    );
    if (fragmentUri.path.endsWith('/capture')) return true;
    if (fragmentUri.queryParameters['screenshot'] == '1') return true;
    if (fragmentUri.queryParameters['capture'] == '1') return true;
    return false;
  }
}
