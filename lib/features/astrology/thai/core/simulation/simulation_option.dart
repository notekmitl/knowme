/// V14 — the four hypothetical paths every simulation evaluates.
///
/// They are *timing paths*: the engine re-queries the V13 runtime as if the
/// decision were taken at different points (now, the best window, an alternative
/// window) versus not taken at all.
enum SimulationOptionKind {
  /// Option A — take the decision at the current evaluation date.
  actNow,

  /// Option B — take the decision at the recommendation's best timing window.
  actAtBestWindow,

  /// Option C — take the decision at the recommendation's alternative (worst)
  /// timing window, for contrast.
  actAtAlternativeWindow,

  /// Do Nothing — the status-quo baseline (the decision is not taken).
  doNothing,
}

/// V14 — one evaluated path: which option, the age it is simulated at, and the
/// `asOf` the runtime was queried with. Evidence only; no copy.
class SimulationOption {
  const SimulationOption({
    required this.kind,
    required this.targetAge,
    required this.evaluatedAsOf,
  });

  final SimulationOptionKind kind;

  /// The age the action is simulated at (null for [SimulationOptionKind.doNothing]).
  final int? targetAge;

  /// The evaluation date the runtime was queried with for this path
  /// (null for [SimulationOptionKind.doNothing]).
  final DateTime? evaluatedAsOf;
}
