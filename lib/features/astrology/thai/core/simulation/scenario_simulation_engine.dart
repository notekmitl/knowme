import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_window.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_evidence.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart';
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart';

import 'simulation_comparison.dart';
import 'simulation_confidence.dart';
import 'simulation_evidence.dart';
import 'simulation_impact.dart';
import 'simulation_option.dart';
import 'simulation_outcome.dart';
import 'simulation_result.dart';
import 'simulation_scenario.dart';
import 'simulation_tradeoff.dart';
import 'simulation_window.dart';

/// V14 — Scenario Simulation engine.
///
/// Deterministically evaluates hypothetical decision paths for a life scenario:
/// **Act now**, **Act at the best window**, **Act at an alternative window** and
/// **Do nothing**. Each acting path is evaluated by re-querying the V13
/// [ThaiReasoningRuntime] as if the decision were taken at that point in time;
/// Do Nothing is the status-quo baseline. It then compares the paths.
///
/// It consumes the **runtime only** — it never calls the Timeline, Prediction,
/// Decision or Question engines directly — and it is pure, deterministic and
/// evidence only: no AI, no Thai copy, no presenter, no parser, no UI, no
/// Firestore. Transit, Compatibility and AI Conversation consume *this* later.
abstract final class ScenarioSimulationEngine {
  /// Status-quo expected outcome on the 0–100 favourable axis. Aligned with the
  /// V11 thresholds (45 = mixed boundary) so acting beats inaction only when a
  /// path is genuinely above neutral.
  static const int neutralBaseline = 50;

  /// Cap on supporting evidence atoms surfaced per option.
  static const int maxEvidence = 6;

  static SimulationResult simulate({
    required DateTime birthDate,
    required SimulationScenario scenario,
    LifePlanet? lagnaLord,
    DateTime? asOf,
    ThaiReasoningRuntime runtime = const ThaiReasoningRuntime(),
  }) {
    final ds = scenario.decisionScenario;

    final base = runtime.decide(
      ReasoningRequest(
        birthDate: birthDate,
        lagnaLord: lagnaLord,
        asOf: asOf,
        scenarioFocus: ds,
      ),
    );
    final rec = base.decision!.focus;
    final currentAge = base.timeline.currentAge;
    final baseDate = asOf ??
        DateTime(birthDate.year + currentAge, birthDate.month, birthDate.day);

    // Option A — act now (the base evaluation).
    final actNow = _fromResponse(
      kind: SimulationOptionKind.actNow,
      response: base,
      option: SimulationOption(
        kind: SimulationOptionKind.actNow,
        targetAge: currentAge,
        evaluatedAsOf: baseDate,
      ),
      timing: SimulationWindow(
        startAge: currentAge,
        endAge: currentAge,
        favourability: rec.outcome.favourability,
        available: true,
      ),
    );

    // Option B — act at the best timing window.
    final optB = _atWindow(
      runtime: runtime,
      birthDate: birthDate,
      lagnaLord: lagnaLord,
      ds: ds,
      kind: SimulationOptionKind.actAtBestWindow,
      window: rec.bestTiming,
      currentAge: currentAge,
      baseDate: baseDate,
      base: base,
    );

    // Option C — act at the alternative (worst) timing window, for contrast.
    final optC = _atWindow(
      runtime: runtime,
      birthDate: birthDate,
      lagnaLord: lagnaLord,
      ds: ds,
      kind: SimulationOptionKind.actAtAlternativeWindow,
      window: rec.worstTiming,
      currentAge: currentAge,
      baseDate: baseDate,
      base: base,
    );

    // Do Nothing — status quo; its risk is the opportunity cost vs the best path.
    final doNothing = _doNothing(
      base: base,
      acting: [actNow, optB, optC],
      baseDate: baseDate,
    );

    final outcomes = <SimulationOutcome>[actNow, optB, optC, doNothing];
    final comparison = _compare(outcomes, doNothing);

    return SimulationResult(
      scenario: scenario,
      outcomes: outcomes,
      comparison: comparison,
      confidence: comparison.best.confidence,
    );
  }

  // --- Option builders -----------------------------------------------------

  static SimulationOutcome _atWindow({
    required ThaiReasoningRuntime runtime,
    required DateTime birthDate,
    required LifePlanet? lagnaLord,
    required DecisionScenario ds,
    required SimulationOptionKind kind,
    required DecisionWindow window,
    required int currentAge,
    required DateTime baseDate,
    required ReasoningResponse base,
  }) {
    final timing = SimulationWindow.fromDecision(window);

    // Can't act in the past or in an unavailable window → collapse onto the
    // base evaluation (the path is still reported, just at the current point).
    if (!window.available || window.startAge <= currentAge) {
      return _fromResponse(
        kind: kind,
        response: base,
        option: SimulationOption(
          kind: kind,
          targetAge: currentAge,
          evaluatedAsOf: baseDate,
        ),
        timing: timing,
      );
    }

    final date =
        DateTime(birthDate.year + window.startAge, birthDate.month, birthDate.day);
    final response = runtime.decide(
      ReasoningRequest(
        birthDate: birthDate,
        lagnaLord: lagnaLord,
        asOf: date,
        scenarioFocus: ds,
      ),
    );
    return _fromResponse(
      kind: kind,
      response: response,
      option: SimulationOption(
        kind: kind,
        targetAge: window.startAge,
        evaluatedAsOf: date,
      ),
      timing: timing,
    );
  }

  static SimulationOutcome _fromResponse({
    required SimulationOptionKind kind,
    required ReasoningResponse response,
    required SimulationOption option,
    required SimulationWindow? timing,
  }) {
    final rec = response.decision!.focus;
    final out = rec.outcome;

    final opportunity = out.leadingOpportunity == null
        ? null
        : SimulationImpact.favourable(
            out.favourability,
            domain: out.leadingOpportunity,
          );
    final risk = out.leadingRisk == null
        ? null
        : SimulationImpact.risk(
            100 - out.favourability,
            domain: out.leadingRisk,
          );

    return SimulationOutcome(
      option: option,
      expected: SimulationImpact.favourable(out.favourability),
      opportunity: opportunity,
      risk: risk,
      tradeoffs:
          rec.tradeoffs.map(SimulationTradeoff.fromDecision).toList(growable: false),
      timing: timing,
      confidence: SimulationConfidence(value: response.confidence),
      evidence: _evidence(kind, response.evidence),
      action: rec.action,
    );
  }

  static SimulationOutcome _doNothing({
    required ReasoningResponse base,
    required List<SimulationOutcome> acting,
    required DateTime baseDate,
  }) {
    final bestActing = acting.reduce(
      (a, b) => b.expected.score > a.expected.score ? b : a,
    );
    final foregone = bestActing.expected.score - neutralBaseline;
    final risk = (foregone <= 0 || bestActing.opportunity?.domain == null)
        ? null
        : SimulationImpact.risk(foregone, domain: bestActing.opportunity!.domain);

    return SimulationOutcome(
      option: SimulationOption(
        kind: SimulationOptionKind.doNothing,
        targetAge: null,
        evaluatedAsOf: baseDate,
      ),
      expected: SimulationImpact.favourable(neutralBaseline),
      opportunity: null,
      risk: risk,
      tradeoffs: const [],
      timing: null,
      confidence: SimulationConfidence(value: base.confidence),
      evidence: _evidence(SimulationOptionKind.doNothing, base.evidence),
      action: null,
    );
  }

  // --- Evidence & comparison ----------------------------------------------

  static List<SimulationEvidence> _evidence(
    SimulationOptionKind kind,
    List<ReasoningEvidence> atoms,
  ) {
    final sorted = [...atoms]..sort((a, b) {
        final byMag = b.magnitude.abs().compareTo(a.magnitude.abs());
        if (byMag != 0) return byMag;
        final byLayer = a.layer.index.compareTo(b.layer.index);
        if (byLayer != 0) return byLayer;
        return a.sourceName.compareTo(b.sourceName);
      });
    return [
      for (final atom in sorted.take(maxEvidence))
        SimulationEvidence(
          option: kind,
          atom: atom,
          relevance: atom.magnitude.abs(),
        ),
    ];
  }

  static SimulationComparison _compare(
    List<SimulationOutcome> outcomes,
    SimulationOutcome doNothing,
  ) {
    final ranked = [...outcomes]..sort((a, b) {
        final byScore = b.expected.score.compareTo(a.expected.score);
        if (byScore != 0) return byScore;
        final byConf = b.confidence.value.compareTo(a.confidence.value);
        if (byConf != 0) return byConf;
        return a.option.kind.index.compareTo(b.option.kind.index);
      });
    final best = ranked.first;
    final worst = ranked.last;
    return SimulationComparison(
      ranked: ranked,
      best: best,
      worst: worst,
      doNothing: doNothing,
      valueOfActing: best.expected.score - doNothing.expected.score,
    );
  }
}
