import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/annual_taksa_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_sub_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/mahabhut_planet_position_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';

void main() {
  group('Life Map V1.2.3 — major periods', () {
    test('every weekday yields exactly 8 periods covering ages 1–108', () {
      for (
        var weekday = DateTime.monday;
        weekday <= DateTime.sunday;
        weekday++
      ) {
        final t = LifePeriodEngine.build(
          birthWeekday: weekday,
          currentAge: 30,
          maxAge: LifePeriodEngine.lifeMapMaxAge,
        );
        expect(t.periods, hasLength(8));
        expect(t.periods.first.startAge, 1);
        expect(t.periods.last.endAge, 108);
        var covered = 0;
        for (var i = 0; i < t.periods.length; i++) {
          final p = t.periods[i];
          covered += p.endAge - p.startAge + 1;
          if (i > 0) {
            expect(p.startAge, t.periods[i - 1].endAge + 1);
          }
        }
        expect(covered, 108);
        final planets = t.periods.map((p) => p.planet).toSet();
        expect(planets, hasLength(8));
      }
    });

    test('Wednesday night / Rahu starts the ring at Rahu', () {
      final night = ThaiBirthData(
        localDateTime: DateTime(1972, 4, 5, 22, 30),
        timeZoneOffset: const Duration(hours: 7),
        latitude: 13.7563,
        longitude: 100.5018,
        hasBirthTime: true,
        astrologicalDate: DateTime(1972, 4, 5),
      );
      expect(night.astrologicalDate.weekday, DateTime.wednesday);
      expect(LifePeriodEngine.isWednesdayNightRahu(night), isTrue);
      final t = LifePeriodEngine.fromBirthData(
        night,
        asOf: DateTime(2026, 7, 1),
      );
      expect(t.startPlanet, LifePlanet.rahu);
      expect(t.periods, hasLength(8));
      expect(t.periods.last.endAge, 108);
    });

    test(
      'Wednesday daytime stays Mercury; unknown time never invents Rahu',
      () {
        final day = ThaiBirthData(
          localDateTime: DateTime(1972, 4, 5, 9, 15),
          timeZoneOffset: const Duration(hours: 7),
          latitude: 13.7563,
          longitude: 100.5018,
          hasBirthTime: true,
          astrologicalDate: DateTime(1972, 4, 5),
        );
        expect(LifePeriodEngine.isWednesdayNightRahu(day), isFalse);
        expect(
          LifePeriodEngine.fromBirthData(day).startPlanet,
          LifePlanet.mercury,
        );

        final unknown = ThaiBirthData(
          localDateTime: DateTime(1972, 4, 5, 12),
          timeZoneOffset: const Duration(hours: 7),
          latitude: 13.7563,
          longitude: 100.5018,
          hasBirthTime: false,
          astrologicalDate: DateTime(1972, 4, 5),
        );
        expect(LifePeriodEngine.isWednesdayNightRahu(unknown), isFalse);
      },
    );

    test('before-sunrise birth uses astrological weekday for the ring', () {
      // Civil Thursday 02:00 → astrological Wednesday (sunrise boundary upstream).
      final birth = ThaiBirthData(
        localDateTime: DateTime(1972, 4, 6, 2, 0),
        timeZoneOffset: const Duration(hours: 7),
        latitude: 13.7563,
        longitude: 100.5018,
        hasBirthTime: true,
        astrologicalDate: DateTime(1972, 4, 5),
      );
      expect(birth.astrologicalDate.weekday, DateTime.wednesday);
      expect(LifePeriodEngine.isWednesdayNightRahu(birth), isTrue);
      expect(
        LifePeriodEngine.fromBirthData(birth).startPlanet,
        LifePlanet.rahu,
      );
    });
  });

  group('Life Map V1.2.3 — sub-periods', () {
    test(
      'each major has 8 contiguous sub-periods summing to major Thai days',
      () {
        for (final major in LifePlanets.ring) {
          final subs = LifeSubPeriodEngine.forMajor(major);
          expect(subs, hasLength(8));
          final total = subs.fold<int>(0, (a, s) => a + s.durationDays);
          expect(
            total,
            LifePlanets.of(major).strength * LifeSubPeriodEngine.thaiYearDays,
          );
        }
      },
    );

    test('อังคารแทรกศุกร์ = 1 ปี 6 เดือน 20 วัน', () {
      final sample = LifeSubPeriodEngine.marsInVenusSample();
      expect(sample.durationDays, 560);
      expect(sample.years, 1);
      expect(sample.months, 6);
      expect(sample.days, 20);
      expect(sample.durationLabel, '1 ปี 6 เดือน 20 วัน');
      expect(sample.thaiLabel, 'ดาวอังคารแทรกดาวศุกร์');
    });
  });

  group('Life Map V1.2.3 — annual Taksa', () {
    test('covers ages 1–108 for every start planet', () {
      for (final start in LifePlanets.ring) {
        final years = AnnualTaksaEngine.build(startPlanet: start);
        expect(years, hasLength(108));
        expect(years.first.age, 1);
        expect(years.last.age, 108);
        expect(years.map((y) => y.age).toSet(), hasLength(108));
      }
    });

    test('อาทิตย์ ๑ is followed by ตากลาง ๙ then จันทร์', () {
      final years = AnnualTaksaEngine.build(startPlanet: LifePlanet.sun);
      expect(years[0].boriwanPlanet, LifePlanet.sun);
      expect(years[0].house, 1);
      expect(years[0].isTagklang, isFalse);
      expect(years[1].isTagklang, isTrue);
      expect(years[1].house, AnnualTaksaEngine.tagklangHouse);
      expect(years[2].boriwanPlanet, LifePlanet.moon);
      expect(years[2].house, 2);
    });

    test('house path follows 1→2→3→4→7→5→8→6 on planet years', () {
      final years = AnnualTaksaEngine.build(startPlanet: LifePlanet.saturn);
      final planetYears = years.where((y) => !y.isTagklang).toList();
      for (var i = 0; i < AnnualTaksaEngine.housePath.length; i++) {
        expect(planetYears[i].house, AnnualTaksaEngine.housePath[i]);
      }
    });

    test('age planet is บริวารจร and roles follow Canon order', () {
      final year = AnnualTaksaEngine.build(startPlanet: LifePlanet.mars).first;
      expect(year.roleByPlanet[LifePlanet.mars], AnnualTaksaRoles.boriwan);
      expect(year.roleByPlanet[LifePlanet.mercury], AnnualTaksaRoles.ayu);
      expect(year.roleByPlanet.values.toList(), AnnualTaksaRoles.ordered);
    });
  });

  group('Life Map V1.2.3 — Mahabhut positions', () {
    test('without Canon evidence stays unknown (no invention)', () {
      final t = LifePeriodEngine.build(
        birthWeekday: DateTime.friday,
        currentAge: 40,
      );
      final pos = MahabhutPlanetPositionEngine.resolve(period: t.periods.first);
      expect(pos.known, isFalse);
      expect(pos.displayLabel, MahabhutPlanetPosition.unknownLabel);
      expect(pos.thaiName, isNull);
    });

    test('Canon labels resolve only for known vocabulary ids', () {
      expect(
        MahabhutPlanetPositionEngine.thaiNameForCanonId(
          'mahabhutPosition.thongchai',
        ),
        'ธงชัย',
      );
      expect(
        MahabhutPlanetPositionEngine.thaiNameForCanonId(
          'mahabhutPosition.racha',
        ),
        'ราชา',
      );
      expect(
        MahabhutPlanetPositionEngine.thaiNameForCanonId(
          'mahabhutPosition.fake',
        ),
        isNull,
      );
    });
  });
}
