/// Lahiri (Chitrapaksha) ayanamsa — Swiss Ephemeris compatible approximation.
///
/// Formula aligned with SE_SIDM_LAHIRI polynomial used in common ephemeris tools.
abstract final class LahiriAyanamsa {
  static double forJulianDay(double julianDay) {
    final t = (julianDay - 2451545.0) / 36525.0;
    return 22.460148 +
        1.396042 * t +
        0.000308 * t * t -
        0.000000057 * t * t * t;
  }

  static double normalizeDegrees(double degrees) {
    var value = degrees % 360.0;
    if (value < 0) value += 360.0;
    return value;
  }

  static double siderealFromTropical({
    required double tropicalDegrees,
    required double julianDay,
  }) {
    return normalizeDegrees(tropicalDegrees - forJulianDay(julianDay));
  }
}
