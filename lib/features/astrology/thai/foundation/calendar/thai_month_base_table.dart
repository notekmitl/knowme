/// Lunar month → month-base mapping (พรหมชาติ paired-month table).
///
/// See THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md § OQ-2.
abstract final class ThaiMonthBaseTable {
  /// Returns month base number 1–7 from lunar month 1–12.
  static int monthBaseFromLunarMonth(int lunarMonthNumber) {
    if (lunarMonthNumber < 1 || lunarMonthNumber > 12) {
      throw ArgumentError.value(
        lunarMonthNumber,
        'lunarMonthNumber',
        'must be between 1 and 12',
      );
    }
    if (lunarMonthNumber > 7) {
      return lunarMonthNumber - 7;
    }
    return lunarMonthNumber;
  }

  /// Builds row-2 rotated sequence starting with [monthBase].
  static List<int> rowFromMonthBase(int monthBase) {
    return _rotationFromStart(monthBase);
  }

  static List<int> rowFromLunarMonth(int lunarMonthNumber) {
    return rowFromMonthBase(monthBaseFromLunarMonth(lunarMonthNumber));
  }

  static List<int> _rotationFromStart(int start) {
    return List<int>.generate(7, (index) {
      return ((start - 1 + index) % 7) + 1;
    });
  }
}
