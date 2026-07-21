import 'package:knowme/features/astrology/thai/core/decision/decision_evidence.dart';

/// V12 — a decision evidence atom selected and scored for a question intent.
///
/// It wraps the original V11 [DecisionEvidence] atom unchanged (so every piece
/// of question evidence is fully traceable back to the decision layer) and adds
/// a [relevance] score the engine used to rank it for the asked intent.
class QuestionEvidence {
  const QuestionEvidence({
    required this.atom,
    required this.relevance,
  });

  /// The untouched V11 evidence atom (provenance preserved).
  final DecisionEvidence atom;

  /// How relevant this atom is to the question (higher = more relevant).
  final int relevance;
}
