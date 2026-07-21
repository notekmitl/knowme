import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_day_boundary.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_engine_adapter.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';
import 'package:knowme/features/narrative_runtime/integration/user_profile_birth_loader.dart';

/// Thai Astrology — Birth Normalization Migration.
///
/// The Thai engine input ([ThaiBirthData]) is now produced exclusively from a
/// normalized [ThaiBirthContext]. These tests pin the migration seam: the
/// sunrise day boundary, the exact instant preservation, the profile adapter,
/// and the legacy loader regression.
void main() {
  Map<String, dynamic> bangkokProfile({
    required String birthDate,
    String birthTime = '',
    double? latitude,
    double? longitude,
    String timezone = 'Asia/Bangkok',
  }) {
    return {
      'birthDate': birthDate,
      'birthTime': birthTime,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }

  group('ThaiEngineAdapter.fromContext', () {
    test('after sunrise → astrologicalDate is the civil day, instant preserved', () {
      final ctx = BirthNormalizer.normalize(
        RawBirthInput(
          birthDate: DateTime(1990, 6, 15),
          birthHour: 9,
          timeZoneId: 'Asia/Bangkok',
          latitude: 13.75,
          longitude: 100.50,
        ),
      ).birth!.thai;

      final birth = ThaiEngineAdapter.fromContext(ctx);

      expect(birth.localDateTime, DateTime(1990, 6, 15, 9));
      expect(birth.timeZoneOffset, const Duration(hours: 7));
      expect(birth.latitude, 13.75);
      expect(birth.longitude, 100.50);
      expect(birth.hasBirthTime, isTrue);
      expect(birth.astrologicalDate, DateTime(1990, 6, 15));
    });

    test('before sunrise → astrologicalDate is previous day, instant preserved', () {
      final ctx = BirthNormalizer.normalize(
        RawBirthInput(
          birthDate: DateTime(1990, 6, 15),
          birthHour: 3,
          timeZoneId: 'Asia/Bangkok',
          latitude: 13.75,
          longitude: 100.50,
        ),
      ).birth!.thai;

      final birth = ThaiEngineAdapter.fromContext(ctx);

      // Exact instant is unchanged (lagna/astronomy must not shift a day).
      expect(birth.localDateTime, DateTime(1990, 6, 15, 3));
      // Day boundary rolls back to the previous calendar day.
      expect(birth.astrologicalDate, DateTime(1990, 6, 14));
    });

    test('direct construction falls back to dateOnly for astrologicalDate', () {
      final birth = ThaiBirthData(
        localDateTime: DateTime(1972, 4, 4, 2, 0),
        timeZoneOffset: const Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
      );
      expect(birth.astrologicalDate, DateTime(1972, 4, 4));
    });
  });

  group('ThaiEngineAdapter.fromProfileMap', () {
    test('builds engine input from a Bangkok profile', () {
      final birth = ThaiEngineAdapter.fromProfileMap(
        bangkokProfile(
          birthDate: '1990-06-15',
          birthTime: '10:30',
          latitude: 13.75,
          longitude: 100.50,
        ),
      )!;

      expect(birth.localDateTime, DateTime(1990, 6, 15, 10, 30));
      expect(birth.timeZoneOffset, const Duration(hours: 7));
      expect(birth.latitude, 13.75);
      expect(birth.longitude, 100.50);
      expect(birth.hasBirthTime, isTrue);
      expect(birth.astrologicalDate, DateTime(1990, 6, 15));
    });

    test('before-sunrise profile rolls the astrological day back', () {
      final birth = ThaiEngineAdapter.fromProfileMap(
        bangkokProfile(
          birthDate: '1990-06-15',
          birthTime: '03:00',
          latitude: 13.75,
          longitude: 100.50,
        ),
      )!;

      expect(birth.localDateTime, DateTime(1990, 6, 15, 3));
      expect(birth.astrologicalDate, DateTime(1990, 6, 14));
    });

    test('missing birth time → noon assumed, after sunrise', () {
      final birth = ThaiEngineAdapter.fromProfileMap(
        bangkokProfile(birthDate: '1990-06-15'),
      )!;

      expect(birth.hasBirthTime, isFalse);
      expect(birth.localDateTime, DateTime(1990, 6, 15, 12));
      expect(birth.astrologicalDate, DateTime(1990, 6, 15));
    });

    test('returns null when there is no parseable birth date', () {
      expect(
        ThaiEngineAdapter.fromProfileMap(bangkokProfile(birthDate: '')),
        isNull,
      );
    });
  });

  group('UserProfileBirthLoader.fromMap regression', () {
    test('Bangkok profile matches legacy field values (no behaviour change)', () {
      final birth = UserProfileBirthLoader.fromMap(
        bangkokProfile(birthDate: '1990-06-15', birthTime: '10:30'),
      )!;

      // Legacy default Bangkok coordinates + ICT offset are preserved.
      expect(birth.localDateTime, DateTime(1990, 6, 15, 10, 30));
      expect(birth.timeZoneOffset, const Duration(hours: 7));
      expect(birth.latitude, 13.7563);
      expect(birth.longitude, 100.5018);
      expect(birth.hasBirthTime, isTrue);
    });

    test('"unknown" birth time is treated as no time (noon)', () {
      final birth = UserProfileBirthLoader.fromMap(
        bangkokProfile(birthDate: '1990-06-15', birthTime: 'unknown'),
      )!;

      expect(birth.hasBirthTime, isFalse);
      expect(birth.localDateTime, DateTime(1990, 6, 15, 12));
    });
  });

  group('ThaiDayBoundary (deprecated shim) ↔ astrologicalDate', () {
    test('before sunrise stays on the previous calendar date', () {
      expect(
        ThaiDayBoundary.effectiveLocalDateTime(DateTime(1972, 4, 4, 2, 0)),
        DateTime(1972, 4, 3),
      );
    });

    test('after sunrise stays on the same calendar date', () {
      expect(
        ThaiDayBoundary.effectiveLocalDateTime(DateTime(1972, 4, 4, 9, 0)),
        DateTime(1972, 4, 4),
      );
    });

    test('agrees with Birth Normalization astrologicalDate at Bangkok', () {
      for (final hour in [0, 2, 5, 7, 12, 20]) {
        final boundary =
            ThaiDayBoundary.effectiveLocalDateTime(DateTime(1990, 6, 15, hour));
        final normalized = BirthNormalizer.normalize(
          RawBirthInput(
            birthDate: DateTime(1990, 6, 15),
            birthHour: hour,
            timeZoneId: 'Asia/Bangkok',
            latitude: 13.7563,
            longitude: 100.5018,
          ),
        ).birth!.thai.astrologicalDate;
        expect(boundary, normalized, reason: 'hour=$hour');
      }
    });
  });
}
