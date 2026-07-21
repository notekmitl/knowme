import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_lunar_calendar.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/datasets/thai_lunar_verified_entries.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/models/thai_lunar_dataset_manifest.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/models/thai_lunar_lookup_key.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/providers/thai_lunar_calendar_provider.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/repository/thai_lunar_repository.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/validation/thai_lunar_validator.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiBirthData _birth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: true,
  );
}

void main() {
  group('ThaiLunarRepository', () {
    test('manifest reports golden-cases-only coverage', () {
      final repo = InMemoryThaiLunarRepository();
      expect(repo.manifest.infrastructureVersion, 'v1');
      expect(repo.manifest.coverageStatus, ThaiLunarCoverageStatus.goldenCasesOnly);
      expect(repo.manifest.entryCount, 2);
      expect(repo.manifest.coverageStartGregorian, isNull);
    });

    test('lookup returns GC-04 and GC-05 only', () {
      final repo = InMemoryThaiLunarRepository();

      expect(
        repo.lookup(ThaiLunarVerifiedEntries.gc04Horawej1949.lookupKey),
        isNotNull,
      );
      expect(
        repo.lookup(ThaiLunarVerifiedEntries.gc05Sinsaehwang1972.lookupKey),
        isNotNull,
      );
      expect(
        repo.lookup(const ThaiLunarLookupKey(
          year: 1990,
          month: 1,
          day: 1,
          hour: 12,
          minute: 0,
        )),
        isNull,
      );
    });
  });

  group('ThaiLunarValidator', () {
    test('all golden cases pass against default repository', () {
      final repo = InMemoryThaiLunarRepository();
      expect(ThaiLunarValidator.allGoldenCasesPass(repo), isTrue);

      final results = ThaiLunarValidator.validateGoldenCases(repo);
      expect(results, hasLength(2));
      expect(results.every((r) => r.isPass), isTrue);
    });
  });

  group('ThaiLunarCalendarProvider', () {
    test('resolves verified birth dates', () {
      final provider = ThaiLunarCalendarProvider();
      final gc04 = provider.resolve(_birth(
        year: 1949,
        month: 9,
        day: 11,
        hour: 0,
        minute: 15,
      ));
      expect(gc04.isResolved, isTrue);
      expect(gc04.sourceId, 'GC-04');

      final gc05 = provider.resolve(_birth(
        year: 1972,
        month: 4,
        day: 4,
        hour: 2,
      ));
      expect(gc05.isResolved, isTrue);
      expect(gc05.sourceId, 'GC-05');
    });

    test('unverified date emits LUNAR_DATE_UNVERIFIED', () {
      final provider = ThaiLunarCalendarProvider();
      final result = provider.resolve(_birth(year: 1990, month: 6, day: 15));
      expect(result.isResolved, isFalse);
      expect(result.warnings, hasLength(1));
      expect(result.warnings.first.code, 'LUNAR_DATE_UNVERIFIED');
    });
  });

  group('ThaiLunarCalendar facade', () {
    test('delegates to provider without behaviour change', () {
      final resolution = ThaiLunarCalendar.resolve(_birth(
        year: 1972,
        month: 4,
        day: 4,
        hour: 2,
      ));
      expect(resolution.isResolved, isTrue);
      expect(resolution.lunarDate!.weekdayNumber, 2);
      expect(resolution.lunarDate!.lunarMonthNumber, 5);
      expect(resolution.lunarDate!.zodiacYearIndex, 1);
    });
  });
}
