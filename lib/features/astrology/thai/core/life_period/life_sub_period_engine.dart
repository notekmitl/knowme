import 'life_planet.dart';

/// One nested planetary sub-period (ดาวแทรก) inside a major life period.
class LifeSubPeriod {
  const LifeSubPeriod({
    required this.index,
    required this.majorPlanet,
    required this.subPlanet,
    required this.durationDays,
    required this.years,
    required this.months,
    required this.days,
  });

  final int index;
  final LifePlanet majorPlanet;
  final LifePlanet subPlanet;

  /// Exact Thai-year days: majorStrength × subStrength × 360 / 108.
  final int durationDays;

  /// Calendar breakdown using 30-day months inside a 360-day Thai year.
  final int years;
  final int months;
  final int days;

  String get thaiLabel =>
      '${LifePlanets.of(subPlanet).thaiName}แทรก${LifePlanets.of(majorPlanet).thaiName}';

  String get durationLabel {
    final parts = <String>[];
    if (years > 0) parts.add('$years ปี');
    if (months > 0) parts.add('$months เดือน');
    if (days > 0) parts.add('$days วัน');
    if (parts.isEmpty) return '0 วัน';
    return parts.join(' ');
  }
}

/// Deterministic ดาวแทรก engine — 8 sub-periods per major period.
///
/// Duration uses planet strengths (กำลัง) with Thai year = 360 days and
/// total strength cycle = 108:
/// `days = majorStrength × subStrength × 360 ÷ 108`.
abstract final class LifeSubPeriodEngine {
  static const thaiYearDays = 360;
  static const totalStrength = 108;
  static const daysPerMonth = 30;

  /// Days for [subPlanet] nested inside [majorPlanet].
  static int durationDays({
    required LifePlanet majorPlanet,
    required LifePlanet subPlanet,
  }) {
    final major = LifePlanets.of(majorPlanet).strength;
    final sub = LifePlanets.of(subPlanet).strength;
    return (major * sub * thaiYearDays) ~/ totalStrength;
  }

  static ({int years, int months, int days}) breakdown(int durationDays) {
    final years = durationDays ~/ thaiYearDays;
    final rem = durationDays % thaiYearDays;
    final months = rem ~/ daysPerMonth;
    final days = rem % daysPerMonth;
    return (years: years, months: months, days: days);
  }

  /// Eight sub-periods starting at [majorPlanet], then following [LifePlanets.ring].
  static List<LifeSubPeriod> forMajor(LifePlanet majorPlanet) {
    final ring = LifePlanets.ring;
    final start = ring.indexOf(majorPlanet);
    final majorStrength = LifePlanets.of(majorPlanet).strength;
    final exactTotal = majorStrength * thaiYearDays;
    final rawDays = <int>[];

    for (var i = 0; i < ring.length; i++) {
      final sub = ring[(start + i) % ring.length];
      rawDays.add(
        durationDays(majorPlanet: majorPlanet, subPlanet: sub),
      );
    }

    // Integer division can drop a few days; pin the last sub-period so the
    // major window stays contiguous and exact.
    final floored = rawDays.fold<int>(0, (a, d) => a + d);
    rawDays[rawDays.length - 1] += exactTotal - floored;

    final out = <LifeSubPeriod>[];
    for (var i = 0; i < ring.length; i++) {
      final sub = ring[(start + i) % ring.length];
      final days = rawDays[i];
      final b = breakdown(days);
      out.add(
        LifeSubPeriod(
          index: i,
          majorPlanet: majorPlanet,
          subPlanet: sub,
          durationDays: days,
          years: b.years,
          months: b.months,
          days: b.days,
        ),
      );
    }
    return out;
  }

  /// Mars nested in Venus — acceptance sample: 1 ปี 6 เดือน 20 วัน.
  static LifeSubPeriod marsInVenusSample() {
    final days = durationDays(
      majorPlanet: LifePlanet.venus,
      subPlanet: LifePlanet.mars,
    );
    final b = breakdown(days);
    return LifeSubPeriod(
      index: 0,
      majorPlanet: LifePlanet.venus,
      subPlanet: LifePlanet.mars,
      durationDays: days,
      years: b.years,
      months: b.months,
      days: b.days,
    );
  }
}
