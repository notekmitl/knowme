import 'dart:math' as math;

/// Result of a sunrise computation for a given date/place.
class SunriseCalculation {
  const SunriseCalculation({required this.localSunrise, required this.available});

  /// Local sunrise on the requested civil date. When [available] is false this
  /// falls back to 06:00 local purely so callers always have a value; callers
  /// must check [available] before treating it as a real sunrise.
  final DateTime localSunrise;

  /// False at polar latitudes/dates where the sun does not rise.
  final bool available;
}

/// Deterministic local sunrise — **location-aware, season-aware, timezone-aware**.
///
/// Implements the standard "Sunrise/Sunset Algorithm" (Almanac, official zenith
/// 90.833°). Pure math, no I/O, no clock: same inputs → same output. This is what
/// lets the Thai layer find the real day boundary instead of a hardcoded 06:00.
abstract final class SunriseCalculator {
  static const double _officialZenith = 90.833;

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

  static int dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(start).inDays + 1;
  }

  /// Local sunrise for [date] at [latitude]/[longitude] (degrees, east positive)
  /// expressed in the zone described by [utcOffset].
  static SunriseCalculation localSunrise({
    required DateTime date,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
  }) {
    final n = dayOfYear(date);
    final lngHour = longitude / 15.0;

    // Approximate time (rising).
    final t = n + ((6.0 - lngHour) / 24.0);

    // Sun's mean anomaly.
    final m = (0.9856 * t) - 3.289;

    // Sun's true longitude.
    var l = m +
        (1.916 * math.sin(_rad(m))) +
        (0.020 * math.sin(_rad(2 * m))) +
        282.634;
    l = _normDeg(l);

    // Sun's right ascension, put into the same quadrant as L.
    var ra = _deg(math.atan(0.91764 * math.tan(_rad(l))));
    ra = _normDeg(ra);
    final lQuadrant = (l / 90.0).floor() * 90.0;
    final raQuadrant = (ra / 90.0).floor() * 90.0;
    ra = ra + (lQuadrant - raQuadrant);
    ra = ra / 15.0;

    // Sun's declination.
    final sinDec = 0.39782 * math.sin(_rad(l));
    final cosDec = math.cos(math.asin(sinDec));

    // Local hour angle.
    final cosH = (math.cos(_rad(_officialZenith)) -
            (sinDec * math.sin(_rad(latitude)))) /
        (cosDec * math.cos(_rad(latitude)));

    if (cosH > 1 || cosH < -1) {
      // The sun never rises (or never sets) at this latitude on this date.
      return SunriseCalculation(
        localSunrise: DateTime(date.year, date.month, date.day, 6),
        available: false,
      );
    }

    var h = 360.0 - _deg(math.acos(cosH)); // sunrise branch
    h = h / 15.0;

    final localMeanTime = h + ra - (0.06571 * t) - 6.622;
    final utHours = _normHours(localMeanTime - lngHour);
    final localHours = _normHours(utHours + (utcOffset.inMinutes / 60.0));

    final hour = localHours.floor();
    final minuteDouble = (localHours - hour) * 60.0;
    final minute = minuteDouble.floor();
    final second = ((minuteDouble - minute) * 60.0).round().clamp(0, 59);

    return SunriseCalculation(
      localSunrise:
          DateTime(date.year, date.month, date.day, hour, minute, second),
      available: true,
    );
  }
}
