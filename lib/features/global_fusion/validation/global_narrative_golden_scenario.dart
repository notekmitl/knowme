/// Golden validation scenarios for Global Narrative Foundation (GF-F3).
enum GlobalNarrativeGoldenScenario {
  /// No mirror data — empty reflection list.
  emptyState,

  /// Theme activations only (single mirror).
  themeOnly,

  /// Cross-mirror agreements without tensions.
  agreementOnly,

  /// Cross-mirror tensions without agreements.
  tensionOnly,

  /// Themes, agreements, and tensions together.
  mixedState,
}
