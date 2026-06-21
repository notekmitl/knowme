/// Golden validation scenarios for Exploration Overview (EO-F0).
enum ExplorationOverviewGoldenScenario {
  /// No profile data and no mirror snapshots.
  emptyUser,

  /// Profile present but no mirror snapshots.
  profileOnly,

  /// Astrology mirror only.
  astrologyOnly,

  /// Personality mirror only.
  personalityOnly,

  /// Both mirrors present.
  bothMirrors,

  /// Both mirrors with global fusion snapshot.
  globalFusionReady,

  /// Partial lenses across astrology and personality.
  mixedPartialState,
}
