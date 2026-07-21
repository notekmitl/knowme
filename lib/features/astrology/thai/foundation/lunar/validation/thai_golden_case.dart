import '../models/thai_lunar_lookup_key.dart';

/// How [expectedRow4] was obtained from the source.
enum ThaiGoldenRow4Source {
  /// Row 4 printed explicitly in the published example.
  published,

  /// Row 4 computed from published rows 1–3 or published inputs via vertical sum.
  arithmeticFromPublishedInputs,
}

/// Single golden reference case for 4-row chart regression.
class ThaiGoldenCase {
  const ThaiGoldenCase({
    required this.id,
    required this.source,
    required this.weekdayNumber,
    required this.lunarMonthNumber,
    required this.zodiacYearIndex,
    required this.expectedRow4,
    required this.row4Source,
    this.birthDate,
    this.lookupKey,
    this.notes = const [],
    this.boundaryTags = const [],
  });

  final String id;
  final String source;

  /// Gregorian civil datetime when published (`null` for chart-input-only cases).
  final DateTime? birthDate;

  /// Exact lookup key when birth time is published.
  final ThaiLunarLookupKey? lookupKey;

  final int weekdayNumber;
  final int lunarMonthNumber;
  final int zodiacYearIndex;
  final List<int> expectedRow4;
  final ThaiGoldenRow4Source row4Source;
  final List<String> notes;
  final List<String> boundaryTags;

  bool get hasGregorianBirth => birthDate != null || lookupKey != null;
}
