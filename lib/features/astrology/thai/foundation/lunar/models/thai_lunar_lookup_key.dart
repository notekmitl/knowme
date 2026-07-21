/// Normalized Gregorian lookup key for Thai lunar dataset queries.
///
/// Keys use local civil datetime components (year, month, day, hour, minute)
/// as stored in [ThaiBirthData.localDateTime].
class ThaiLunarLookupKey {
  const ThaiLunarLookupKey({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
  });

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;

  factory ThaiLunarLookupKey.fromDateTime(DateTime localDateTime) {
    return ThaiLunarLookupKey(
      year: localDateTime.year,
      month: localDateTime.month,
      day: localDateTime.day,
      hour: localDateTime.hour,
      minute: localDateTime.minute,
    );
  }

  /// Canonical string: `yyyy-MM-dd HH:mm` (local civil).
  String get canonical => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')} '
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) {
    return other is ThaiLunarLookupKey &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(year, month, day, hour, minute);
}
