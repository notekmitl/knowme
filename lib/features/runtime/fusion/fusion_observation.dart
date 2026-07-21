import '../reasoning_capability.dart';
import '../reasoning_evidence.dart';
import '../reasoning_module.dart';
import '../reasoning_response.dart';

/// P2 — one provider's contribution to a fusion.
///
/// A thin, structured view over a single provider's [ReasoningResponse]: the
/// answering [module], its [confidence] and flattened [evidence]. The native
/// [response] is preserved so a consumer that knows the system (e.g. the Mirror
/// Conversation knowing it asked Thai) can downcast `response.raw` for richer
/// data.
class FusionObservation {
  const FusionObservation({
    required this.module,
    required this.capability,
    required this.confidence,
    required this.evidence,
    required this.response,
  });

  factory FusionObservation.fromResponse(ReasoningResponse response) =>
      FusionObservation(
        module: response.module,
        capability: response.capability,
        confidence: response.confidence,
        evidence: response.evidence,
        response: response,
      );

  final ReasoningModule module;
  final ReasoningCapability capability;
  final int confidence;
  final List<ReasoningEvidence> evidence;
  final ReasoningResponse response;
}
