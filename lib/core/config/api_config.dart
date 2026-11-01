import 'package:flutter/foundation.dart';

/// Astrology API base URL (no trailing slash).
///
/// Override at build/run time:
/// `flutter run --dart-define=ASTROLOGY_API_BASE_URL=https://api.example.com`
///
/// Release builds fall back to production Cloud Run when the define is omitted,
/// so a plain `flutter build web --release` cannot silently ship localhost.
class ApiConfig {
  static const bool isOverallPreview = bool.fromEnvironment(
    'KNOWME_OVERALL_PREVIEW',
  );

  /// Enables the anonymous astrology trial in a normal Production build.
  /// Unlike [isOverallPreview], this does not bypass Firebase initialization
  /// for the rest of the application.
  static const bool isOverallTrial =
      isOverallPreview || bool.fromEnvironment('KNOWME_OVERALL_TRIAL');
  static const String _fromEnv = String.fromEnvironment(
    'ASTROLOGY_API_BASE_URL',
  );
  static const String _overallFromEnv = String.fromEnvironment(
    'OVERALL_CALC_API_BASE_URL',
  );
  static const String _productionFallback =
      'https://knowme-astrology-api-avbyttircq-as.a.run.app';

  static String get astrologyBaseUrl {
    if (isOverallPreview) {
      if (_fromEnv.isEmpty ||
          _fromEnv.contains('knowme-astrology-api-avbyttircq-as.a.run.app')) {
        throw StateError('Overall Preview requires its isolated backend URL');
      }
      return _fromEnv;
    }
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (kReleaseMode) return _productionFallback;
    return 'http://127.0.0.1:8000';
  }

  static Uri astrologyGenerateChartUri() {
    return Uri.parse('$astrologyBaseUrl/v1/generate-chart');
  }

  static String get overallCalculationBaseUrl {
    // The existing isolated Preview build retains its pinned API URL.
    if (isOverallPreview) return astrologyBaseUrl;
    if (isOverallTrial) {
      final uri = Uri.tryParse(_overallFromEnv);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          (uri.path.isNotEmpty && uri.path != '/') ||
          uri.hasQuery ||
          uri.hasFragment ||
          uri.host == Uri.parse(_productionFallback).host) {
        throw StateError('Overall trial requires a separate HTTPS calculator');
      }
      return _overallFromEnv.replaceFirst(RegExp(r'/$'), '');
    }
    return astrologyBaseUrl;
  }

  static Uri baziGenerateUri() {
    return Uri.parse('$astrologyBaseUrl/v1/generate-bazi');
  }

  static Uri astrologyCalculateChartUri() {
    return Uri.parse('$overallCalculationBaseUrl/v1/calculate-chart');
  }

  static Uri baziCalculateUri() {
    return Uri.parse('$overallCalculationBaseUrl/v1/calculate-bazi');
  }

  /// Compatibility paths used only by already-released clients. New code must
  /// use the authenticated versioned endpoints above.
  static Uri legacyAstrologyGenerateChartUri() {
    return Uri.parse('$astrologyBaseUrl/generate-chart');
  }

  static Uri legacyBaziGenerateUri() {
    return Uri.parse('$astrologyBaseUrl/generate-bazi');
  }
}
