import 'reasoning_capability.dart';
import 'reasoning_evidence.dart';
import 'reasoning_module.dart';
import 'reasoning_provider.dart';
import 'reasoning_provider_registry.dart';
import 'reasoning_request.dart';
import 'reasoning_response.dart';

/// V17 — the cross-system reasoning runtime.
///
/// Generalizes the Thai reference runtime into a provider-dispatching
/// architecture: it holds a set of [ReasoningProvider]s, detects their
/// capabilities, dispatches a [ReasoningRequest] to the provider that owns the
/// requested [ReasoningModule], and aggregates evidence. It has **no hard-coded
/// system dependency** — providers arrive via the constructor or, by default,
/// via [ReasoningProviderRegistry] discovery.
class ReasoningRuntime {
  const ReasoningRuntime(this._providers);

  /// Builds a runtime from the providers registered in [ReasoningProviderRegistry].
  factory ReasoningRuntime.discover() =>
      ReasoningRuntime(ReasoningProviderRegistry.instance.providers);

  final List<ReasoningProvider> _providers;

  List<ReasoningProvider> get providers => List.unmodifiable(_providers);

  /// The set of modules at least one provider serves.
  Set<ReasoningModule> get modules => {for (final p in _providers) p.module};

  /// The provider serving [module], or null if none is registered.
  ReasoningProvider? providerFor(ReasoningModule module) {
    for (final p in _providers) {
      if (p.module == module) return p;
    }
    return null;
  }

  /// The capabilities available for [module] (empty if unsupported).
  Set<ReasoningCapability> capabilitiesFor(ReasoningModule module) =>
      providerFor(module)?.capabilities ?? const {};

  /// Whether [module] supports [capability].
  bool supports(ReasoningModule module, ReasoningCapability capability) =>
      providerFor(module)?.supports(capability) ?? false;

  /// Dispatches [request] to the owning provider.
  ReasoningResponse run(ReasoningRequest request) {
    final provider = providerFor(request.module);
    if (provider == null) {
      throw StateError(
        'No reasoning provider for module ${request.module.name}',
      );
    }
    if (!provider.supports(request.capability)) {
      throw StateError(
        'Provider ${provider.id} does not support ${request.capability.name}',
      );
    }
    return provider.run(request);
  }

  ReasoningResponse evaluate(ReasoningRequest request) =>
      run(request.withCapability(ReasoningCapability.evaluate));

  ReasoningResponse predict(ReasoningRequest request) =>
      run(request.withCapability(ReasoningCapability.predict));

  ReasoningResponse decide(ReasoningRequest request) =>
      run(request.withCapability(ReasoningCapability.decide));

  ReasoningResponse question(ReasoningRequest request) =>
      run(request.withCapability(ReasoningCapability.question));

  ReasoningResponse answer(ReasoningRequest request) =>
      run(request.withCapability(ReasoningCapability.answer));

  /// Flattens evidence across many responses (e.g. multi-system reads), in order.
  List<ReasoningEvidence> aggregate(Iterable<ReasoningResponse> responses) =>
      [for (final r in responses) ...r.evidence];
}
