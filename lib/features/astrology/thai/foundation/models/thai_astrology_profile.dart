import 'profile_warning.dart';

/// Deterministic output of Thai Foundation Engine V1.1.
///
/// Keys align with [ThaiContentKeys] for direct Theme Resolver integration.
/// Ramahabhuta is intentionally excluded — use [mahabhutaPositionKeys] instead.
class ThaiAstrologyProfile {
  const ThaiAstrologyProfile({
    this.lagnaKey,
    this.lagnaLordKey,
    this.mahabhutaPositionKeys = const [],
    this.myanmarKeys = const [],
    this.dominantMyanmarKey,
    this.hasBirthTime = true,
    this.calculationStandardVersion = 'v1.1',
    this.zodiac = 'sidereal',
    this.ayanamsa = 'lahiri',
    this.houseSystem = 'whole_sign',
    this.warnings = const [],
    this.computedAt,
    this.siderealAscendantDeg,
    this.myanmarChartNumbers,
    this.mahabhutaChartNumbers,
    this.row4Sum,
  });

  final String? lagnaKey;
  final String? lagnaLordKey;
  final List<String> mahabhutaPositionKeys;
  final List<String> myanmarKeys;
  final String? dominantMyanmarKey;

  final bool hasBirthTime;
  final String calculationStandardVersion;
  final String zodiac;
  final String ayanamsa;
  final String houseSystem;
  final List<ProfileWarning> warnings;
  final DateTime? computedAt;

  /// Audit field — sidereal ascendant in degrees (0–360), when birth time exists.
  final double? siderealAscendantDeg;

  /// Seven chart numbers (1–7) ordered by Myanmar life-position slots.
  final List<int>? myanmarChartNumbers;

  /// Row 4 vertical sums (3–21) ordered by chart columns.
  final List<int>? mahabhutaChartNumbers;

  /// Row 4 vertical sums (3–21) — audit field (alias stored on profile).
  final List<int>? row4Sum;
}
