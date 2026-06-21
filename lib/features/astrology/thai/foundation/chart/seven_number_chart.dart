import '../calendar/thai_lunar_calendar.dart';
import '../calendar/thai_lunar_date.dart';
import '../calendar/thai_month_base_table.dart';
import '../calendar/thai_zodiac_year.dart';
import '../constants/thai_calculation_standards.dart';
import '../models/profile_warning.dart';
import '../models/thai_birth_data.dart';

/// Shared 4-row seven-number chart for Myanmar Seven + Mahabhuta layers.
///
/// Validated standard per THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md:
/// Row 1 (day) + Row 2 (month) + Row 3 (year) → Row 4 vertical sum.
abstract final class SevenNumberChart {
  static const slotCount = 7;

  /// Frozen day-base rotation table (พรหมชาติ).
  static const _dayBaseRotations = <List<int>>[
    [1, 2, 3, 4, 5, 6, 7], // Sunday
    [2, 3, 4, 5, 6, 7, 1], // Monday
    [3, 4, 5, 6, 7, 1, 2], // Tuesday
    [4, 5, 6, 7, 1, 2, 3], // Wednesday
    [5, 6, 7, 1, 2, 3, 4], // Thursday
    [6, 7, 1, 2, 3, 4, 5], // Friday
    [7, 1, 2, 3, 4, 5, 6], // Saturday
  ];

  /// Builds chart from explicit lunar inputs (golden cases, direct API).
  static SevenNumberChartResult build(ThaiLunarChartInput input) {
    return buildFromLunarDate(input.toLunarDate());
  }

  /// Builds chart from resolved [ThaiLunarDate].
  static SevenNumberChartResult buildFromLunarDate(ThaiLunarDate lunar) {
    final weekdayNumber = lunar.weekdayNumber;
    final monthBase = ThaiMonthBaseTable.monthBaseFromLunarMonth(
      lunar.lunarMonthNumber,
    );
    final yearBase = ThaiZodiacYear.yearBaseFromZodiacIndex(
      lunar.zodiacYearIndex,
    );

    final row1Day = List<int>.unmodifiable(
      _dayBaseRotations[weekdayNumber - 1],
    );
    final row2Month = ThaiMonthBaseTable.rowFromLunarMonth(
      lunar.lunarMonthNumber,
    );
    final row3Year = ThaiZodiacYear.rowFromZodiacIndex(lunar.zodiacYearIndex);

    final row4Sum = List<int>.generate(slotCount, (index) {
      return row1Day[index] + row2Month[index] + row3Year[index];
    });

    final row4Reduced = row4Sum.map(reduceSumToSeven).toList(growable: false);

    return SevenNumberChartResult(
      weekdayNumber: weekdayNumber,
      lunarMonthNumber: lunar.lunarMonthNumber,
      zodiacYearIndex: lunar.zodiacYearIndex,
      monthBase: monthBase,
      yearBase: yearBase,
      row1Day: row1Day,
      row2Month: List<int>.unmodifiable(row2Month),
      row3Year: List<int>.unmodifiable(row3Year),
      row4Sum: List<int>.unmodifiable(row4Sum),
      row4Reduced: List<int>.unmodifiable(row4Reduced),
    );
  }

  /// Builds chart from [ThaiBirthData] via [ThaiLunarCalendar].
  static SevenNumberChartResolution calculate(ThaiBirthData birthData) {
    final resolution = ThaiLunarCalendar.resolve(birthData);
    if (resolution.lunarDate == null) {
      return SevenNumberChartResolution(
        warnings: resolution.warnings,
      );
    }

    return SevenNumberChartResolution(
      chart: buildFromLunarDate(resolution.lunarDate!),
      warnings: resolution.warnings,
    );
  }

  /// Reduces row-4 sum to 1–7 by repeated subtraction (horawej auxiliary).
  static int reduceSumToSeven(int sum) {
    var value = sum;
    while (value > 7) {
      value -= 7;
    }
    return value;
  }
}

class SevenNumberChartResolution {
  const SevenNumberChartResolution({
    this.chart,
    this.warnings = const [],
  });

  final SevenNumberChartResult? chart;
  final List<ProfileWarning> warnings;

  bool get hasChart => chart != null;
}

class SevenNumberChartResult {
  const SevenNumberChartResult({
    required this.weekdayNumber,
    required this.lunarMonthNumber,
    required this.zodiacYearIndex,
    required this.monthBase,
    required this.yearBase,
    required this.row1Day,
    required this.row2Month,
    required this.row3Year,
    required this.row4Sum,
    required this.row4Reduced,
  });

  final int weekdayNumber;
  final int lunarMonthNumber;
  final int zodiacYearIndex;
  final int monthBase;
  final int yearBase;

  /// Row 1 — ฐานวัน (อัตตะ … มัชฌิมา).
  final List<int> row1Day;

  /// Row 2 — ฐานเดือน (ตนุ … ปัตนิ).
  final List<int> row2Month;

  /// Row 3 — ฐานปี (มรณะ … ทาสี).
  final List<int> row3Year;

  /// Row 4 — ฐานผลรวม (vertical sum, range 3–21).
  final List<int> row4Sum;

  /// Row 4 reduced to 1–7 (auxiliary, horawej GC-04).
  final List<int> row4Reduced;

  /// Backward-compatible alias for row 1.
  List<int> get dayNumbers => row1Day;

  /// Backward-compatible alias for row 4 sums.
  List<int> get finalNumbers => row4Sum;
}

/// Documents validated chart standard (V1.1).
abstract final class SevenNumberChartStandard {
  static const mergeFormula = 'vertical_sum_row4';
  static const monthBaseSource = 'lunar_month_paired_table';
  static const yearBoundary = 'waxing_1_lunar_month_5';
  static const version = ThaiCalculationStandards.version;
}
