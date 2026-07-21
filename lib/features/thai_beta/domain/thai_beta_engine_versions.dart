/// Version stamps for every layer that produced a beta submission, so feedback
/// can be correlated with the exact engine/pipeline that generated the report.
class ThaiBetaEngineVersions {
  const ThaiBetaEngineVersions({
    required this.thaiFoundationVersion,
    required this.birthNormalizationVersion,
    required this.betaSchemaVersion,
  });

  /// Thai Foundation Engine standard (e.g. `v1.1`), from the generated profile.
  final String thaiFoundationVersion;

  /// Birth Normalization layer version.
  final String birthNormalizationVersion;

  /// Beta record schema version (for future migrations).
  final String betaSchemaVersion;

  static const String currentBirthNormalizationVersion = 'birth-normalization-v1';
  static const String currentBetaSchemaVersion = 'thai-beta-v1';

  Map<String, dynamic> toMap() {
    return {
      'thaiFoundationVersion': thaiFoundationVersion,
      'birthNormalizationVersion': birthNormalizationVersion,
      'betaSchemaVersion': betaSchemaVersion,
    };
  }

  factory ThaiBetaEngineVersions.fromMap(Map<String, dynamic> map) {
    return ThaiBetaEngineVersions(
      thaiFoundationVersion: (map['thaiFoundationVersion'] ?? 'unknown').toString(),
      birthNormalizationVersion:
          (map['birthNormalizationVersion'] ?? 'unknown').toString(),
      betaSchemaVersion: (map['betaSchemaVersion'] ?? 'unknown').toString(),
    );
  }
}
