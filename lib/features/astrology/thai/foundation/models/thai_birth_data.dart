/// Birth input for Thai Foundation Engine V1.
///
/// [localDateTime] uses civil/local calendar components (date + optional time).
/// [timeZoneOffset] converts local civil time to UTC (e.g. `Duration(hours: 7)` for ICT).
class ThaiBirthData {
  const ThaiBirthData({
    required this.localDateTime,
    required this.timeZoneOffset,
    required this.latitude,
    required this.longitude,
    this.hasBirthTime = true,
  });

  final DateTime localDateTime;
  final Duration timeZoneOffset;
  final double latitude;
  final double longitude;
  final bool hasBirthTime;

  DateTime get utcDateTime => localDateTime.subtract(timeZoneOffset);

  DateTime get dateOnly => DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );
}
