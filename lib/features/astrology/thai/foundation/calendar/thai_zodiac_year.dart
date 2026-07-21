/// Zodiac year index and year-base mapping (พรหมชาติ paired-year table).
///
/// Year boundary: ขึ้น 1 ค่ำ เดือน 5 (OQ-6). Boundary application requires
/// full lunar date from verified calendar — see [ThaiLunarCalendar].
abstract final class ThaiZodiacYear {
  static const zodiacYearChangeLunarMonth = 5;

  /// Returns year base number 1–7 from zodiac index 1–12.
  static int yearBaseFromZodiacIndex(int zodiacYearIndex) {
    if (zodiacYearIndex < 1 || zodiacYearIndex > 12) {
      throw ArgumentError.value(
        zodiacYearIndex,
        'zodiacYearIndex',
        'must be between 1 and 12',
      );
    }
    if (zodiacYearIndex > 7) {
      return zodiacYearIndex - 7;
    }
    return zodiacYearIndex;
  }

  /// Builds row-3 rotated sequence starting with [yearBase].
  static List<int> rowFromYearBase(int yearBase) {
    return List<int>.generate(7, (index) {
      return ((yearBase - 1 + index) % 7) + 1;
    });
  }

  static List<int> rowFromZodiacIndex(int zodiacYearIndex) {
    return rowFromYearBase(yearBaseFromZodiacIndex(zodiacYearIndex));
  }
}
