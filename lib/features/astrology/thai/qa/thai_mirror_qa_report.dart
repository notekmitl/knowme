import '../mirror/models/thai_mirror_result.dart';
import '../mirror/runtime/thai_mirror_pipeline.dart';
import '../mirror/runtime/thai_mirror_pipeline_result.dart';
import 'thai_mirror_qa_profile.dart';

/// Validation outcome for one QA profile run.
enum ThaiMirrorQaStatus {
  pass,
  warning,
  fail,
}

/// Aggregated QA report for a single profile pipeline run.
class ThaiMirrorQaReport {
  const ThaiMirrorQaReport({
    required this.profileId,
    required this.status,
    required this.topThemes,
    required this.warningCount,
    required this.sectionCount,
    required this.evidenceCount,
    required this.issues,
    this.generatedAt,
    this.pipelineSucceeded = false,
    this.narrativeComplete = false,
  });

  final String profileId;
  final DateTime? generatedAt;
  final List<String> topThemes;
  final int warningCount;
  final int sectionCount;
  final int evidenceCount;
  final ThaiMirrorQaStatus status;
  final List<String> issues;
  final bool pipelineSucceeded;
  final bool narrativeComplete;

  static const expectedSectionCount = 8;

  /// Runs the real pipeline and produces a validated report.
  static ThaiMirrorQaReport generate(ThaiMirrorQaProfile profile) {
    final pipelineResult = ThaiMirrorPipeline.generate(profile.birthData);
    return fromPipeline(profile: profile, pipelineResult: pipelineResult);
  }

  static ThaiMirrorQaReport fromPipeline({
    required ThaiMirrorQaProfile profile,
    required ThaiMirrorPipelineResult pipelineResult,
  }) {
    if (pipelineResult.isFailure) {
      return ThaiMirrorQaReport(
        profileId: profile.id,
        status: ThaiMirrorQaStatus.fail,
        topThemes: const [],
        warningCount: 0,
        sectionCount: 0,
        evidenceCount: 0,
        issues: [
          pipelineResult.errorMessage ?? 'Pipeline failed without message',
        ],
      );
    }

    final mirrorResult = pipelineResult.mirrorResult!;
    final viewState = pipelineResult.viewState!;
    final foundationProfile = pipelineResult.profile!;

    final topThemeIds =
        mirrorResult.topThemes.map((theme) => theme.themeId).toList();
    final topThemeNames =
        mirrorResult.topThemes.map((theme) => theme.themeName).toList();
    final sectionCount = mirrorResult.sections.length;
    final evidenceCount = viewState.evidenceExplorer.totalEvidenceCount;
    final narrativeComplete =
        mirrorResult.narrativeStatus == ThaiMirrorNarrativeStatus.complete;

    final issues = <String>[];
    final criticalIssues = <String>[];

    if (topThemeIds.isEmpty) {
      issues.add('Top themes is empty');
    }

    if (sectionCount != expectedSectionCount) {
      criticalIssues.add(
        'Section count is $sectionCount (expected $expectedSectionCount)',
      );
    }

    if (!narrativeComplete) {
      issues.add('Narrative is not complete');
    }

    if (evidenceCount == 0) {
      issues.add('No evidence rows found');
    }

    if (_hasDuplicateIds(topThemeIds)) {
      criticalIssues.add('Duplicate theme ids in top themes');
    }

    final status = _resolveStatus(
      pipelineSucceeded: true,
      issues: issues,
      criticalIssues: criticalIssues,
    );

    return ThaiMirrorQaReport(
      profileId: profile.id,
      generatedAt: pipelineResult.generatedAt,
      topThemes: topThemeNames,
      warningCount: foundationProfile.warnings.length,
      sectionCount: sectionCount,
      evidenceCount: evidenceCount,
      status: status,
      issues: [...criticalIssues, ...issues],
      pipelineSucceeded: true,
      narrativeComplete: narrativeComplete,
    );
  }

  static bool _hasDuplicateIds(List<String> ids) {
    return ids.toSet().length != ids.length;
  }

  static ThaiMirrorQaStatus _resolveStatus({
    required bool pipelineSucceeded,
    required List<String> issues,
    required List<String> criticalIssues,
  }) {
    if (!pipelineSucceeded) {
      return ThaiMirrorQaStatus.fail;
    }
    if (criticalIssues.isNotEmpty) {
      return ThaiMirrorQaStatus.fail;
    }
    if (issues.isNotEmpty) {
      return ThaiMirrorQaStatus.warning;
    }
    return ThaiMirrorQaStatus.pass;
  }
}
