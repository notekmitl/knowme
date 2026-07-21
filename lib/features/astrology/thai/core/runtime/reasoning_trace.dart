import 'reasoning_evidence.dart';

/// Whether a pipeline stage actually ran for a request.
enum ReasoningStepStatus { ran, skipped }

/// V13 — one stage of the reasoning pipeline as recorded in the [ReasoningTrace].
/// Evidence only: it captures *that* a layer ran (or was skipped), how many
/// outputs it produced and the confidence it contributed — never any copy.
class ReasoningStep {
  const ReasoningStep({
    required this.layer,
    required this.status,
    required this.outputCount,
    required this.confidence,
  });

  final ReasoningLayer layer;
  final ReasoningStepStatus status;

  /// Number of products the layer emitted (periods/predictions/recommendations/
  /// answers). 0 when skipped.
  final int outputCount;

  /// Representative confidence the layer contributed (0 when skipped or n/a).
  final int confidence;

  bool get ran => status == ReasoningStepStatus.ran;
}

/// V13 — the ordered record of which layers ran to produce a response. Always
/// lists all four layers in pipeline order so a consumer can audit the run.
class ReasoningTrace {
  const ReasoningTrace({required this.steps});

  final List<ReasoningStep> steps;

  ReasoningStep stepFor(ReasoningLayer layer) =>
      steps.firstWhere((s) => s.layer == layer);

  List<ReasoningStep> get ranSteps =>
      steps.where((s) => s.ran).toList(growable: false);
}
