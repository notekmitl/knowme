import 'reasoning_capability.dart';
import 'reasoning_evidence.dart';
import 'reasoning_module.dart';
import 'reasoning_trace.dart';

/// V17 — a system-agnostic reasoning response.
///
/// Bundles the answering [module]/[capability], the flattened [evidence] (each
/// atom tagged with its module), the [trace] of dispatch and an overall
/// [confidence]. [raw] carries the underlying system response untouched, so a
/// consumer that knows the system (e.g. the Mirror Conversation knowing it asked
/// Thai) can downcast for richer, system-specific data without the generic
/// runtime depending on that system.
class ReasoningResponse {
  const ReasoningResponse({
    required this.module,
    required this.capability,
    required this.evidence,
    required this.trace,
    required this.confidence,
    this.raw,
  });

  final ReasoningModule module;
  final ReasoningCapability capability;
  final List<ReasoningEvidence> evidence;
  final ReasoningTrace trace;
  final int confidence;

  /// The underlying system's native response (opaque to the generic runtime).
  final Object? raw;
}
