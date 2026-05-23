/// Astrology API base URL (no trailing slash).
///
/// Override at build/run time:
/// `flutter run --dart-define=ASTROLOGY_API_BASE_URL=https://api.example.com`
class ApiConfig {
  static const String astrologyBaseUrl = String.fromEnvironment(
    'ASTROLOGY_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static Uri astrologyGenerateChartUri() {
    return Uri.parse('$astrologyBaseUrl/generate-chart');
  }
}
