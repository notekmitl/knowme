import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'transit_assessment.dart';
import 'transit_context.dart';
import 'transit_event.dart';
import 'transit_evidence.dart';
import 'transit_impact.dart';
import 'transit_influence.dart';
import 'transit_signal.dart';
import 'transit_window.dart';

/// V15 — Transit Intelligence engine.
///
/// Deterministically evaluates the **current transit** and converts it into
/// evidence. The transiting planet is the Thai day-of-week ruler of the
/// evaluation date (a genuine calendar signal the age/period pipeline does not
/// capture); the engine assesses it against the natal ruler and the current
/// life-period planet using the shared V9 relationship logic (reused, not
/// duplicated).
///
/// Transit **only contributes evidence** — it never decides, predicts or
/// answers, and it never bypasses the runtime: its [TransitContext] is derived
/// from a runtime response. Pure, deterministic, evidence only: no AI, no Thai
/// copy, no presenter, no UI, no Firestore.
abstract final class TransitIntelligenceEngine {
  /// Magnitude per relationship-score step (score is −3..+3).
  static const int scorePerStep = 15;

  static TransitAssessment evaluate(TransitContext context) {
    final dayRuler = LifePlanets.rulerForWeekday(context.asOf.weekday);
    final day = DateTime(
      context.asOf.year,
      context.asOf.month,
      context.asOf.day,
    );
    final window = TransitWindow(start: day, end: day, ruler: dayRuler);

    final events = <TransitEvent>[
      TransitEvent(
        kind: TransitEventKind.dayVersusNatal,
        signal: TransitSignal.between(dayRuler, context.natalRuler),
        window: window,
      ),
      TransitEvent(
        kind: TransitEventKind.dayVersusPeriod,
        signal: TransitSignal.between(dayRuler, context.currentPlanet),
        window: window,
      ),
    ];

    final influences = [for (final e in events) _influence(e)];
    final evidence = [for (final e in events) _evidence(e)];
    final net = influences.fold<int>(0, (sum, i) => sum + i.magnitude);

    return TransitAssessment(
      events: events,
      influences: influences,
      impact: TransitImpact.fromNet(net),
      evidence: evidence,
      window: window,
    );
  }

  static TransitInfluence _influence(TransitEvent event) => TransitInfluence(
        source: event.kind,
        domain: _leadingDomain(event.signal.transiting),
        magnitude: event.signal.score * scorePerStep,
      );

  static TransitEvidence _evidence(TransitEvent event) => TransitEvidence(
        sourceName: _sourceName(event.kind),
        magnitude: event.signal.score * scorePerStep,
        domain: _leadingDomain(event.signal.transiting),
        planet: event.signal.transiting,
      );

  /// The transiting planet's strongest supportive domain (its intrinsic focus).
  static LifeDomain _leadingDomain(LifePlanet planet) =>
      LifePlanets.of(planet).affinity.supportRanked.first;

  static String _sourceName(TransitEventKind kind) => switch (kind) {
        TransitEventKind.dayVersusNatal => 'transitDayVsNatal',
        TransitEventKind.dayVersusPeriod => 'transitDayVsPeriod',
      };
}
