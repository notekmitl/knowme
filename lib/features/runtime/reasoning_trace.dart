import 'reasoning_capability.dart';
import 'reasoning_module.dart';

/// One step in a [ReasoningTrace] — a stable [label] and optional [detail], both
/// codes, never copy.
class ReasoningStep {
  const ReasoningStep({required this.label, this.detail});

  final String label;
  final String? detail;
}

/// V17 — a system-agnostic audit of one dispatch: which [module] and
/// [capability] ran, and the ordered [steps] (provider resolution, delegation,
/// aggregation). Evidence only.
class ReasoningTrace {
  const ReasoningTrace({
    required this.module,
    required this.capability,
    this.steps = const [],
  });

  final ReasoningModule module;
  final ReasoningCapability capability;
  final List<ReasoningStep> steps;
}
