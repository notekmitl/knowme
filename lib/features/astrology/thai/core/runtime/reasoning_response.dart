import 'reasoning_evidence.dart';
import 'reasoning_request.dart';
import 'reasoning_snapshot.dart';
import 'reasoning_trace.dart';

/// V13 — the unified, public output of the reasoning runtime.
///
/// One stable surface that bundles each layer's snapshot (deeper layers are null
/// when the request did not reach them), the flattened cross-layer [evidence],
/// the [trace] of what ran, and an overall [confidence]. Evidence only — no copy,
/// no presenter. Future consumers read everything they need from here.
class ReasoningResponse {
  const ReasoningResponse({
    required this.depth,
    required this.timeline,
    required this.prediction,
    required this.decision,
    required this.question,
    required this.evidence,
    required this.trace,
    required this.confidence,
  });

  /// How far the pipeline ran for this response.
  final ReasoningDepth depth;

  /// Always present — timeline and prediction always run.
  final TimelineSnapshot timeline;
  final PredictionSnapshot prediction;

  /// Present only when the request reached the decision/question depth.
  final DecisionSnapshot? decision;
  final QuestionSnapshot? question;

  /// Flattened, layer-tagged evidence across every layer that ran.
  final List<ReasoningEvidence> evidence;

  final ReasoningTrace trace;

  /// Overall confidence (0–100), taken from the deepest layer that ran.
  final int confidence;
}
