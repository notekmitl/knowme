import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';

/// How deep the runtime ran the reasoning pipeline. Timeline + Prediction always
/// run; deeper stages are added on demand. Ordered for index comparison.
enum ReasoningDepth { prediction, decision, question }

/// V13 — the single, structured input to the Unified Reasoning Runtime.
///
/// It carries the deterministic chart anchors (birth date, optional lagna lord,
/// optional evaluation date) plus optional foci: a [question] intent (required
/// by `answer`/`question`) and a [scenarioFocus] (to centre `decide`/`evaluate`
/// on one decision scenario). No copy, no parsing — intent objects only.
class ReasoningRequest {
  const ReasoningRequest({
    required this.birthDate,
    this.lagnaLord,
    this.asOf,
    this.question,
    this.scenarioFocus,
  });

  final DateTime birthDate;
  final LifePlanet? lagnaLord;
  final DateTime? asOf;

  /// Optional structured question intent (object, never text).
  final QuestionIntent? question;

  /// Optional decision scenario to centre the response on.
  final DecisionScenario? scenarioFocus;
}
