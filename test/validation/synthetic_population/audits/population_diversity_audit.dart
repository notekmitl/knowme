import '../pipeline/synthetic_human_run_record.dart';

/// Measures unique outcomes across mirror, fusion, pattern, and narrative layers.
class PopulationDiversityAudit {
  const PopulationDiversityAudit({
    required this.populationSize,
    required this.uniqueMirrorOutcomes,
    required this.uniqueFusionOutcomes,
    required this.uniquePatternSets,
    required this.uniqueNarrativeFingerprints,
    required this.mirrorDiversityRatio,
    required this.fusionDiversityRatio,
    required this.patternDiversityRatio,
    required this.narrativeDiversityRatio,
  });

  final int populationSize;
  final int uniqueMirrorOutcomes;
  final int uniqueFusionOutcomes;
  final int uniquePatternSets;
  final int uniqueNarrativeFingerprints;
  final double mirrorDiversityRatio;
  final double fusionDiversityRatio;
  final double patternDiversityRatio;
  final double narrativeDiversityRatio;

  static PopulationDiversityAudit analyze(List<SyntheticHumanRunRecord> records) {
    final size = records.length;
    final mirrors = records.map((item) => item.mirrorFingerprint).toSet();
    final fusions = records.map((item) => item.fusionFingerprint).toSet();
    final patterns = records.map((item) => item.patternFingerprint).toSet();
    final narratives = records.map((item) => item.narrativeFingerprint).toSet();

    double ratio(int unique) => size == 0 ? 0 : unique / size;

    return PopulationDiversityAudit(
      populationSize: size,
      uniqueMirrorOutcomes: mirrors.length,
      uniqueFusionOutcomes: fusions.length,
      uniquePatternSets: patterns.length,
      uniqueNarrativeFingerprints: narratives.length,
      mirrorDiversityRatio: ratio(mirrors.length),
      fusionDiversityRatio: ratio(fusions.length),
      patternDiversityRatio: ratio(patterns.length),
      narrativeDiversityRatio: ratio(narratives.length),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'uniqueMirrorOutcomes': uniqueMirrorOutcomes,
      'uniqueFusionOutcomes': uniqueFusionOutcomes,
      'uniquePatternSets': uniquePatternSets,
      'uniqueNarrativeFingerprints': uniqueNarrativeFingerprints,
      'mirrorDiversityRatio': mirrorDiversityRatio,
      'fusionDiversityRatio': fusionDiversityRatio,
      'patternDiversityRatio': patternDiversityRatio,
      'narrativeDiversityRatio': narrativeDiversityRatio,
    };
  }
}
