/// Metadata for the Thai lunar dataset backing [ThaiLunarRepository].
class ThaiLunarDatasetManifest {
  const ThaiLunarDatasetManifest({
    required this.infrastructureVersion,
    required this.schemaVersion,
    required this.entryCount,
    required this.coverageStatus,
    this.coverageStartGregorian,
    this.coverageEndGregorian,
    this.primaryDataSource,
    this.notes = const [],
  });

  /// Infrastructure release (not chart standard version).
  final String infrastructureVersion;

  /// Record JSON/schema version for embedded datasets.
  final int schemaVersion;

  /// Number of lookup entries currently available.
  final int entryCount;

  /// Whether full user-birth coverage is available.
  final ThaiLunarCoverageStatus coverageStatus;

  /// Inclusive start of Gregorian coverage when populated.
  final DateTime? coverageStartGregorian;

  /// Inclusive end of Gregorian coverage when populated.
  final DateTime? coverageEndGregorian;

  /// Authoritative source name (e.g. ปฏิทิน 100 ปี, เกษมบรรณกิจ 150 ปี).
  final String? primaryDataSource;

  final List<String> notes;
}

enum ThaiLunarCoverageStatus {
  /// Only verified golden-case entries (current V1).
  goldenCasesOnly,

  /// Partial range populated from licensed source.
  partial,

  /// Full target range populated and validated.
  complete,
}
