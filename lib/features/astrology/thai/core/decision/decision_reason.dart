/// Which axis a [DecisionReason] explains.
enum DecisionReasonKind { favourability, timing, risk, natal }

/// V11 — a finite vocabulary of *why* codes behind a decision. The engine emits
/// codes only; any later presentation layer maps codes → copy. This preserves
/// the copy boundary: no prose ever lives in the decision engine.
enum DecisionReasonCode {
  // favourability ----------------------------------------------------------
  strongFavourableOutlook,
  mixedOutlook,
  weakFavourableOutlook,
  // timing -----------------------------------------------------------------
  currentWindowOptimal,
  nearWindowBetter,
  futureWindowBetter,
  timingStable,
  // risk -------------------------------------------------------------------
  lowRiskEnvironment,
  elevatedRisk,
  highRiskEnvironment,
  // natal ------------------------------------------------------------------
  natalSupportsScenario,
  natalChallengesScenario,
  natalNeutralScenario,
}

/// A single structured reason behind a recommendation — evidence only.
///
/// [magnitude] is the signed contribution this reason made to the decision
/// (positive argues for acting, negative argues against), so a presenter can
/// rank reasons and a test can verify the verdict follows from its reasons.
class DecisionReason {
  const DecisionReason({
    required this.kind,
    required this.code,
    required this.magnitude,
  });

  final DecisionReasonKind kind;
  final DecisionReasonCode code;
  final int magnitude;
}
