import 'reasoning_capability.dart';
import 'reasoning_module.dart';

/// V17 — a system-agnostic reasoning request.
///
/// It names the target [module] and [capability], carries the common temporal
/// inputs ([birthDate], [asOf]) every system needs, and a free-form
/// [parameters] map for system-specific inputs (the Thai adapter reads
/// `lagnaLord`, `questionIntent`, `scenarioFocus`). The generic runtime never
/// inspects [parameters] — only the resolved provider does — so there is **no
/// hard-coded system dependency** here.
class ReasoningRequest {
  const ReasoningRequest({
    required this.module,
    required this.capability,
    this.birthDate,
    this.asOf,
    this.parameters = const {},
  });

  final ReasoningModule module;
  final ReasoningCapability capability;
  final DateTime? birthDate;
  final DateTime? asOf;
  final Map<String, Object?> parameters;

  ReasoningRequest withCapability(ReasoningCapability capability) =>
      ReasoningRequest(
        module: module,
        capability: capability,
        birthDate: birthDate,
        asOf: asOf,
        parameters: parameters,
      );
}
