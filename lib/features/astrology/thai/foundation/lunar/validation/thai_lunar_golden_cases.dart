import '../models/thai_lunar_lookup_key.dart';

/// Expected lunar fields for infrastructure regression validation.
class ThaiLunarGoldenCaseExpectation {
  const ThaiLunarGoldenCaseExpectation({
    required this.id,
    required this.lookupKey,
    required this.weekdayNumber,
    required this.lunarMonthNumber,
    required this.zodiacYearIndex,
    required this.citation,
  });

  final String id;
  final ThaiLunarLookupKey lookupKey;
  final int weekdayNumber;
  final int lunarMonthNumber;
  final int zodiacYearIndex;
  final String citation;
}

/// Golden cases with published Thai lunar references (GC-04, GC-05).
abstract final class ThaiLunarGoldenCases {
  static const gc04 = ThaiLunarGoldenCaseExpectation(
    id: 'GC-04',
    lookupKey: ThaiLunarLookupKey(
      year: 1949,
      month: 9,
      day: 11,
      hour: 0,
      minute: 15,
    ),
    weekdayNumber: 7,
    lunarMonthNumber: 10,
    zodiacYearIndex: 2,
    citation: 'horawej.com Id=538981149',
  );

  static const gc05 = ThaiLunarGoldenCaseExpectation(
    id: 'GC-05',
    lookupKey: ThaiLunarLookupKey(
      year: 1972,
      month: 4,
      day: 4,
      hour: 2,
      minute: 0,
    ),
    weekdayNumber: 2,
    lunarMonthNumber: 5,
    zodiacYearIndex: 1,
    citation: 'sinsaehwang.com 4 เม.ย. 2515 02:00',
  );

  static const all = [gc04, gc05];
}
