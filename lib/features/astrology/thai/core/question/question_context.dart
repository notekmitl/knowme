import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';

/// V12 — the immutable input the Question Reasoning layer reasons over.
///
/// A thin, read-only adapter over the V11 [DecisionIntelligence] result (which
/// already carries the V10 [PredictionIntelligence] and V9
/// [LifeTimelineIntelligence] beneath it). Keeping the question engine's input
/// behind this context lets future consumers (Transit, Compatibility, Future
/// AI, Voice Assistant) feed the same shape without depending on V11 internals.
class QuestionContext {
  const QuestionContext({required this.decision});

  factory QuestionContext.fromDecision(DecisionIntelligence decision) =>
      QuestionContext(decision: decision);

  final DecisionIntelligence decision;

  // --- Convenience accessors (no derivation, just forwarding) --------------

  PredictionIntelligence get prediction => decision.context.prediction;

  LifeTimelineIntelligence get intelligence => decision.context.intelligence;
}
