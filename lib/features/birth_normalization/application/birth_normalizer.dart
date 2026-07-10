import '../domain/birth_calendar.dart';
import '../domain/birth_location.dart';
import '../domain/birth_normalization_reason.dart';
import '../domain/birth_normalization_result.dart';
import '../domain/normalized_birth.dart';
import '../domain/raw_birth_input.dart';
import 'adapters/bazi_birth_adapter.dart';
import 'adapters/thai_birth_adapter.dart';
import 'adapters/western_birth_adapter.dart';
import 'birth_location_resolver.dart';
import 'birth_time_zone_resolver.dart';
import 'sunrise_calculator.dart';

/// The single, deterministic entry point that turns [RawBirthInput] into a
/// [NormalizedBirth] for every astrology system.
///
/// This layer sits **before** every engine. Pure: same input → same output.
abstract final class BirthNormalizer {
  /// Default noon-of-day used when no birth time is provided (noon is after
  /// sunrise everywhere outside the polar regions, so Thai resolves to the same
  /// day — the safe default).
  static const int _assumedHour = 12;

  static BirthNormalizationResult normalize(RawBirthInput input) {
    final reasons = <BirthNormalizationReason>[];

    final location = BirthLocationResolver.resolve(input);
    switch (location.source) {
      case BirthLocationSource.explicit:
        reasons.add(BirthNormalizationReason.locationFromExplicitCoordinates);
        break;
      case BirthLocationSource.resolvedFromProvince:
        reasons.add(BirthNormalizationReason.locationResolvedFromProvince);
        break;
      case BirthLocationSource.resolvedFromCountry:
        reasons.add(BirthNormalizationReason.locationResolvedFromCountry);
        break;
      case BirthLocationSource.defaulted:
        reasons.add(BirthNormalizationReason.locationDefaultedToBangkok);
        break;
    }

    final timeZone = BirthTimeZoneResolver.resolve(input.timeZoneId);
    final tzId = input.timeZoneId?.trim() ?? '';
    if (tzId.isEmpty || !timeZone.resolved || timeZone.id != tzId) {
      reasons.add(BirthNormalizationReason.timeZoneDefaultedToBangkok);
    } else {
      reasons.add(BirthNormalizationReason.timeZoneResolved);
    }

    final hasBirthTime = input.hasBirthTime;
    final hour = hasBirthTime ? input.birthHour! : _assumedHour;
    final minute = hasBirthTime ? input.birthMinute : 0;
    reasons.add(hasBirthTime
        ? BirthNormalizationReason.birthTimeProvided
        : BirthNormalizationReason.birthTimeMissingNoonAssumed);

    final localDateTime = DateTime(
      input.birthDate.year,
      input.birthDate.month,
      input.birthDate.day,
      hour,
      minute,
    );

    final sunrise = SunriseCalculator.localSunrise(
      date: localDateTime,
      latitude: location.latitude,
      longitude: location.longitude,
      utcOffset: timeZone.utcOffset,
    );

    final thai = ThaiBirthAdapter.build(
      localDateTime: localDateTime,
      sunrise: sunrise,
      location: location,
      timeZone: timeZone,
      hasBirthTime: hasBirthTime,
    );

    if (!sunrise.available) {
      reasons.add(BirthNormalizationReason.sunriseUnavailableNoShift);
    } else if (thai.bornBeforeSunrise) {
      reasons.add(BirthNormalizationReason.bornBeforeLocalSunrise);
    } else {
      reasons.add(BirthNormalizationReason.bornAfterLocalSunrise);
    }

    final western = WesternBirthAdapter.build(
      localDateTime: localDateTime,
      location: location,
      timeZone: timeZone,
      hasBirthTime: hasBirthTime,
    );
    reasons.add(BirthNormalizationReason.westernUsesExactInstant);

    final bazi = BaZiBirthAdapter.build(
      localDateTime: localDateTime,
      location: location,
      timeZone: timeZone,
    );
    reasons.add(BirthNormalizationReason.baziNotImplemented);

    final normalized = NormalizedBirth(
      raw: input,
      location: location,
      timeZone: timeZone,
      calendar: BirthCalendar.gregorian,
      sunrise: sunrise.localSunrise,
      sunriseAvailable: sunrise.available,
      thai: thai,
      western: western,
      bazi: bazi,
      reasons: List.unmodifiable(reasons),
    );

    return BirthNormalizationResult.success(normalized);
  }

  /// Convenience: normalize directly from a Firestore profile map.
  static BirthNormalizationResult normalizeProfileMap(
    Map<String, dynamic> profile,
  ) {
    final input = RawBirthInput.fromProfileMap(profile);
    if (input == null) {
      return BirthNormalizationResult.invalid(
        'Profile has no parseable birth date.',
      );
    }
    return normalize(input);
  }
}
