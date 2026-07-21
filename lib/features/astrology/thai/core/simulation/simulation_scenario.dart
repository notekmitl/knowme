import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';

/// V14 — the seven life areas the Scenario Simulation engine can simulate
/// (Supported V1). Each routes 1:1 onto a V11 [DecisionScenario] so the
/// simulation never re-derives decision logic — it drives the V13 runtime.
enum SimulationScenario {
  career,
  investment,
  business,
  marriage,
  relationship,
  relocation,
  education,
}

extension SimulationScenarioMapping on SimulationScenario {
  /// The V11 decision scenario this simulation drives through the runtime.
  DecisionScenario get decisionScenario {
    switch (this) {
      case SimulationScenario.career:
        return DecisionScenario.careerChange;
      case SimulationScenario.investment:
        return DecisionScenario.investment;
      case SimulationScenario.business:
        return DecisionScenario.businessStart;
      case SimulationScenario.marriage:
        return DecisionScenario.marriage;
      case SimulationScenario.relationship:
        return DecisionScenario.relationship;
      case SimulationScenario.relocation:
        return DecisionScenario.relocation;
      case SimulationScenario.education:
        return DecisionScenario.education;
    }
  }
}
