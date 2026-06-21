import '../lunar/providers/thai_lunar_calendar_provider.dart';
import '../models/profile_warning.dart';
import '../models/thai_birth_data.dart';
import 'thai_lunar_date.dart';

/// Result of Gregorian → Thai lunar resolution.
class ThaiLunarResolution {
  const ThaiLunarResolution({
    this.lunarDate,
    this.warnings = const [],
  });

  final ThaiLunarDate? lunarDate;
  final List<ProfileWarning> warnings;

  bool get isResolved => lunarDate != null;
}

/// Gregorian → Thai lunar mapping layer.
///
/// Delegates to [ThaiLunarCalendarProvider] / [ThaiLunarRepository].
/// Full ปฏิทิน 100/150 ปี dataset is TODO — see [ThaiLunarCalendarOpenQuestions].
abstract final class ThaiLunarCalendar {
  static final ThaiLunarCalendarProvider _provider =
      ThaiLunarCalendarProvider();

  /// Override for tests — inject custom repository.
  static ThaiLunarCalendarProvider get provider => _provider;

  static ThaiLunarResolution resolve(ThaiBirthData birthData) {
    final result = _provider.resolve(birthData);
    return ThaiLunarResolution(
      lunarDate: result.lunarDate,
      warnings: result.warnings,
    );
  }
}

/// Open questions for lunar calendar layer.
abstract final class ThaiLunarCalendarOpenQuestions {
  static const fullCalendarAlgorithm =
      'TODO: Populate embedded ปฏิทิน 100/150 ปี dataset (see lunar/datasets/)';
  static const intercalaryMonth8 =
      'TODO OQ-LUNAR-8: เดือน 8 สองหน handling per horawej';
  static const weekdayFromHundredYearCalendar =
      'TODO: Weekday for row-1 must come from Thai 100-year calendar, '
      'not Dart DateTime.weekday alone';
  static const yearBoundaryWaxingDay =
      'TODO: Apply ขึ้น 1 ค่ำ เดือน 5 boundary using waxing-day data';
}
