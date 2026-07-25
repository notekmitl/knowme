/// Independent calendar / age / Wednesday day-night oracle for Life Map V1.2.7.
///
/// Intentionally does **not** import production resolvers (`LifePeriodEngine`,
/// `SunriseCalculator`, `BirthNormalizer`). Encodes Source-of-Truth rules
/// documented in production comments:
/// - Civil weekday via Sakamoto (Dart Mon=1…Sun=7)
/// - Whole-year age from birth YMD to as-of YMD
/// - Astrological date = prior civil day when birth is before local sunrise
/// - พุธกลางคืน / ราหู when astrological weekday is Wednesday and birth
///   local time is at/after local sunset (Almanac 90.833° zenith)
library;

import 'dart:math' as math;

/// Eight Thai birth-day categories used by the simulated matrix.
enum ThaiWeekdayCategory {
  sunday,
  monday,
  tuesday,
  wednesdayDay,
  wednesdayNight,
  thursday,
  friday,
  saturday,
}

extension ThaiWeekdayCategoryX on ThaiWeekdayCategory {
  String get id => switch (this) {
    ThaiWeekdayCategory.sunday => 'sunday',
    ThaiWeekdayCategory.monday => 'monday',
    ThaiWeekdayCategory.tuesday => 'tuesday',
    ThaiWeekdayCategory.wednesdayDay => 'wednesday_day',
    ThaiWeekdayCategory.wednesdayNight => 'wednesday_night',
    ThaiWeekdayCategory.thursday => 'thursday',
    ThaiWeekdayCategory.friday => 'friday',
    ThaiWeekdayCategory.saturday => 'saturday',
  };

  String get labelTh => switch (this) {
    ThaiWeekdayCategory.sunday => 'วันอาทิตย์',
    ThaiWeekdayCategory.monday => 'วันจันทร์',
    ThaiWeekdayCategory.tuesday => 'วันอังคาร',
    ThaiWeekdayCategory.wednesdayDay => 'วันพุธกลางวัน',
    ThaiWeekdayCategory.wednesdayNight => 'วันพุธกลางคืน',
    ThaiWeekdayCategory.thursday => 'วันพฤหัสบดี',
    ThaiWeekdayCategory.friday => 'วันศุกร์',
    ThaiWeekdayCategory.saturday => 'วันเสาร์',
  };

  /// Dart [DateTime.weekday] for this category (Wed day/night both Wednesday).
  int get civilWeekday => switch (this) {
    ThaiWeekdayCategory.sunday => DateTime.sunday,
    ThaiWeekdayCategory.monday => DateTime.monday,
    ThaiWeekdayCategory.tuesday => DateTime.tuesday,
    ThaiWeekdayCategory.wednesdayDay => DateTime.wednesday,
    ThaiWeekdayCategory.wednesdayNight => DateTime.wednesday,
    ThaiWeekdayCategory.thursday => DateTime.thursday,
    ThaiWeekdayCategory.friday => DateTime.friday,
    ThaiWeekdayCategory.saturday => DateTime.saturday,
  };

  bool get isWednesdayNight => this == ThaiWeekdayCategory.wednesdayNight;
  bool get isWednesdayDay => this == ThaiWeekdayCategory.wednesdayDay;
}

/// Pure test oracle — no production imports.
abstract final class ThaiLifeMapV127WeekdayOracle {
  static const double bangkokLat = 13.7563;
  static const double bangkokLng = 100.5018;
  static const Duration bangkokUtcOffset = Duration(hours: 7);
  static const double _officialZenith = 90.833;

  /// Sakamoto method → Dart weekday (Mon=1 … Sun=7). Independent of
  /// [DateTime.weekday] implementation details for expected-value creation.
  static int civilWeekday(int year, int month, int day) {
    final t = <int>[0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
    var y = year;
    if (month < 3) y -= 1;
    final w = (y + y ~/ 4 - y ~/ 100 + y ~/ 400 + t[month - 1] + day) % 7;
    // Sakamoto: 0=Sun … 6=Sat → Dart Mon=1…Sun=7
    return w == 0 ? DateTime.sunday : w;
  }

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  static int daysInMonth(int year, int month) {
    const lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear(year)) return 29;
    return lengths[month - 1];
  }

  /// Whole completed years from birth YMD to as-of YMD (time-of-day ignored).
  static int ageYears({required DateTime birthDate, required DateTime asOf}) {
    var age = asOf.year - birthDate.year;
    final hadBirthday =
        (asOf.month > birthDate.month) ||
        (asOf.month == birthDate.month && asOf.day >= birthDate.day);
    if (!hadBirthday) age -= 1;
    return age < 0 ? 0 : age;
  }

  static DateTime ymd(
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
  ]) => DateTime(year, month, day, hour, minute);

  /// Independent Almanac sunrise (same formula family as production SoT).
  static DateTime? localSunrise({
    required DateTime date,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
  }) => _sunEvent(
    date: date,
    latitude: latitude,
    longitude: longitude,
    utcOffset: utcOffset,
    rising: true,
  );

  /// Independent Almanac sunset.
  static DateTime? localSunset({
    required DateTime date,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
  }) => _sunEvent(
    date: date,
    latitude: latitude,
    longitude: longitude,
    utcOffset: utcOffset,
    rising: false,
  );

  /// Astrological date: prior civil day when birth is before local sunrise.
  static DateTime astrologicalDate({
    required DateTime civilLocal,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
  }) {
    final civilDay = DateTime(
      civilLocal.year,
      civilLocal.month,
      civilLocal.day,
    );
    final sunrise = localSunrise(
      date: civilDay,
      latitude: latitude,
      longitude: longitude,
      utcOffset: utcOffset,
    );
    if (sunrise != null && civilLocal.isBefore(sunrise)) {
      return civilDay.subtract(const Duration(days: 1));
    }
    return civilDay;
  }

  /// True when birth is พุธกลางคืน / ราหู under SoT sunset rule.
  static bool isWednesdayNightRahu({
    required DateTime civilLocal,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
    required bool hasBirthTime,
  }) {
    if (!hasBirthTime) return false;
    final astro = astrologicalDate(
      civilLocal: civilLocal,
      latitude: latitude,
      longitude: longitude,
      utcOffset: utcOffset,
    );
    if (civilWeekday(astro.year, astro.month, astro.day) !=
        DateTime.wednesday) {
      return false;
    }
    final sunset = localSunset(
      date: DateTime(astro.year, astro.month, astro.day),
      latitude: latitude,
      longitude: longitude,
      utcOffset: utcOffset,
    );
    if (sunset == null) return false;
    return !civilLocal.isBefore(sunset);
  }

  static ThaiWeekdayCategory categoryForBirth({
    required DateTime civilLocal,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
    required bool hasBirthTime,
  }) {
    final astro = astrologicalDate(
      civilLocal: civilLocal,
      latitude: latitude,
      longitude: longitude,
      utcOffset: utcOffset,
    );
    final wd = civilWeekday(astro.year, astro.month, astro.day);
    if (wd == DateTime.wednesday) {
      final night = isWednesdayNightRahu(
        civilLocal: civilLocal,
        latitude: latitude,
        longitude: longitude,
        utcOffset: utcOffset,
        hasBirthTime: hasBirthTime,
      );
      return night
          ? ThaiWeekdayCategory.wednesdayNight
          : ThaiWeekdayCategory.wednesdayDay;
    }
    return switch (wd) {
      DateTime.monday => ThaiWeekdayCategory.monday,
      DateTime.tuesday => ThaiWeekdayCategory.tuesday,
      DateTime.thursday => ThaiWeekdayCategory.thursday,
      DateTime.friday => ThaiWeekdayCategory.friday,
      DateTime.saturday => ThaiWeekdayCategory.saturday,
      DateTime.sunday => ThaiWeekdayCategory.sunday,
      _ => ThaiWeekdayCategory.sunday,
    };
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;
  static double _normDeg(double value) {
    var v = value % 360.0;
    if (v < 0) v += 360.0;
    return v;
  }

  static double _normHours(double value) {
    var v = value % 24.0;
    if (v < 0) v += 24.0;
    return v;
  }

  static int _dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(start).inDays + 1;
  }

  static DateTime? _sunEvent({
    required DateTime date,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
    required bool rising,
  }) {
    final n = _dayOfYear(date);
    final lngHour = longitude / 15.0;
    final t = n + (((rising ? 6.0 : 18.0) - lngHour) / 24.0);
    final m = (0.9856 * t) - 3.289;
    var l =
        m +
        (1.916 * math.sin(_rad(m))) +
        (0.020 * math.sin(_rad(2 * m))) +
        282.634;
    l = _normDeg(l);
    var ra = _deg(math.atan(0.91764 * math.tan(_rad(l))));
    ra = _normDeg(ra);
    final lQuadrant = (l / 90.0).floor() * 90.0;
    final raQuadrant = (ra / 90.0).floor() * 90.0;
    ra = ra + (lQuadrant - raQuadrant);
    ra = ra / 15.0;
    final sinDec = 0.39782 * math.sin(_rad(l));
    final cosDec = math.cos(math.asin(sinDec));
    final cosH =
        (math.cos(_rad(_officialZenith)) -
            (sinDec * math.sin(_rad(latitude)))) /
        (cosDec * math.cos(_rad(latitude)));
    if (cosH > 1 || cosH < -1) return null;
    var h = rising ? (360.0 - _deg(math.acos(cosH))) : _deg(math.acos(cosH));
    h = h / 15.0;
    final localMeanTime = h + ra - (0.06571 * t) - 6.622;
    final utHours = _normHours(localMeanTime - lngHour);
    final localHours = _normHours(utHours + (utcOffset.inMinutes / 60.0));
    final hour = localHours.floor();
    final minuteDouble = (localHours - hour) * 60.0;
    final minute = minuteDouble.floor();
    final second = ((minuteDouble - minute) * 60.0).round().clamp(0, 59);
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }
}
