import '../../domain/birth_location.dart';
import '../../domain/birth_time_zone.dart';
import '../../domain/western_birth_context.dart';

/// Builds the Western birth context: exact astronomical instant, no day shift.
abstract final class WesternBirthAdapter {
  static WesternBirthContext build({
    required DateTime localDateTime,
    required BirthLocation location,
    required BirthTimeZone timeZone,
    required bool hasBirthTime,
  }) {
    return WesternBirthContext(
      localDateTime: localDateTime,
      utcInstant: localDateTime.subtract(timeZone.utcOffset),
      timeZoneOffset: timeZone.utcOffset,
      latitude: location.latitude,
      longitude: location.longitude,
      hasBirthTime: hasBirthTime,
    );
  }
}
