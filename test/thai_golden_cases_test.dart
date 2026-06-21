import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_lunar_calendar.dart';
import 'package:knowme/features/astrology/thai/foundation/calendar/thai_lunar_date.dart';
import 'package:knowme/features/astrology/thai/foundation/chart/seven_number_chart.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/validation/thai_golden_cases.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiBirthData _bangkokBirth(DateTime local) {
  return ThaiBirthData(
    localDateTime: local,
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: true,
  );
}

void main() {
  group('Thai Golden Cases — chart regression (GC-01..GC-20)', () {
    for (final golden in ThaiGoldenCases.all) {
      test('${golden.id} row4 matches published reference', () {
        final SevenNumberChartResult chart;

        if (golden.lookupKey != null) {
          final birth = _bangkokBirth(
            DateTime(
              golden.lookupKey!.year,
              golden.lookupKey!.month,
              golden.lookupKey!.day,
              golden.lookupKey!.hour,
              golden.lookupKey!.minute,
            ),
          );
          final resolution = ThaiLunarCalendar.resolve(birth);
          expect(
            resolution.isResolved,
            isTrue,
            reason: '${golden.id} requires verified lunar lookup',
          );
          expect(resolution.lunarDate!.weekdayNumber, golden.weekdayNumber);
          expect(resolution.lunarDate!.lunarMonthNumber, golden.lunarMonthNumber);
          expect(resolution.lunarDate!.zodiacYearIndex, golden.zodiacYearIndex);
          chart = SevenNumberChart.calculate(birth).chart!;
        } else {
          chart = SevenNumberChart.build(
            ThaiLunarChartInput(
              weekdayNumber: golden.weekdayNumber,
              lunarMonthNumber: golden.lunarMonthNumber,
              zodiacYearIndex: golden.zodiacYearIndex,
            ),
          );
        }

        expect(
          chart.row4Sum,
          golden.expectedRow4,
          reason: '${golden.id} (${golden.source})',
        );
      });
    }
  });

  group('Thai Golden Cases — coverage', () {
    test('at least 20 reference cases', () {
      expect(ThaiGoldenCases.all.length, greaterThanOrEqualTo(20));
    });

    test('boundary tags present across calendar year', () {
      final tags = ThaiGoldenCases.all
          .expand((c) => c.boundaryTags)
          .toSet();

      expect(tags, contains('january'));
      expect(tags, contains('april'));
      expect(tags, contains('june'));
      expect(tags, contains('september'));
      expect(tags, contains('december'));
      expect(tags, contains('zodiac_year_boundary'));
      expect(tags, contains('songkran_season'));
      expect(tags, contains('lunar_month_boundary'));
    });

    test('gregorian cases are subset of verified lunar repository', () {
      final gregorianIds = ThaiGoldenCases.all
          .where((c) => c.lookupKey != null)
          .map((c) => c.id)
          .toList();
      expect(gregorianIds, containsAll(['GC-04', 'GC-05']));
      expect(gregorianIds.length, 2);
    });
  });
}
