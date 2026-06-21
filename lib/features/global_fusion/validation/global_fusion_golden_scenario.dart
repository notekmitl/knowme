/// Golden validation scenarios for Global Fusion (GF-F1 synthesis).
enum GlobalFusionGoldenScenario {
  /// Astrology mirror only — no cross-mirror synthesis.
  scenarioA,

  /// Personality mirror only — no cross-mirror synthesis.
  scenarioB,

  /// Both mirrors — agreement only.
  scenarioC,

  /// Both mirrors — tension only.
  scenarioD,

  /// Both mirrors — agreement and tension.
  scenarioE,

  /// Neither mirror — empty state.
  scenarioF,
}
