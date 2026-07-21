/// Versioning and calculation metadata for [ThaiChart].
class ThaiChartMetadata {
  const ThaiChartMetadata({
    required this.engineVersion,
    required this.schemaVersion,
    required this.zodiac,
    required this.ayanamsa,
    required this.houseSystem,
    required this.birthFingerprint,
    required this.computedAt,
    required this.hasBirthTime,
  });

  final String engineVersion;
  final String schemaVersion;
  final String zodiac;
  final String ayanamsa;
  final String houseSystem;
  final String birthFingerprint;
  final DateTime computedAt;
  final bool hasBirthTime;
}
