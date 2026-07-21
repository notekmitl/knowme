import 'simulation_outcome.dart';

/// V14 — the deterministic comparison across all four simulated options.
///
/// [ranked] is best→worst by expected outcome (then confidence, then a stable
/// option order). [best] / [worst] are its ends; [doNothing] is the status-quo
/// baseline; [valueOfActing] is `best.expected − doNothing.expected` — the net
/// gain of the best path over inaction. Evidence only.
class SimulationComparison {
  const SimulationComparison({
    required this.ranked,
    required this.best,
    required this.worst,
    required this.doNothing,
    required this.valueOfActing,
  });

  final List<SimulationOutcome> ranked;
  final SimulationOutcome best;
  final SimulationOutcome worst;
  final SimulationOutcome doNothing;
  final int valueOfActing;
}
