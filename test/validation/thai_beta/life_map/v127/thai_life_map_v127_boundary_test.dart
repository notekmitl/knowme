import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_engine_adapter.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import 'thai_life_map_v127_fixture_matrix.dart';
import 'thai_life_map_v127_weekday_oracle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    ThaiCanonEvidenceRepository.clearCachedForTest();
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    ThaiCanonEvidenceRepository.bindCachedForTest(repository);
  });

  tearDownAll(ThaiCanonEvidenceRepository.clearCachedForTest);

  group('V1.2.7 Wednesday sunset boundaries', () {
    test('engine exact-second cutoff via ThaiBirthData', () {
      final date = DateTime(1972, 4, 5);
      final sunset = ThaiLifeMapV127WeekdayOracle.localSunset(
        date: date,
        latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
        longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
        utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
      );
      expect(sunset, isNotNull);

      ThaiBirthData birthAt(DateTime local) => ThaiBirthData(
            localDateTime: local,
            timeZoneOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
            latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
            longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
            hasBirthTime: true,
          );

      final before = sunset!.subtract(const Duration(seconds: 1));
      final at = sunset;
      final after = sunset.add(const Duration(seconds: 1));

      expect(LifePeriodEngine.isWednesdayNightRahu(birthAt(before)), isFalse);
      expect(LifePeriodEngine.isWednesdayNightRahu(birthAt(at)), isTrue);
      expect(LifePeriodEngine.isWednesdayNightRahu(birthAt(after)), isTrue);

      expect(
        ThaiLifeMapV127WeekdayOracle.isWednesdayNightRahu(
          civilLocal: before,
          latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
          longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
          utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
          hasBirthTime: true,
        ),
        isFalse,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.isWednesdayNightRahu(
          civilLocal: at,
          latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
          longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
          utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
          hasBirthTime: true,
        ),
        isTrue,
      );
    });

    test('ThaiBeta minute-resolution before/after sunset', () {
      final date = DateTime(1972, 4, 5);
      final sunset = ThaiLifeMapV127WeekdayOracle.localSunset(
        date: date,
        latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
        longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
        utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
      )!;
      // Input path only stores hour:minute (seconds=0). Stay ≥2 minutes clear.
      final before = sunset.subtract(const Duration(minutes: 2));
      final after = sunset.add(const Duration(minutes: 2));

      bool prodNight(DateTime local) {
        final input = ThaiBetaInput(
          firstName: 'Bound',
          lastName: 'Wed',
          birthDate: DateTime(local.year, local.month, local.day),
          birthHour: local.hour,
          birthMinute: local.minute,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        );
        final analysis = ThaiBetaAnalysisRunner.run(
          input,
          asOf: ThaiLifeMapV127ReferenceClock.asOf,
          canonIndex: repository.index,
        );
        final birth = analysis.pipelineResult!.birthData!;
        final oracle = ThaiLifeMapV127WeekdayOracle.isWednesdayNightRahu(
          civilLocal: birth.localDateTime,
          latitude: birth.latitude,
          longitude: birth.longitude,
          utcOffset: birth.timeZoneOffset,
          hasBirthTime: birth.hasBirthTime,
        );
        final prod = LifePeriodEngine.isWednesdayNightRahu(birth);
        expect(prod, oracle);
        return prod;
      }

      expect(prodNight(before), isFalse);
      expect(prodNight(after), isTrue);
    });
  });

  group('V1.2.7 age / calendar boundaries', () {
    test('day before birthday / birthday / day after vs frozen asOf', () {
      final asOf = DateTime(2026, 7, 15);
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 7, 14),
          asOf: asOf,
        ),
        26,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 7, 15),
          asOf: asOf,
        ),
        26,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 7, 16),
          asOf: asOf,
        ),
        25,
      );
    });

    test('year-end / year-start age step', () {
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 12, 31),
          asOf: DateTime(2026, 1, 1),
        ),
        25,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 1, 1),
          asOf: DateTime(2026, 1, 1),
        ),
        26,
      );
    });

    test('Feb 28/29 leap handling', () {
      expect(ThaiLifeMapV127WeekdayOracle.isLeapYear(2000), isTrue);
      expect(ThaiLifeMapV127WeekdayOracle.isLeapYear(1900), isFalse);
      expect(ThaiLifeMapV127WeekdayOracle.daysInMonth(2000, 2), 29);
      expect(ThaiLifeMapV127WeekdayOracle.daysInMonth(1900, 2), 28);
    });

    test('production asOf plumbing ages 1 and 108', () {
      for (final age in [1, 108]) {
        final fixture = ThaiLifeMapV127FixtureMatrix.buildCore().firstWhere(
          (f) => f.category == ThaiWeekdayCategory.monday && f.age == age,
        );
        final analysis = ThaiBetaAnalysisRunner.run(
          fixture.input,
          asOf: fixture.referenceAsOf,
          canonIndex: repository.index,
        );
        expect(analysis.isSuccess, isTrue, reason: fixture.id);
        expect(analysis.pipelineResult!.lifePeriods!.currentAge, age);
      }
    });

    test('pre-sunrise civil Thursday can still be astrological Wednesday', () {
      // Known QA pattern: early morning may roll Thai day back.
      final raw = RawBirthInput(
        birthDate: DateTime(1972, 4, 6), // Thursday civil
        birthHour: 2,
        birthMinute: 0,
        province: 'bangkok',
        placeLabel: 'กรุงเทพมหานคร',
        timeZoneId: 'Asia/Bangkok',
      );
      final birth = BirthNormalizer.normalize(raw).birth!;
      final birthData = ThaiEngineAdapter.fromContext(birth.thai);
      final oracleAstro = ThaiLifeMapV127WeekdayOracle.astrologicalDate(
        civilLocal: birthData.localDateTime,
        latitude: birthData.latitude,
        longitude: birthData.longitude,
        utcOffset: birthData.timeZoneOffset,
      );
      expect(
        DateTime(
          birthData.astrologicalDate.year,
          birthData.astrologicalDate.month,
          birthData.astrologicalDate.day,
        ),
        DateTime(oracleAstro.year, oracleAstro.month, oracleAstro.day),
      );
    });
  });
}
