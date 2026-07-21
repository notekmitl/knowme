/// V11 — the four verdicts the Decision Intelligence layer can return for a
/// scenario. Evidence only: this is a structured recommendation, never copy.
///
///  * [shouldAct]     — conditions favour moving now.
///  * [shouldPrepare] — groundwork now; a nearer window opens the door.
///  * [shouldWait]    — a later life period is materially more favourable.
///  * [shouldAvoid]   — risk outweighs reward in the foreseeable windows.
enum DecisionAction { shouldAct, shouldPrepare, shouldWait, shouldAvoid }

extension DecisionActionInfo on DecisionAction {
  /// Stable iteration order.
  static const List<DecisionAction> all = DecisionAction.values;

  /// A coarse "go" direction useful for downstream ranking without re-deriving
  /// the verdict: +1 act, 0 prepare/wait (conditional), −1 avoid.
  int get direction => switch (this) {
        DecisionAction.shouldAct => 1,
        DecisionAction.shouldPrepare => 0,
        DecisionAction.shouldWait => 0,
        DecisionAction.shouldAvoid => -1,
      };
}
