import '../../domain/birth_location.dart';
import '../../domain/birth_time_zone.dart';
import '../../domain/thai_birth_context.dart';
import '../sunrise_calculator.dart';

/// Builds the Thai birth context: applies the **local sunrise** day boundary.
abstract final class ThaiBirthAdapter {
  static ThaiBirthContext build({
    required DateTime localDateTime,
    required SunriseCalculation sunrise,
    required BirthLocation location,
    required BirthTimeZone timeZone,
    required bool hasBirthTime,
  }) {
    final civilDate = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );

    final bornBeforeSunrise =
        sunrise.available && localDateTime.isBefore(sunrise.localSunrise);

    final thaiDate = bornBeforeSunrise
        ? civilDate.subtract(const Duration(days: 1))
        : civilDate;

    return ThaiBirthContext(
      localDateTime: localDateTime,
      localSunrise: sunrise.localSunrise,
      bornBeforeSunrise: bornBeforeSunrise,
      astrologicalDate: thaiDate,
      timeZoneOffset: timeZone.utcOffset,
      latitude: location.latitude,
      longitude: location.longitude,
      hasBirthTime: hasBirthTime,
      sunriseAvailable: sunrise.available,
    );
  }
}
