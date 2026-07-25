import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import 'thai_life_map_v127_weekday_oracle.dart';

/// One deterministic simulated Life Map profile (test-only; not real PII).
class ThaiLifeMapV127Fixture {
  const ThaiLifeMapV127Fixture({
    required this.id,
    required this.category,
    required this.age,
    required this.input,
    required this.referenceAsOf,
    required this.expectedCivilWeekday,
    required this.expectedWednesdayNightRahu,
    required this.expectedLifeStageBandName,
  });

  final String id;
  final ThaiWeekdayCategory category;
  final int age;
  final ThaiBetaInput input;
  final DateTime referenceAsOf;
  final int expectedCivilWeekday;
  final bool expectedWednesdayNightRahu;
  final String expectedLifeStageBandName;
}

/// Frozen reference clock for the 864-core matrix (Asia/Bangkok local wall time).
///
/// Chosen mid-month so birthday search around Jan 15 stays clear of as-of day.
abstract final class ThaiLifeMapV127ReferenceClock {
  static final DateTime asOf = DateTime(2026, 7, 15, 12, 0);
  static const String timeZoneId = 'Asia/Bangkok';
  static const String provinceTh = 'กรุงเทพมหานคร';
  static const String provinceKey = 'bangkok';
}

/// Builds the deterministic 8 × 108 = 864 core simulated profiles.
abstract final class ThaiLifeMapV127FixtureMatrix {
  static const int coreCount = 864;

  static List<ThaiLifeMapV127Fixture> buildCore() {
    final out = <ThaiLifeMapV127Fixture>[];
    for (final category in ThaiWeekdayCategory.values) {
      for (var age = 1; age <= 108; age++) {
        out.add(_buildOne(category: category, age: age));
      }
    }
    if (out.length != coreCount) {
      throw StateError('Expected $coreCount fixtures, built ${out.length}');
    }
    return List.unmodifiable(out);
  }

  static ThaiLifeMapV127Fixture _buildOne({
    required ThaiWeekdayCategory category,
    required int age,
  }) {
    final asOf = ThaiLifeMapV127ReferenceClock.asOf;
    final birth = _birthFor(category: category, age: age, asOf: asOf);
    final civilLocal = DateTime(
      birth.year,
      birth.month,
      birth.day,
      birth.hour,
      birth.minute,
    );
    final cat = ThaiLifeMapV127WeekdayOracle.categoryForBirth(
      civilLocal: civilLocal,
      latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
      longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
      utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
      hasBirthTime: true,
    );
    if (cat != category) {
      throw StateError(
        'Fixture category mismatch for ${category.id}_age_$age: got ${cat.id}',
      );
    }
    final ageCheck = ThaiLifeMapV127WeekdayOracle.ageYears(
      birthDate: DateTime(birth.year, birth.month, birth.day),
      asOf: asOf,
    );
    // Age may be computed on astrological date in production; for 10:30/22:30
    // Bangkok births after sunrise, astrological date == civil date.
    if (ageCheck != age) {
      throw StateError(
        'Age mismatch for ${category.id}_age_$age: oracle=$ageCheck',
      );
    }

    final id = '${category.id}_age_$age';
    return ThaiLifeMapV127Fixture(
      id: id,
      category: category,
      age: age,
      referenceAsOf: asOf,
      expectedCivilWeekday: category.civilWeekday,
      expectedWednesdayNightRahu: category.isWednesdayNight,
      expectedLifeStageBandName: _bandName(age),
      input: ThaiBetaInput(
        firstName: 'Sim',
        lastName: id,
        birthDate: DateTime(birth.year, birth.month, birth.day),
        birthHour: birth.hour,
        birthMinute: birth.minute,
        province: ThaiLifeMapV127ReferenceClock.provinceTh,
        provinceKey: ThaiLifeMapV127ReferenceClock.provinceKey,
        gender: 'ไม่ระบุ',
      ),
    );
  }

  /// Birth month/day fixed at Jan 15 (birthday already passed by Jul 15 as-of).
  /// Hour: 10:30 for daytime categories; 22:30 for Wednesday night.
  static ({int year, int month, int day, int hour, int minute}) _birthFor({
    required ThaiWeekdayCategory category,
    required int age,
    required DateTime asOf,
  }) {
    final hour = category.isWednesdayNight ? 22 : 10;
    final minute = 30;
    final year = asOf.year - age;
    // Search ±14 days around Jan 15 for the target civil weekday.
    const month = 1;
    const anchorDay = 15;
    for (var delta = 0; delta <= 14; delta++) {
      for (final sign in [0, -1, 1]) {
        if (delta == 0 && sign != 0) continue;
        if (delta > 0 && sign == 0) continue;
        final day = anchorDay + (sign * delta);
        if (day < 1 ||
            day > ThaiLifeMapV127WeekdayOracle.daysInMonth(year, month)) {
          continue;
        }
        final wd = ThaiLifeMapV127WeekdayOracle.civilWeekday(year, month, day);
        if (wd != category.civilWeekday) continue;
        final civilLocal = DateTime(year, month, day, hour, minute);
        final resolved = ThaiLifeMapV127WeekdayOracle.categoryForBirth(
          civilLocal: civilLocal,
          latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
          longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
          utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
          hasBirthTime: true,
        );
        if (resolved != category) continue;
        final ageCheck = ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(year, month, day),
          asOf: asOf,
        );
        if (ageCheck != age) continue;
        return (year: year, month: month, day: day, hour: hour, minute: minute);
      }
    }
    throw StateError(
      'Unable to place birth for ${category.id} age $age around $year-01-15',
    );
  }

  static String _bandName(int age) {
    if (age <= 6) return 'earlyChildhood';
    if (age <= 12) return 'schoolAge';
    if (age <= 17) return 'teen';
    if (age <= 29) return 'youngAdult';
    if (age <= 49) return 'workingAdult';
    if (age <= 64) return 'midlife';
    return 'elder';
  }
}
