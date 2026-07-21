import '../../mirror/runtime/thai_mirror_pipeline_result.dart';
import 'thai_mirror_population_profile.dart';

/// Pipeline outcome for one population profile.
class ThaiMirrorPopulationRecord {
  const ThaiMirrorPopulationRecord({
    required this.profile,
    required this.pipelineResult,
    this.lagnaKey,
    this.topThemeIds = const [],
    this.topThemeConfidences = const [],
    this.evidenceCount = 0,
    this.evidenceByLens = const {},
    this.sectionsWithThemes = 0,
    this.sectionsWithEvidence = 0,
    this.summaries = const [],
  });

  final ThaiMirrorPopulationProfile profile;
  final ThaiMirrorPipelineResult pipelineResult;
  final String? lagnaKey;
  final List<String> topThemeIds;
  final List<String> topThemeConfidences;
  final int evidenceCount;
  final Map<String, int> evidenceByLens;
  final int sectionsWithThemes;
  final int sectionsWithEvidence;
  final List<String> summaries;

  bool get succeeded => pipelineResult.isSuccess;
}
