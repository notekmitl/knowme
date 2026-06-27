import 'package:knowme/features/astrology/thai/core/decision/decision_recommendation.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';

import 'question_topic.dart';

/// V12 — the resolution of a question [topic] onto a V11 [DecisionScenario] and
/// its computed [recommendation]. This is the bridge between the question layer
/// and the decision layer; it derives nothing new, it only routes. No copy.
class QuestionScenario {
  const QuestionScenario({
    required this.topic,
    required this.scenario,
    required this.recommendation,
  });

  final QuestionTopic topic;
  final DecisionScenario scenario;
  final DecisionRecommendation recommendation;
}
