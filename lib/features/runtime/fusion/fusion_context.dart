import '../reasoning_capability.dart';
import '../reasoning_module.dart';

/// P2 — a cross-system fusion request.
///
/// Unlike a `ReasoningRequest` (which targets one [ReasoningModule]), a fusion
/// context names a [capability] and is fanned out across **every** provider that
/// supports it (optionally restricted by [modules]). The common temporal inputs
/// and the free-form [parameters] are forwarded to each provider unchanged; each
/// provider reads what it understands. Evidence only — no copy.
class FusionContext {
  const FusionContext({
    required this.capability,
    this.birthDate,
    this.asOf,
    this.parameters = const {},
    this.modules,
  });

  final ReasoningCapability capability;
  final DateTime? birthDate;
  final DateTime? asOf;
  final Map<String, Object?> parameters;

  /// Restrict fusion to these modules; null means every available provider.
  final Set<ReasoningModule>? modules;
}
