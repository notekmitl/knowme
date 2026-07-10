import 'package:knowme/features/birth_normalization/application/sunrise_calculator.dart';

/// **DEPRECATED — use `ThaiBirthContext.astrologicalDate`** (Birth Normalization).
///
/// The Thai astrological day starts at **local sunrise**. Birth Normalization is
/// now the single source of truth for that boundary: it resolves real location,
/// timezone and sunrise, and exposes the result as
/// `ThaiBirthContext.astrologicalDate`. New code must consume that.
///
/// This shim is retained only for legacy callers and the V1.1 audit test. It no
/// longer hardcodes 06:00 — it delegates to the same [SunriseCalculator] used by
/// Birth Normalization, evaluated at the canonical Bangkok reference point.
abstract final class ThaiDayBoundary {
  static const double _bangkokLatitude = 13.7563;
  static const double _bangkokLongitude = 100.5018;
  static const Duration _ict = Duration(hours: 7);

  /// Returns the date-only Thai astrological day for [localDateTime].
  ///
  /// Births before local sunrise belong to the previous calendar day. Computed
  /// from [SunriseCalculator] (no hardcoded clock time).
  static DateTime effectiveLocalDateTime(DateTime localDateTime) {
    final civilDate = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );

    final sunrise = SunriseCalculator.localSunrise(
      date: localDateTime,
      latitude: _bangkokLatitude,
      longitude: _bangkokLongitude,
      utcOffset: _ict,
    );

    if (sunrise.available && localDateTime.isBefore(sunrise.localSunrise)) {
      return civilDate.subtract(const Duration(days: 1));
    }
    return civilDate;
  }
}
