/// Coarse confidence band for a simulated option.
enum SimulationConfidenceBand { low, moderate, high }

/// V14 — how well-supported a simulated option is (0–100). Carried straight
/// from the runtime's confidence for that evaluation. Evidence only.
class SimulationConfidence {
  const SimulationConfidence({required this.value});

  final int value;

  SimulationConfidenceBand get band {
    if (value >= 67) return SimulationConfidenceBand.high;
    if (value >= 40) return SimulationConfidenceBand.moderate;
    return SimulationConfidenceBand.low;
  }
}
