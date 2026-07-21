import 'package:knowme/features/astrology/thai/core/decision/decision_tradeoff.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// V14 — a structured tradeoff for a simulated option, projected from the
/// runtime's V11 [DecisionTradeoff]: a [gain] domain weighed against a [cost]
/// domain the same move tends to press on. Evidence only — no copy.
class SimulationTradeoff {
  const SimulationTradeoff({
    required this.gain,
    required this.gainMagnitude,
    required this.cost,
    required this.costMagnitude,
  });

  factory SimulationTradeoff.fromDecision(DecisionTradeoff t) =>
      SimulationTradeoff(
        gain: t.gain,
        gainMagnitude: t.gainMagnitude,
        cost: t.cost,
        costMagnitude: t.costMagnitude,
      );

  final LifeDomain gain;
  final int gainMagnitude;
  final LifeDomain cost;
  final int costMagnitude;

  int get net => gainMagnitude - costMagnitude;
}
