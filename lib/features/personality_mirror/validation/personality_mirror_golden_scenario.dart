/// Golden validation scenarios for Personality Mirror (PF-4).
enum PersonalityMirrorGoldenScenario {
  /// MBTI + Big Five aligned themes → strong agreement.
  scenarioA,

  /// MBTI reserved vs Big Five expressive → tension.
  scenarioB,

  /// MBTI only → low coverage and low confidence.
  scenarioC,

  /// MBTI + Big Five + EQ aligned → very high confidence.
  scenarioD,
}
