import 'package:knowme/features/astrology/thai/core/prediction/prediction_category.dart';

/// V11 — the ten life decisions the Decision Intelligence layer reasons about
/// (Supported Scenarios V1). Each maps onto a weighted blend of V10
/// [PredictionCategory]s, so the decision layer never re-derives category
/// strength — it composes the prediction substrate.
enum DecisionScenario {
  careerChange,
  businessStart,
  investment,
  marriage,
  relationship,
  education,
  relocation,
  healthImprovement,
  financialPlanning,
  familyPlanning,
}

/// One prediction category's contribution to a scenario (weights sum to ~1.0).
/// Deterministic config — no copy.
class ScenarioCategoryWeight {
  const ScenarioCategoryWeight(this.category, this.weight);
  final PredictionCategory category;
  final double weight;
}

/// Tunable, stakes-derived thresholds that shape how cautious a scenario is.
///
/// Higher [stakes] (more irreversible / higher-commitment decisions) make the
/// engine weight risk more and demand a stronger favourable signal before it
/// will say [DecisionAction.shouldAct]. Pure config — fully deterministic.
class DecisionScenarioConfig {
  const DecisionScenarioConfig({
    required this.categories,
    required this.stakes,
  });

  /// The prediction categories (with weights) that compose this scenario.
  final List<ScenarioCategoryWeight> categories;

  /// 1 = low-commitment / reversible … 3 = high-commitment / irreversible.
  final int stakes;

  /// How heavily window risk is subtracted from favourability (percent).
  int get riskWeightPct => switch (stakes) {
        1 => 40,
        2 => 55,
        _ => 70,
      };

  /// Net favourability required at the decisive window to act.
  int get actThreshold => switch (stakes) {
        1 => 50,
        2 => 56,
        _ => 62,
      };

  /// Window risk at/above which the engine leans to avoid (unless net is high).
  int get avoidRisk => switch (stakes) {
        1 => 80,
        2 => 74,
        _ => 68,
      };
}

extension DecisionScenarioMapping on DecisionScenario {
  /// Stable, documented scenario → prediction-category mapping (V1).
  DecisionScenarioConfig get config => switch (this) {
        DecisionScenario.careerChange => const DecisionScenarioConfig(
            stakes: 3,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.career, 0.6),
              ScenarioCategoryWeight(PredictionCategory.finance, 0.25),
              ScenarioCategoryWeight(PredictionCategory.personalGrowth, 0.15),
            ],
          ),
        DecisionScenario.businessStart => const DecisionScenarioConfig(
            stakes: 3,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.career, 0.45),
              ScenarioCategoryWeight(PredictionCategory.finance, 0.4),
              ScenarioCategoryWeight(PredictionCategory.learning, 0.15),
            ],
          ),
        DecisionScenario.investment => const DecisionScenarioConfig(
            stakes: 3,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.finance, 0.7),
              ScenarioCategoryWeight(PredictionCategory.career, 0.3),
            ],
          ),
        DecisionScenario.marriage => const DecisionScenarioConfig(
            stakes: 3,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.relationship, 0.6),
              ScenarioCategoryWeight(PredictionCategory.family, 0.25),
              ScenarioCategoryWeight(PredictionCategory.finance, 0.15),
            ],
          ),
        DecisionScenario.relationship => const DecisionScenarioConfig(
            stakes: 2,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.relationship, 0.7),
              ScenarioCategoryWeight(PredictionCategory.personalGrowth, 0.3),
            ],
          ),
        DecisionScenario.education => const DecisionScenarioConfig(
            stakes: 2,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.learning, 0.6),
              ScenarioCategoryWeight(PredictionCategory.personalGrowth, 0.25),
              ScenarioCategoryWeight(PredictionCategory.career, 0.15),
            ],
          ),
        DecisionScenario.relocation => const DecisionScenarioConfig(
            stakes: 3,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.career, 0.35),
              ScenarioCategoryWeight(PredictionCategory.family, 0.3),
              ScenarioCategoryWeight(PredictionCategory.personalGrowth, 0.2),
              ScenarioCategoryWeight(PredictionCategory.health, 0.15),
            ],
          ),
        DecisionScenario.healthImprovement => const DecisionScenarioConfig(
            stakes: 1,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.health, 0.7),
              ScenarioCategoryWeight(PredictionCategory.personalGrowth, 0.3),
            ],
          ),
        DecisionScenario.financialPlanning => const DecisionScenarioConfig(
            stakes: 2,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.finance, 0.7),
              ScenarioCategoryWeight(PredictionCategory.career, 0.2),
              ScenarioCategoryWeight(PredictionCategory.family, 0.1),
            ],
          ),
        DecisionScenario.familyPlanning => const DecisionScenarioConfig(
            stakes: 3,
            categories: [
              ScenarioCategoryWeight(PredictionCategory.family, 0.5),
              ScenarioCategoryWeight(PredictionCategory.relationship, 0.3),
              ScenarioCategoryWeight(PredictionCategory.finance, 0.2),
            ],
          ),
      };

  /// The dominant prediction category for this scenario (highest weight).
  PredictionCategory get primaryCategory => config.categories.first.category;

  /// All scenarios in a fixed order (stable iteration for determinism).
  static const List<DecisionScenario> all = DecisionScenario.values;
}
