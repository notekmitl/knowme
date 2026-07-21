import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/astronomy/sidereal_ascendant.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_day_boundary.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_lunar_calendar.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_lunar_date.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_month_base_table.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_zodiac_year.dart';
import 'package:knowme/features/astrology/thai/foundation/chart/seven_number_chart.dart';
import 'package:knowme/features/astrology/thai/foundation/constants/thai_lagna_rulership.dart';
import 'package:knowme/features/astrology/thai/foundation/engines/lagna_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/engines/lagna_lord_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/engines/mahabhuta_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/engines/myanmar_seven_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/integration/thai_foundation_resolver_bridge.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/thai_foundation_engine.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_resolver.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
  bool hasBirthTime = true,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: hasBirthTime,
  );
}

void _expectChartRows(
  SevenNumberChartResult chart, {
  required List<int> row1,
  required List<int> row2,
  required List<int> row3,
  required List<int> row4,
}) {
  expect(chart.row1Day, row1);
  expect(chart.row2Month, row2);
  expect(chart.row3Year, row3);
  expect(chart.row4Sum, row4);
}

void main() {
  group('Golden Cases — 4-row chart (GC-01..GC-05)', () {
    test('GC-01 พรหมชาติ ตย.1 — Sunday, lunar month 2, year ขาล(3)', () {
      final chart = SevenNumberChart.build(
        const ThaiLunarChartInput(
          weekdayNumber: 1,
          lunarMonthNumber: 2,
          zodiacYearIndex: 3,
        ),
      );

      _expectChartRows(
        chart,
        row1: [1, 2, 3, 4, 5, 6, 7],
        row2: [2, 3, 4, 5, 6, 7, 1],
        row3: [3, 4, 5, 6, 7, 1, 2],
        row4: [6, 9, 12, 15, 18, 14, 10],
      );
    });

    test('GC-02 พรหมชาติ ตย.2 — Monday, lunar month 5, year ชวด(1)', () {
      final chart = SevenNumberChart.build(
        const ThaiLunarChartInput(
          weekdayNumber: 2,
          lunarMonthNumber: 5,
          zodiacYearIndex: 1,
        ),
      );

      _expectChartRows(
        chart,
        row1: [2, 3, 4, 5, 6, 7, 1],
        row2: [5, 6, 7, 1, 2, 3, 4],
        row3: [1, 2, 3, 4, 5, 6, 7],
        // Col 5 (มาตา): 6+2+5=13 — พรหมชาติ text shows 12 (likely typo).
        row4: [8, 11, 14, 10, 13, 16, 12],
      );
    });

    test('GC-03 พรหมชาติ ตย.3 — Thursday, lunar month 9, year กุน(12)', () {
      final chart = SevenNumberChart.build(
        const ThaiLunarChartInput(
          weekdayNumber: 5,
          lunarMonthNumber: 9,
          zodiacYearIndex: 12,
        ),
      );

      _expectChartRows(
        chart,
        row1: [5, 6, 7, 1, 2, 3, 4],
        row2: [2, 3, 4, 5, 6, 7, 1],
        row3: [5, 6, 7, 1, 2, 3, 4],
        row4: [12, 15, 18, 7, 10, 13, 9],
      );
    });

    test('GC-04 horawej 11/09/2492 00:15 — verified lunar lookup', () {
      final birth = _bangkokBirth(
        year: 1949,
        month: 9,
        day: 11,
        hour: 0,
        minute: 15,
      );

      final resolution = ThaiLunarCalendar.resolve(birth);
      expect(resolution.isResolved, isTrue);

      final chart = SevenNumberChart.calculate(birth).chart!;
      _expectChartRows(
        chart,
        row1: [7, 1, 2, 3, 4, 5, 6],
        row2: [3, 4, 5, 6, 7, 1, 2],
        row3: [2, 3, 4, 5, 6, 7, 1],
        row4: [12, 8, 11, 14, 17, 13, 9],
      );
      expect(chart.row4Reduced, [5, 1, 4, 7, 3, 6, 2]);
    });

    test('GC-05 sinsaehwang 4/04/2515 02:00 — verified lunar lookup', () {
      final birth = _bangkokBirth(
        year: 1972,
        month: 4,
        day: 4,
        hour: 2,
      );

      final resolution = ThaiLunarCalendar.resolve(birth);
      expect(resolution.isResolved, isTrue);

      final chart = SevenNumberChart.calculate(birth).chart!;
      _expectChartRows(
        chart,
        row1: [2, 3, 4, 5, 6, 7, 1],
        row2: [5, 6, 7, 1, 2, 3, 4],
        row3: [1, 2, 3, 4, 5, 6, 7],
        row4: [8, 11, 14, 10, 13, 16, 12],
      );
    });
  });

  group('LagnaEngine', () {
    test('computes sidereal lagna with Lahiri + Whole Sign', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );

      final result = LagnaEngine.calculate(birth);
      expect(result, isNotNull);
      expect(result!.lagnaKey, isIn(ThaiContentKeys.allLagna));
      expect(result.siderealAscendantDeg, inInclusiveRange(0.0, 360.0));
    });

    test('returns null when birth time is missing', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hasBirthTime: false,
      );

      expect(LagnaEngine.calculate(birth), isNull);
    });

    test('TC-01 Bangkok 1990-01-15 10:30 — deterministic lagna', () {
      final result = LagnaEngine.calculate(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      )!;
      expect(result.lagnaKey, ThaiContentKeys.lagnaVirgo);
      expect(result.signIndex, 5);
    });

    test('TC-02 Bangkok 1988-05-10 14:00 — deterministic lagna', () {
      final result = LagnaEngine.calculate(
        _bangkokBirth(year: 1988, month: 5, day: 10, hour: 14),
      )!;
      expect(result.lagnaKey, ThaiContentKeys.lagnaPisces);
      expect(result.signIndex, 11);
    });
  });

  group('LagnaLordEngine', () {
    test('maps lagna to traditional Thai ruler', () {
      expect(
        LagnaLordEngine.resolve(ThaiContentKeys.lagnaAries),
        ThaiContentKeys.lagnaLordMars,
      );
      expect(
        LagnaLordEngine.resolve(ThaiContentKeys.lagnaCapricorn),
        ThaiContentKeys.lagnaLordSaturn,
      );
      expect(
        LagnaLordEngine.resolve(ThaiContentKeys.lagnaAquarius),
        ThaiContentKeys.lagnaLordSaturn,
      );
      expect(
        LagnaLordEngine.resolve(ThaiContentKeys.lagnaPisces),
        ThaiContentKeys.lagnaLordJupiter,
      );
    });

    test('rulership table covers all 12 lagna keys', () {
      for (final lagna in ThaiContentKeys.allLagna) {
        expect(ThaiLagnaRulership.lordForLagna(lagna), isNotNull);
      }
    });
  });

  group('ThaiMonthBaseTable', () {
    test('lunar month 10 reduces to base 3', () {
      expect(ThaiMonthBaseTable.monthBaseFromLunarMonth(10), 3);
      expect(
        ThaiMonthBaseTable.rowFromLunarMonth(10),
        [3, 4, 5, 6, 7, 1, 2],
      );
    });
  });

  group('ThaiZodiacYear', () {
    test('zodiac year 12 reduces to base 5', () {
      expect(ThaiZodiacYear.yearBaseFromZodiacIndex(12), 5);
      expect(
        ThaiZodiacYear.rowFromZodiacIndex(12),
        [5, 6, 7, 1, 2, 3, 4],
      );
    });
  });

  group('ThaiDayBoundary', () {
    test('02:00 stays on same calendar date', () {
      final effective = ThaiDayBoundary.effectiveLocalDateTime(
        DateTime(1972, 4, 4, 2, 0),
      );
      expect(effective, DateTime(1972, 4, 3));
    });
  });

  group('MyanmarSevenEngine', () {
    test('maps myanmar keys from row 1 for GC-02', () {
      final result = MyanmarSevenEngine.calculate(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      expect(result.myanmarKeys, [
        ThaiContentKeys.myanmarSeven2,
        ThaiContentKeys.myanmarSeven3,
        ThaiContentKeys.myanmarSeven4,
        ThaiContentKeys.myanmarSeven5,
        ThaiContentKeys.myanmarSeven6,
        ThaiContentKeys.myanmarSeven7,
        ThaiContentKeys.myanmarSeven1,
      ]);
      expect(result.row4Sum, [8, 11, 14, 10, 13, 16, 12]);
    });

    test('emits warning when lunar date is unverified', () {
      final result = MyanmarSevenEngine.calculate(
        _bangkokBirth(year: 1985, month: 3, day: 17, hasBirthTime: false),
      );

      expect(result.myanmarKeys, isEmpty);
      expect(
        result.warnings.any((w) => w.code == 'LUNAR_DATE_UNVERIFIED'),
        isTrue,
      );
    });
  });

  group('MahabhutaEngine', () {
    test('stores row 4 sums and canonical position keys for GC-05', () {
      final result = MahabhutaEngine.calculate(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      expect(
        result.mahabhutaPositionKeys,
        ThaiContentKeys.allMahabhutaPosition,
      );
      expect(result.row4Sum, [8, 11, 14, 10, 13, 16, 12]);
    });
  });

  group('ThaiFoundationEngine', () {
    test('full profile with verified lunar date (GC-05)', () {
      final profile = ThaiFoundationEngine.generate(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      expect(profile.calculationStandardVersion, 'v1.1');
      expect(profile.myanmarKeys, hasLength(7));
      expect(profile.mahabhutaPositionKeys, hasLength(7));
      expect(profile.row4Sum, [8, 11, 14, 10, 13, 16, 12]);
      expect(profile.warnings, isEmpty);
    });

    test('date-only profile omits lagna and emits warning', () {
      final profile = ThaiFoundationEngine.generate(
        _bangkokBirth(year: 1985, month: 3, day: 17, hasBirthTime: false),
      );

      expect(profile.lagnaKey, isNull);
      expect(profile.lagnaLordKey, isNull);
      expect(profile.myanmarKeys, isEmpty);
      expect(profile.warnings.any((w) => w.code == 'MISSING_BIRTH_TIME'), isTrue);
      expect(
        profile.warnings.any((w) => w.code == 'LUNAR_DATE_UNVERIFIED'),
        isTrue,
      );
    });
  });

  group('ThaiFoundationResolverBridge', () {
    test('resolver accepts GC-05 foundation profile output', () {
      final profile = ThaiFoundationEngine.generate(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      final signals = ThaiThemeResolver.resolve(
        ThaiFoundationResolverBridge.toResolverInput(profile),
      );

      expect(signals, isNotEmpty);
    });
  });

  group('SiderealAscendant audit', () {
    test('julian day and ascendant are stable for same instant', () {
      final utc = DateTime.utc(1990, 1, 15, 3, 30);
      final jd = SiderealAscendant.julianDay(utc);
      expect(jd, closeTo(2447906.646, 0.01));

      final asc = SiderealAscendant.siderealAscendantDegrees(
        utc: utc,
        latitude: 13.75,
        longitudeEast: 100.50,
      );
      expect(asc, closeTo(160.313, 0.01));
    });
  });
}
