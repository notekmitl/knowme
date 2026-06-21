import 'dart:math' as math;

import 'lahiri_ayanamsa.dart';

/// Tropical ascendant + sidereal lagna sign using Whole Sign houses.
abstract final class SiderealAscendant {
  static const _degToRad = math.pi / 180.0;
  static const _radToDeg = 180.0 / math.pi;

  static double julianDay(DateTime utc) {
    final year = utc.year;
    final month = utc.month;
    final day = utc.day +
        (utc.hour + utc.minute / 60.0 + utc.second / 3600.0 + utc.millisecond / 3600000.0) /
            24.0;

    var y = year;
    var m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  static double tropicalAscendantDegrees({
    required double julianDay,
    required double latitude,
    required double longitudeEast,
  }) {
    final t = (julianDay - 2451545.0) / 36525.0;
    final obliquity = 23.439291 -
        0.0130042 * t -
        0.00000016 * t * t +
        0.000000504 * t * t * t;

    final gmst = _normalizeDegrees(
      280.46061837 +
          360.98564736629 * (julianDay - 2451545.0) +
          0.000387933 * t * t -
          t * t * t / 38710000.0,
    );

    final lst = _normalizeDegrees(gmst + longitudeEast);
    final ramc = lst * _degToRad;
    final lat = latitude * _degToRad;
    final eps = obliquity * _degToRad;

    final y = math.cos(ramc);
    final x = -math.sin(eps) * math.tan(lat) + math.cos(eps) * math.sin(ramc);
    final asc = math.atan2(y, x) * _radToDeg;
    return LahiriAyanamsa.normalizeDegrees(asc);
  }

  static int wholeSignIndex(double siderealAscendantDegrees) {
    final normalized = LahiriAyanamsa.normalizeDegrees(siderealAscendantDegrees);
    return (normalized / 30.0).floor() % 12;
  }

  static double siderealAscendantDegrees({
    required DateTime utc,
    required double latitude,
    required double longitudeEast,
  }) {
    final jd = julianDay(utc);
    final tropical = tropicalAscendantDegrees(
      julianDay: jd,
      latitude: latitude,
      longitudeEast: longitudeEast,
    );
    return LahiriAyanamsa.siderealFromTropical(
      tropicalDegrees: tropical,
      julianDay: jd,
    );
  }

  static double _normalizeDegrees(double degrees) {
    var value = degrees % 360.0;
    if (value < 0) value += 360.0;
    return value;
  }
}
