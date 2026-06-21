/// Thai astrological day boundary — day changes at 06:00 local (frozen V1.1).
abstract final class ThaiDayBoundary {
  static const dayChangeHour = 6;

  /// Returns local civil datetime after applying the 06:00 day-change rule.
  ///
  /// Times before 06:00 belong to the previous calendar date for weekday lookup
  /// when no verified Thai lunar calendar entry exists.
  static DateTime effectiveLocalDateTime(DateTime localDateTime) {
    if (localDateTime.hour < dayChangeHour) {
      return DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      ).subtract(const Duration(days: 1));
    }
    return DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );
  }
}
