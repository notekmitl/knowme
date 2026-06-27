import 'question_answer.dart';
import 'question_evidence.dart';
import 'question_intent.dart';
import 'question_reason.dart';
import 'question_scenario.dart';
import 'question_window.dart';

/// V12 — the full deterministic result of reasoning over one [QuestionIntent].
///
/// Evidence only: it exposes the resolved decision [scenario], the relevant
/// [windows], the relevant [evidence], the [reasons] in priority order, the
/// structured [answer] and the [confidence]. There is no copy anywhere.
class QuestionResult {
  const QuestionResult({
    required this.intent,
    required this.scenario,
    required this.answer,
    required this.windows,
    required this.evidence,
    required this.reasons,
    required this.confidence,
  });

  final QuestionIntent intent;

  /// Topic → V11 `DecisionScenario` resolution (+ the recommendation it routes to).
  final QuestionScenario scenario;

  final QuestionAnswer answer;

  /// Windows relevant to the asked intent (focus / best / worst).
  final List<QuestionWindow> windows;

  /// Evidence relevant to the asked intent, ranked by relevance.
  final List<QuestionEvidence> evidence;

  /// Decision reasons re-ordered by relevance to the asked intent.
  final List<QuestionReason> reasons;

  /// Confidence in the answer (0–100) — the underlying decision confidence.
  final int confidence;

  /// Whether the [confidence] meets the intent's optional minimum.
  bool get meetsConfidence {
    final min = intent.constraint.minConfidence;
    return min == null || confidence >= min;
  }
}
