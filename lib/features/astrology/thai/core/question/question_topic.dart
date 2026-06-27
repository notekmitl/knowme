import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';

/// V12 — the ten life topics a question can be about (Supported Topics V1).
/// Each topic resolves deterministically to exactly one V11 [DecisionScenario],
/// so the question layer never re-reasons — it routes into the decision layer.
enum QuestionTopic {
  career,
  finance,
  investment,
  relationship,
  marriage,
  health,
  education,
  business,
  relocation,
  family,
}

extension QuestionTopicMapping on QuestionTopic {
  /// Stable, documented topic → decision-scenario routing (V1).
  DecisionScenario get scenario => switch (this) {
        QuestionTopic.career => DecisionScenario.careerChange,
        QuestionTopic.finance => DecisionScenario.financialPlanning,
        QuestionTopic.investment => DecisionScenario.investment,
        QuestionTopic.relationship => DecisionScenario.relationship,
        QuestionTopic.marriage => DecisionScenario.marriage,
        QuestionTopic.health => DecisionScenario.healthImprovement,
        QuestionTopic.education => DecisionScenario.education,
        QuestionTopic.business => DecisionScenario.businessStart,
        QuestionTopic.relocation => DecisionScenario.relocation,
        QuestionTopic.family => DecisionScenario.familyPlanning,
      };

  /// All topics in a fixed order (stable iteration for determinism).
  static const List<QuestionTopic> all = QuestionTopic.values;
}
