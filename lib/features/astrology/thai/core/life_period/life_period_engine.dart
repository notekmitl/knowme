import 'life_planet.dart';

/// One life period in the timeline.
///
/// [startAge]/[endAge] are inclusive (1-based). A period of strength 10 starting
/// at age 1 covers ages 1–10. [isCurrent], [progress] and [remainingYears] are
/// only meaningful once the engine is given the person's current age.
class PeriodState {
  const PeriodState({
    required this.index,
    required this.planet,
    required this.startAge,
    required this.endAge,
    required this.strength,
    required this.isCurrent,
    required this.isPast,
    required this.progress,
    required this.remainingYears,
    required this.previousPlanet,
    required this.nextPlanet,
  });

  final int index;
  final LifePlanet planet;
  final int startAge;
  final int endAge;
  final int strength;
  final bool isCurrent;
  final bool isPast;

  /// 0.0–1.0 progress through this period (0 for future, 1 for past).
  final double progress;

  /// Whole years until this period ends (0 unless [isCurrent]).
  final int remainingYears;

  final LifePlanet? previousPlanet;
  final LifePlanet? nextPlanet;

  bool get isFuture => !isCurrent && !isPast;
}

/// The full life timeline derived from a person's chart.
class LifeTimeline {
  const LifeTimeline({
    required this.periods,
    required this.currentAge,
    required this.currentIndex,
    required this.startPlanet,
  });

  final List<PeriodState> periods;
  final int currentAge;

  /// Index into [periods] of the current period (clamped to range).
  final int currentIndex;

  /// The planet the ring began on (the weekday ruler).
  final LifePlanet startPlanet;

  PeriodState get current => periods[currentIndex];
  PeriodState? get previous =>
      currentIndex > 0 ? periods[currentIndex - 1] : null;
  PeriodState? get next =>
      currentIndex < periods.length - 1 ? periods[currentIndex + 1] : null;
}

/// Core Thai astrology — Life Period Engine.
///
/// Builds the lifelong sequence of planetary periods from weekday of birth using
/// the traditional Thai 8-day cycle. The starting planet is the weekday ruler;
/// the order then follows [LifePlanets.ring]; each period lasts the planet's
/// strength in years.
///
/// The engine consumes the canonical birth profile (the birth date already
/// resolved by `CanonicalProfileResolver` upstream) and returns *evidence only*
/// — the [LifeTimeline] of [PeriodState]s. It performs no scoring narrative and
/// produces no user-facing copy; composite scoring and narrative live in their
/// own composers so this engine can be reused by Timeline, Annual/Future
/// Prediction, AI Chat, Compatibility and Fusion.
abstract final class LifePeriodEngine {
  /// Builds the timeline directly from a canonical birth [DateTime]. This is the
  /// preferred entry point: callers pass the birth date that already came from
  /// the canonical profile, never a duplicated birth-data structure.
  static LifeTimeline fromBirthDate(DateTime birthDate, {DateTime? asOf}) {
    return build(
      birthWeekday: birthDate.weekday,
      currentAge: ageFrom(birthDate, asOf: asOf),
    );
  }

  /// Generates all periods covering roughly age 1–[maxAge].
  static LifeTimeline build({
    required int birthWeekday,
    required int currentAge,
    int maxAge = 120,
  }) {
    final startPlanet = LifePlanets.rulerForWeekday(birthWeekday);
    final ring = LifePlanets.ring;
    final startIndex = ring.indexOf(startPlanet);

    final planetsSeq = <LifePlanet>[];
    final raw = <_RawPeriod>[];
    var age = 1;
    var k = 0;
    while (age <= maxAge) {
      final planet = ring[(startIndex + k) % ring.length];
      final strength = LifePlanets.of(planet).strength;
      final start = age;
      final end = age + strength - 1;
      planetsSeq.add(planet);
      raw.add(_RawPeriod(planet, start, end, strength));
      age = end + 1;
      k++;
    }

    final effectiveAge = currentAge < 1 ? 1 : currentAge;
    var currentIndex = raw.indexWhere(
      (p) => effectiveAge >= p.start && effectiveAge <= p.end,
    );
    if (currentIndex < 0) {
      currentIndex = effectiveAge < raw.first.start ? 0 : raw.length - 1;
    }

    final periods = <PeriodState>[];
    for (var i = 0; i < raw.length; i++) {
      final p = raw[i];
      final isCurrent = i == currentIndex;
      final isPast = i < currentIndex;
      double progress;
      int remaining;
      if (isCurrent) {
        final into = (effectiveAge - p.start + 1).clamp(0, p.strength);
        progress = (into / p.strength).clamp(0.0, 1.0);
        remaining = (p.end - effectiveAge).clamp(0, p.strength);
      } else if (isPast) {
        progress = 1.0;
        remaining = 0;
      } else {
        progress = 0.0;
        remaining = 0;
      }
      periods.add(
        PeriodState(
          index: i,
          planet: p.planet,
          startAge: p.start,
          endAge: p.end,
          strength: p.strength,
          isCurrent: isCurrent,
          isPast: isPast,
          progress: progress,
          remainingYears: remaining,
          previousPlanet: i > 0 ? raw[i - 1].planet : null,
          nextPlanet: i < raw.length - 1 ? raw[i + 1].planet : null,
        ),
      );
    }

    return LifeTimeline(
      periods: periods,
      currentAge: currentAge,
      currentIndex: currentIndex,
      startPlanet: startPlanet,
    );
  }

  /// Whole-year age from [birthDate] to [asOf] (defaults to now).
  static int ageFrom(DateTime birthDate, {DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    var age = now.year - birthDate.year;
    final hadBirthday = (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) age -= 1;
    return age < 0 ? 0 : age;
  }
}

class _RawPeriod {
  const _RawPeriod(this.planet, this.start, this.end, this.strength);
  final LifePlanet planet;
  final int start;
  final int end;
  final int strength;
}
