import 'package:flutter/foundation.dart';

/// Astrology API base URL (no trailing slash).
///
/// Override at build/run time:
/// `flutter run --dart-define=ASTROLOGY_API_BASE_URL=https://api.example.com`
///
/// Release builds fall back to production Cloud Run when the define is omitted,
/// so a plain `flutter build web --release` cannot silently ship localhost.
class ApiConfig {
  static const String _fromEnv = String.fromEnvironment('ASTROLOGY_API_BASE_URL');
  static const String _productionFallback =
      'https://knowme-astrology-api-avbyttircq-as.a.run.app';

  static String get astrologyBaseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (kReleaseMode) return _productionFallback;
    return 'http://127.0.0.1:8000';
  }

  static Uri astrologyGenerateChartUri() {
    return Uri.parse('$astrologyBaseUrl/generate-chart');
  }

  static Uri baziGenerateUri() {
    return Uri.parse('$astrologyBaseUrl/generate-bazi');
  }
}
