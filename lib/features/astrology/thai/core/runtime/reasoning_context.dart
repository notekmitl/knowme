import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_result.dart';

/// V13 — the runtime's internal orchestration state: the layer results computed
/// so far for one request. [timeline] and [prediction] are always present;
/// [decision] and [question] are filled only when the request reached that
/// depth. The runtime uses this to assemble the public response; it is not the
/// public surface itself (that is `ReasoningResponse`).
class ReasoningContext {
  const ReasoningContext({
    required this.timeline,
    required this.prediction,
    this.decision,
    this.question,
  });

  final LifeTimelineIntelligence timeline;
  final PredictionIntelligence prediction;
  final DecisionIntelligence? decision;
  final QuestionResult? question;
}
