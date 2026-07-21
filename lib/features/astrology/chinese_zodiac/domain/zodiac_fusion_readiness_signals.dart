/// Theme Foundation ids grouped for future Fusion consumption (preparation only).
class ZodiacFusionReadinessSignals {
  const ZodiacFusionReadinessSignals({
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

  bool get hasCoreSelfCoverage => coreSelf.isNotEmpty;
  bool get hasRelationshipsCoverage => relationships.isNotEmpty;
  bool get hasWorkAndAmbitionCoverage => workAndAmbition.isNotEmpty;
  bool get hasStrengthsCoverage => strengths.isNotEmpty;
  bool get hasGrowthAreasCoverage => growthAreas.isNotEmpty;

  bool get isFullyReady =>
      hasCoreSelfCoverage &&
      hasRelationshipsCoverage &&
      hasWorkAndAmbitionCoverage &&
      hasStrengthsCoverage &&
      hasGrowthAreasCoverage;
}
