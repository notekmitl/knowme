/// Fusion Theme Registry ids grouped by category (preparation layer — not consumed at runtime yet).
class ZodiacFusionThemeBundle {
  const ZodiacFusionThemeBundle({
    required this.coreSelf,
    required this.relationships,
    required this.workAndAmbition,
    required this.strengths,
    required this.growthAreas,
  });

  final List<String> coreSelf;
  final List<String> relationships;
  final List<String> workAndAmbition;
  final List<String> strengths;
  final List<String> growthAreas;
}
