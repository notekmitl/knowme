/// Resolved Thai lunar inputs for 4-row seven-number chart (พรหมชาติ standard).
class ThaiLunarDate {
  const ThaiLunarDate({
    required this.weekdayNumber,
    required this.lunarMonthNumber,
    required this.zodiacYearIndex,
    this.source = ThaiLunarDateSource.verifiedLookup,
  });

  /// Thai weekday: อาทิตย์=1 … เสาร์=7.
  final int weekdayNumber;

  /// Lunar month number 1–12 (ธันวา=1 per พรหมชาติ).
  final int lunarMonthNumber;

  /// Zodiac year index 1–12 (ชวด=1 … กุน=12).
  final int zodiacYearIndex;

  final ThaiLunarDateSource source;
}

enum ThaiLunarDateSource {
  verifiedLookup,
  explicitInput,

  /// Future: row from embedded ปฏิทิน dataset asset.
  embeddedDataset,

  /// Future: computed from licensed calendar algorithm.
  generated,
}

/// Explicit chart inputs — used by golden-case tests and direct API callers.
class ThaiLunarChartInput {
  const ThaiLunarChartInput({
    required this.weekdayNumber,
    required this.lunarMonthNumber,
    required this.zodiacYearIndex,
  });

  final int weekdayNumber;
  final int lunarMonthNumber;
  final int zodiacYearIndex;

  ThaiLunarDate toLunarDate() {
    return ThaiLunarDate(
      weekdayNumber: weekdayNumber,
      lunarMonthNumber: lunarMonthNumber,
      zodiacYearIndex: zodiacYearIndex,
      source: ThaiLunarDateSource.explicitInput,
    );
  }
}
