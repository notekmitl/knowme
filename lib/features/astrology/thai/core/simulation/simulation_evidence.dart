import 'package:knowme/features/astrology/thai/core/runtime/reasoning_evidence.dart';

import 'simulation_option.dart';

/// V14 — a piece of supporting evidence for a simulated option.
///
/// It wraps a runtime [ReasoningEvidence] atom **unchanged** (identity and
/// signed magnitude preserved) and tags it with the option it supports plus a
/// [relevance] score, so every simulation evidence atom is traceable back
/// through the runtime to its originating layer. Evidence only — no copy.
class SimulationEvidence {
  const SimulationEvidence({
    required this.option,
    required this.atom,
    required this.relevance,
  });

  final SimulationOptionKind option;

  /// The original runtime evidence atom (provenance preserved).
  final ReasoningEvidence atom;

  /// Ranking weight (|magnitude|).
  final int relevance;
}
