/// Normalized birth data for **Thai** astrology.
///
/// The defining rule: the Thai astrological day starts at **local sunrise**, not
/// at a hardcoded clock time. If the birth instant is before local sunrise, the
/// astrological date is the previous calendar day. [astrologicalDate] is the
/// authoritative date Thai engines should use for weekday/day-ruler lookup
/// (superseding the legacy frozen 06:00 `ThaiDayBoundary`).
class ThaiBirthContext {
  const ThaiBirthContext({
    required this.localDateTime,
    required this.localSunrise,
    required this.bornBeforeSunrise,
    required this.astrologicalDate,
    required this.timeZoneOffset,
    required this.latitude,
    required this.longitude,
    required this.hasBirthTime,
    required this.sunriseAvailable,
  });

  /// Civil local datetime used (assumed noon when no birth time was given).
  final DateTime localDateTime;

  /// Local sunrise on the civil birth date (null-of-meaning when
  /// [sunriseAvailable] is false).
  final DateTime localSunrise;

  final bool bornBeforeSunrise;

  /// Date-only. Previous calendar day when [bornBeforeSunrise], else the civil day.
  final DateTime astrologicalDate;

  final Duration timeZoneOffset;
  final double latitude;
  final double longitude;
  final bool hasBirthTime;

  /// False at polar latitudes/dates where sunrise does not occur.
  final bool sunriseAvailable;
}
