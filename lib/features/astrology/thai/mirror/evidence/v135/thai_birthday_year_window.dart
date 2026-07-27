/// Calendar birthday-year window for the reading date.
///
/// From the most recent birthday through one day before the next birthday.
/// Pure date math — not an ephemeris solar return.
class ThaiBirthdayYearWindow {
  const ThaiBirthdayYearWindow({
    required this.startInclusive,
    required this.endInclusive,
    required this.asOfLocalDate,
    required this.birthMonth,
    required this.birthDay,
  });

  /// Local calendar date of the most recent birthday (inclusive).
  final DateTime startInclusive;

  /// Local calendar date of the day before the next birthday (inclusive).
  final DateTime endInclusive;

  /// Reading date (local calendar date, time stripped).
  final DateTime asOfLocalDate;

  final int birthMonth;
  final int birthDay;

  /// Resolve [birthLocalDate] + [asOfLocal] into a birthday-year window.
  ///
  /// Both inputs are interpreted as local civil dates (time ignored).
  /// 29 February births use 28 February in non-leap years.
  static ThaiBirthdayYearWindow resolve({
    required DateTime birthLocalDate,
    required DateTime asOfLocal,
  }) {
    final birth = _dateOnly(birthLocalDate);
    final asOf = _dateOnly(asOfLocal);
    final month = birth.month;
    final day = birth.day;

    final birthdayThisYear = _birthdayInYear(asOf.year, month, day);
    final DateTime start;
    final DateTime nextBirthday;
    if (!asOf.isBefore(birthdayThisYear)) {
      start = birthdayThisYear;
      nextBirthday = _birthdayInYear(asOf.year + 1, month, day);
    } else {
      start = _birthdayInYear(asOf.year - 1, month, day);
      nextBirthday = birthdayThisYear;
    }
    final end = nextBirthday.subtract(const Duration(days: 1));

    return ThaiBirthdayYearWindow(
      startInclusive: start,
      endInclusive: end,
      asOfLocalDate: asOf,
      birthMonth: month,
      birthDay: day,
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _birthdayInYear(int year, int month, int day) {
    if (month == 2 && day == 29 && !_isLeap(year)) {
      return DateTime(year, 2, 28);
    }
    return DateTime(year, month, day);
  }

  static bool _isLeap(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));

  String get labelTh {
    final s =
        '${startInclusive.day}/${startInclusive.month}/${startInclusive.year}';
    final e = '${endInclusive.day}/${endInclusive.month}/${endInclusive.year}';
    return '$s – $e';
  }

  bool contains(DateTime localDate) {
    final d = _dateOnly(localDate);
    return !d.isBefore(startInclusive) && !d.isAfter(endInclusive);
  }
}
