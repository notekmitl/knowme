import 'reasoning_provider.dart';

/// V17 — the discovery registry the global runtime reads from.
///
/// Providers register themselves here at bootstrap (the runtime does **not**
/// import any concrete system), so `ReasoningRuntime.discover()` has no
/// hard-coded dependency on Thai or any other system. Registration is idempotent
/// by provider id.
class ReasoningProviderRegistry {
  ReasoningProviderRegistry._();

  static final ReasoningProviderRegistry instance = ReasoningProviderRegistry._();

  final List<ReasoningProvider> _providers = [];

  List<ReasoningProvider> get providers => List.unmodifiable(_providers);

  /// Registers [provider] unless one with the same id is already present.
  void register(ReasoningProvider provider) {
    if (_providers.any((p) => p.id == provider.id)) return;
    _providers.add(provider);
  }

  void unregister(String id) => _providers.removeWhere((p) => p.id == id);

  void clear() => _providers.clear();
}
