import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';

/// V10 — the three prediction horizons.
enum PredictionWindowKind {
  /// The active life-period chapter the person is in now.
  current,

  /// The near-term twelve months.
  next12Months,

  /// The whole of the upcoming life period.
  nextLifePeriod,
}

/// A concrete, computed prediction horizon (an age span). Evidence only — no
/// copy. [available] is false only for [PredictionWindowKind.nextLifePeriod]
/// when the person is already in the final period of the ring.
class PredictionWindow {
  const PredictionWindow({
    required this.kind,
    required this.startAge,
    required this.endAge,
    required this.spanYears,
    required this.spansTransition,
    required this.available,
  });

  final PredictionWindowKind kind;

  /// Inclusive age bounds the window covers.
  final int startAge;
  final int endAge;

  /// Whole-year span of the window (>= 0).
  final int spanYears;

  /// True when the window crosses (or is) a life-period boundary.
  final bool spansTransition;

  /// False only for an unavailable next period (final period of the ring).
  final bool available;

  static const PredictionWindowKind _finalUnavailableKind =
      PredictionWindowKind.nextLifePeriod;
}

/// Deterministic window calculation from V9 evidence.
abstract final class PredictionWindows {
  /// Near-term horizon length, in years.
  static const int near = 1;

  static List<PredictionWindow> forIntelligence(
    LifeTimelineIntelligence intel,
  ) {
    return [
      current(intel),
      next12Months(intel),
      nextLifePeriod(intel),
    ];
  }

  /// The active life-period chapter: from its start to its end.
  static PredictionWindow current(LifeTimelineIntelligence intel) {
    final p = intel.currentAge.period;
    return PredictionWindow(
      kind: PredictionWindowKind.current,
      startAge: p.startAge,
      endAge: p.endAge,
      spanYears: p.endAge - p.startAge,
      spansTransition: false,
      available: true,
    );
  }

  /// The next twelve months from the current age. Flags a transition when the
  /// current period ends within the window.
  static PredictionWindow next12Months(LifeTimelineIntelligence intel) {
    final now = intel.currentAge.currentAge;
    final remaining = intel.currentAge.period.remainingYears;
    return PredictionWindow(
      kind: PredictionWindowKind.next12Months,
      startAge: now,
      endAge: now + near,
      spanYears: near,
      spansTransition: remaining <= near,
      available: true,
    );
  }

  /// The whole upcoming life period. Unavailable in the final period.
  static PredictionWindow nextLifePeriod(LifeTimelineIntelligence intel) {
    final next = intel.futurePreview.nextPeriod;
    if (next == null) {
      final now = intel.currentAge.currentAge;
      return PredictionWindow(
        kind: PredictionWindow._finalUnavailableKind,
        startAge: now,
        endAge: now,
        spanYears: 0,
        spansTransition: false,
        available: false,
      );
    }
    return PredictionWindow(
      kind: PredictionWindowKind.nextLifePeriod,
      startAge: next.startAge,
      endAge: next.endAge,
      spanYears: next.endAge - next.startAge,
      spansTransition: true,
      available: true,
    );
  }
}
