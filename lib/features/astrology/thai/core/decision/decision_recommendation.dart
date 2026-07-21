import 'decision_action.dart';
import 'decision_confidence.dart';
import 'decision_evidence.dart';
import 'decision_outcome.dart';
import 'decision_reason.dart';
import 'decision_scenario.dart';
import 'decision_tradeoff.dart';
import 'decision_window.dart';

/// V11 — the full deterministic recommendation for one [DecisionScenario].
///
/// Evidence only: every field is a structured value or code, never copy.
/// It bundles the verdict ([action]), its [confidence], the [reasons] behind it,
/// the [supportingEvidence] / [conflictingEvidence] split, the [bestTiming] /
/// [worstTiming] windows, the [tradeoffs] and the projected [outcome].
class DecisionRecommendation {
  const DecisionRecommendation({
    required this.scenario,
    required this.action,
    required this.confidence,
    required this.reasons,
    required this.supportingEvidence,
    required this.conflictingEvidence,
    required this.bestTiming,
    required this.worstTiming,
    required this.tradeoffs,
    required this.outcome,
  });

  final DecisionScenario scenario;
  final DecisionAction action;
  final DecisionConfidence confidence;

  final List<DecisionReason> reasons;

  final List<DecisionEvidence> supportingEvidence;
  final List<DecisionEvidence> conflictingEvidence;

  final DecisionWindow bestTiming;
  final DecisionWindow worstTiming;

  final List<DecisionTradeoff> tradeoffs;
  final DecisionOutcome outcome;

  /// All evidence atoms (supporting then conflicting) for easy iteration.
  List<DecisionEvidence> get evidence =>
      [...supportingEvidence, ...conflictingEvidence];
}
