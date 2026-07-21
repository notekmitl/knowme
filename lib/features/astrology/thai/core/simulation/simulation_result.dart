import 'simulation_comparison.dart';
import 'simulation_confidence.dart';
import 'simulation_outcome.dart';
import 'simulation_scenario.dart';

/// V14 — the aggregate result of simulating one [SimulationScenario].
///
/// [outcomes] holds the four paths in fixed option order (act-now, best window,
/// alternative window, do-nothing); [comparison] ranks them; [confidence] is the
/// confidence of the best path. Evidence only — no copy, no presenter.
class SimulationResult {
  const SimulationResult({
    required this.scenario,
    required this.outcomes,
    required this.comparison,
    required this.confidence,
  });

  final SimulationScenario scenario;
  final List<SimulationOutcome> outcomes;
  final SimulationComparison comparison;
  final SimulationConfidence confidence;
}
