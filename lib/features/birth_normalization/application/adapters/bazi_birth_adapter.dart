import '../../domain/bazi_birth_context.dart';
import '../../domain/birth_location.dart';
import '../../domain/birth_time_zone.dart';

/// Builds the BaZi birth context — **placeholder only**.
///
/// Real BaZi normalization (true solar time + solar-term month-pillar
/// boundaries) is future work. This adapter only carries the raw instant so the
/// [NormalizedBirth] shape is stable; it performs no BaZi-specific calculation.
abstract final class BaZiBirthAdapter {
  static BaZiBirthContext build({
    required DateTime localDateTime,
    required BirthLocation location,
    required BirthTimeZone timeZone,
  }) {
    return BaZiBirthContext.placeholder(
      localDateTime: localDateTime,
      utcInstant: localDateTime.subtract(timeZone.utcOffset),
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }
}
