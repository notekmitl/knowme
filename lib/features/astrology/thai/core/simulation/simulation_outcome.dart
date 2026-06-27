import 'package:knowme/features/astrology/thai/core/decision/decision_action.dart';

import 'simulation_confidence.dart';
import 'simulation_evidence.dart';
import 'simulation_impact.dart';
import 'simulation_option.dart';
import 'simulation_tradeoff.dart';
import 'simulation_window.dart';

/// V14 — the full evaluated result for one [SimulationOption].
///
/// Bundles everything the spec asks per path: the [expected] outcome, the
/// potential [opportunity] and [risk], the [tradeoffs], the [timing], the
/// [confidence] and the supporting [evidence]. [action] is the underlying V11
/// verdict the path would take (null for Do Nothing). Evidence only — no copy.
class SimulationOutcome {
  const SimulationOutcome({
    required this.option,
    required this.expected,
    required this.opportunity,
    required this.risk,
    required this.tradeoffs,
    required this.timing,
    required this.confidence,
    required this.evidence,
    required this.action,
  });

  final SimulationOption option;

  final SimulationImpact expected;
  final SimulationImpact? opportunity;
  final SimulationImpact? risk;

  final List<SimulationTradeoff> tradeoffs;
  final SimulationWindow? timing;

  final SimulationConfidence confidence;
  final List<SimulationEvidence> evidence;

  /// The underlying V11 action this path would take (null for Do Nothing).
  final DecisionAction? action;
}
