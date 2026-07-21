import '../../mirror/models/thai_mirror_lens_source.dart';
import '../../mirror/runtime/thai_mirror_pipeline.dart';
import 'thai_mirror_population_generator.dart';
import 'thai_mirror_population_profile.dart';
import 'thai_mirror_population_record.dart';
import 'thai_mirror_population_report.dart';

/// Runs [ThaiMirrorPipeline] across a population and aggregates statistics.
abstract final class ThaiMirrorPopulationAnalyzer {
  static ThaiMirrorPopulationReport analyze({
    List<ThaiMirrorPopulationProfile>? profiles,
  }) {
    final cohort = profiles ?? ThaiMirrorPopulationGenerator.generate();
    final records = cohort.map(_runProfile).toList(growable: false);
    return ThaiMirrorPopulationReport.fromRecords(records);
  }

  static ThaiMirrorPopulationRecord _runProfile(
    ThaiMirrorPopulationProfile profile,
  ) {
    final pipelineResult = ThaiMirrorPipeline.generate(profile.birthData);

    if (!pipelineResult.isSuccess) {
      return ThaiMirrorPopulationRecord(
        profile: profile,
        pipelineResult: pipelineResult,
      );
    }

    final mirror = pipelineResult.mirrorResult!;
    final foundation = pipelineResult.profile!;
    final viewState = pipelineResult.viewState!;

    final evidenceByLens = <String, int>{};
    for (final row in viewState.evidenceExplorer.rows) {
      final key = row.lensSource.id;
      evidenceByLens[key] = (evidenceByLens[key] ?? 0) + 1;
    }

    final summaries = mirror.sections
        .map((section) => section.summary ?? '')
        .where((summary) => summary.isNotEmpty)
        .toList(growable: false);

    return ThaiMirrorPopulationRecord(
      profile: profile,
      pipelineResult: pipelineResult,
      lagnaKey: foundation.lagnaKey,
      topThemeIds: mirror.topThemes.map((theme) => theme.themeId).toList(),
      topThemeConfidences:
          mirror.topThemes.map((theme) => theme.confidence.id).toList(),
      evidenceCount: viewState.evidenceExplorer.totalEvidenceCount,
      evidenceByLens: evidenceByLens,
      sectionsWithThemes: mirror.sections
          .where((section) => section.supportingThemes.isNotEmpty)
          .length,
      sectionsWithEvidence:
          mirror.sections.where((section) => section.evidence.isNotEmpty).length,
      summaries: summaries,
    );
  }
}
