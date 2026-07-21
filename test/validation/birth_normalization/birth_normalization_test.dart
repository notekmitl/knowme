import 'package:flutter_test/flutter_test.dart';

import 'package:knowme/features/birth_normalization/birth_normalization.dart';

/// Birth Normalization Foundation — the single birth-input layer.
///
/// Sunrise is location-, season-, and timezone-aware (never a hardcoded 06:00),
/// and normalization is fully deterministic.
void main() {
  const bangkokLat = 13.7563;
  const bangkokLng = 100.5018;

  RawBirthInput bangkok(int hour, {int minute = 0, DateTime? date}) =>
      RawBirthInput(
        birthDate: date ?? DateTime(1990, 6, 15),
        birthHour: hour,
        birthMinute: minute,
        latitude: bangkokLat,
        longitude: bangkokLng,
        timeZoneId: 'Asia/Bangkok',
      );

  int minuteOfDay(DateTime t) => t.hour * 60 + t.minute;

  group('sunrise', () {
    test('Bangkok sunrise is a plausible morning time (not hardcoded 06:00)',
        () {
      final r = BirthNormalizer.normalize(bangkok(12)).birth!;
      expect(r.sunriseAvailable, isTrue);
      expect(r.sunrise.hour, inInclusiveRange(5, 7));
      // Not exactly 06:00:00 — it is a real astronomical value.
      final isExactlySix =
          r.sunrise.hour == 6 && r.sunrise.minute == 0 && r.sunrise.second == 0;
      expect(isExactlySix, isFalse);
    });

    test('season-aware: June and December sunrise differ', () {
      final june =
          BirthNormalizer.normalize(bangkok(12, date: DateTime(1990, 6, 21)))
              .birth!;
      final dec =
          BirthNormalizer.normalize(bangkok(12, date: DateTime(1990, 12, 21)))
              .birth!;
      expect(minuteOfDay(june.sunrise),
          isNot(equals(minuteOfDay(dec.sunrise))));
    });

    test('location-aware: different provinces give different sunrise', () {
      final chiangMai = BirthNormalizer.normalize(RawBirthInput(
        birthDate: DateTime(1990, 6, 15),
        birthHour: 12,
        province: 'Chiang Mai',
        timeZoneId: 'Asia/Bangkok',
      )).birth!;
      final phuket = BirthNormalizer.normalize(RawBirthInput(
        birthDate: DateTime(1990, 6, 15),
        birthHour: 12,
        province: 'Phuket',
        timeZoneId: 'Asia/Bangkok',
      )).birth!;
      expect(chiangMai.location.source,
          BirthLocationSource.resolvedFromProvince);
      expect(
          minuteOfDay(chiangMai.sunrise), isNot(minuteOfDay(phuket.sunrise)));
    });

    test('timezone-aware: +08:00 shifts local sunrise ~1h later than +07:00',
        () {
      final ict = BirthNormalizer.normalize(bangkok(12)).birth!;
      final sgt = BirthNormalizer.normalize(RawBirthInput(
        birthDate: DateTime(1990, 6, 15),
        birthHour: 12,
        latitude: bangkokLat,
        longitude: bangkokLng,
        timeZoneId: 'Asia/Singapore',
      )).birth!;
      final delta = minuteOfDay(sgt.sunrise) - minuteOfDay(ict.sunrise);
      expect(delta, inInclusiveRange(58, 62));
    });
  });

  group('Thai day boundary', () {
    test('before local sunrise → previous astrological day', () {
      final r = BirthNormalizer.normalize(bangkok(3)).birth!;
      expect(r.thai.bornBeforeSunrise, isTrue);
      expect(r.thai.astrologicalDate, DateTime(1990, 6, 14));
      expect(r.reasons, contains(BirthNormalizationReason.bornBeforeLocalSunrise));
    });

    test('after local sunrise → same astrological day', () {
      final r = BirthNormalizer.normalize(bangkok(9)).birth!;
      expect(r.thai.bornBeforeSunrise, isFalse);
      expect(r.thai.astrologicalDate, DateTime(1990, 6, 15));
      expect(r.reasons, contains(BirthNormalizationReason.bornAfterLocalSunrise));
    });

    test('no birth time → noon assumed → same day', () {
      final r = BirthNormalizer.normalize(RawBirthInput(
        birthDate: DateTime(1990, 6, 15),
        latitude: bangkokLat,
        longitude: bangkokLng,
        timeZoneId: 'Asia/Bangkok',
      )).birth!;
      expect(r.thai.hasBirthTime, isFalse);
      expect(r.thai.bornBeforeSunrise, isFalse);
      expect(r.thai.astrologicalDate, DateTime(1990, 6, 15));
      expect(r.reasons,
          contains(BirthNormalizationReason.birthTimeMissingNoonAssumed));
    });
  });

  group('Western & BaZi', () {
    test('Western uses exact instant with no day shift', () {
      final r = BirthNormalizer.normalize(bangkok(3)).birth!;
      expect(r.western.localDateTime, DateTime(1990, 6, 15, 3));
      expect(r.western.utcInstant, DateTime(1990, 6, 14, 20)); // 03:00 − 7h
      expect(r.reasons, contains(BirthNormalizationReason.westernUsesExactInstant));
    });

    test('BaZi is a placeholder (not implemented)', () {
      final r = BirthNormalizer.normalize(bangkok(9)).birth!;
      expect(r.bazi.implemented, isFalse);
      expect(r.reasons, contains(BirthNormalizationReason.baziNotImplemented));
    });
  });

  group('resolution & validity', () {
    test('explicit coordinates are preferred', () {
      final r = BirthNormalizer.normalize(bangkok(9)).birth!;
      expect(r.location.source, BirthLocationSource.explicit);
      expect(r.latitude, bangkokLat);
    });

    test('unknown location defaults to Bangkok', () {
      final r = BirthNormalizer.normalize(RawBirthInput(
        birthDate: DateTime(1990, 6, 15),
        birthHour: 9,
        province: 'Atlantis',
        country: 'Nowhere',
        timeZoneId: 'Asia/Bangkok',
      )).birth!;
      expect(r.location.source, BirthLocationSource.defaulted);
      expect(r.latitude, BirthLocationResolver.bangkokLat);
    });

    test('unknown/empty timezone defaults to Bangkok offset', () {
      final r = BirthNormalizer.normalize(RawBirthInput(
        birthDate: DateTime(1990, 6, 15),
        birthHour: 9,
        latitude: bangkokLat,
        longitude: bangkokLng,
      )).birth!;
      expect(r.timeZone.utcOffset, const Duration(hours: 7));
      expect(r.reasons,
          contains(BirthNormalizationReason.timeZoneDefaultedToBangkok));
    });

    test('invalid profile map → invalid result', () {
      final result = BirthNormalizer.normalizeProfileMap({'birthDate': ''});
      expect(result.isValid, isFalse);
      expect(result.birth, isNull);
      expect(result.error, isNotNull);
    });

    test('profile map round-trips through normalization', () {
      final result = BirthNormalizer.normalizeProfileMap({
        'birthDate': '1990-06-15',
        'birthTime': '03:30',
        'birthPlace': 'Bangkok',
        'latitude': bangkokLat,
        'longitude': bangkokLng,
        'timezone': 'Asia/Bangkok',
      });
      expect(result.isValid, isTrue);
      expect(result.birth!.thai.bornBeforeSunrise, isTrue);
    });
  });

  test('determinism: identical input → identical normalization', () {
    final a = BirthNormalizer.normalize(bangkok(3, minute: 15)).birth!;
    final b = BirthNormalizer.normalize(bangkok(3, minute: 15)).birth!;
    expect(a.sunrise, b.sunrise);
    expect(a.thai.astrologicalDate, b.thai.astrologicalDate);
    expect(a.thai.bornBeforeSunrise, b.thai.bornBeforeSunrise);
    expect(a.western.utcInstant, b.western.utcInstant);
    expect(a.reasons, b.reasons);
  });
}
