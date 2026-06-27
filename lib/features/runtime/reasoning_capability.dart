/// V17 — the cross-system reasoning operations a provider may support.
///
/// These mirror the Thai reference runtime's public APIs so any future system
/// (Western, BaZi, MBTI, …) can declare the same capability vocabulary. A
/// provider advertises the subset it implements; the runtime uses this for
/// capability detection and dispatch.
enum ReasoningCapability {
  /// A full evaluation (the deepest snapshot the system produces).
  evaluate,

  /// A forward-looking / predictive read.
  predict,

  /// A decision/recommendation read.
  decide,

  /// A structured-question read.
  question,

  /// An answer to a structured question (alias of [question] for most systems).
  answer,
}
