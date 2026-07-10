/// Normalized birth data for **Western** astrology.
///
/// Western uses the actual astronomical birth instant — there is **no** day
/// adjustment. [utcInstant] is the exact moment used for chart calculation.
class WesternBirthContext {
  const WesternBirthContext({
    required this.localDateTime,
    required this.utcInstant,
    required this.timeZoneOffset,
    required this.latitude,
    required this.longitude,
    required this.hasBirthTime,
  });

  final DateTime localDateTime;

  /// Exact astronomical instant (localDateTime − timezone offset).
  final DateTime utcInstant;

  final Duration timeZoneOffset;
  final double latitude;
  final double longitude;
  final bool hasBirthTime;
}
