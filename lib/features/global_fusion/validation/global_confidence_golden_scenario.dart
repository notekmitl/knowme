/// Golden validation scenarios for Global Confidence v1 (GF-F2).
enum GlobalConfidenceGoldenScenario {
  /// No mirrors → low band.
  noMirrors,

  /// One mirror only → medium band.
  oneMirror,

  /// Both mirrors, no cross-mirror agreement → medium band.
  twoMirrorsNoAgreement,

  /// Both mirrors, one strong agreement → high band.
  oneStrongAgreement,

  /// Both mirrors, multiple agreements → high band.
  manyAgreements,

  /// Both mirrors, agreements and tensions → reduced vs agreement-only.
  agreementsWithTensions,

  /// Both mirrors, heavy tensions without agreements → lower confidence.
  heavyTensions,
}
