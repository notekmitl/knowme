/// Shared Fusion theme categories (KNOWME MASTER CONTEXT Section 50.3).
enum FusionCategory {
  coreSelf,
  thinkingStyle,
  emotionalWorld,
  relationships,
  workAndAmbition,
  strengths,
  growthAreas,
  growthPath,
}

extension FusionCategoryIds on FusionCategory {
  String get id {
    return switch (this) {
      FusionCategory.coreSelf => 'core_self',
      FusionCategory.thinkingStyle => 'thinking_style',
      FusionCategory.emotionalWorld => 'emotional_world',
      FusionCategory.relationships => 'relationships',
      FusionCategory.workAndAmbition => 'work_and_ambition',
      FusionCategory.strengths => 'strengths',
      FusionCategory.growthAreas => 'growth_areas',
      FusionCategory.growthPath => 'growth_path',
    };
  }
}
