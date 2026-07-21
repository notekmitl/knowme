import 'reasoning_capability.dart';
import 'reasoning_module.dart';
import 'reasoning_request.dart';
import 'reasoning_response.dart';

/// V17 — the contract every reasoning system implements to plug into the global
/// runtime.
///
/// A provider owns exactly one [module], advertises the [capabilities] it
/// supports, and answers a [ReasoningRequest] by delegating to its system and
/// mapping the result into the system-agnostic [ReasoningResponse]. The Thai
/// reference system implements this via `ThaiRuntimeAdapter`; future systems
/// (Western, BaZi, MBTI, …) add their own providers without touching the runtime.
abstract class ReasoningProvider {
  const ReasoningProvider();

  /// The system this provider serves.
  ReasoningModule get module;

  /// A stable, unique provider id (e.g. `thai`).
  String get id;

  /// A short, non-localized provider name (developer-facing; not consumer copy).
  String get displayName;

  /// The capabilities this provider implements.
  Set<ReasoningCapability> get capabilities;

  /// Whether this provider supports [capability].
  bool supports(ReasoningCapability capability) =>
      capabilities.contains(capability);

  /// Runs the request against the underlying system.
  ReasoningResponse run(ReasoningRequest request);
}
