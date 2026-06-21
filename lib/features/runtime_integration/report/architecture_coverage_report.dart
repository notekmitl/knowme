import '../audit/runtime_coverage_audit.dart';
import '../audit/runtime_dead_zone_audit.dart';
import '../pipeline/knowme_runtime_pipeline.dart';
import '../validation/runtime_validation.dart';

/// RT6 — architecture coverage report from real runtime execution.
class ArchitectureCoverageReport {
  const ArchitectureCoverageReport({
    required this.themeCount,
    required this.mirrorFindingCount,
    required this.fusionFindingCount,
    required this.humanPatternCount,
    required this.activatedPatternCount,
    required this.activationRate,
    required this.averageActivationsPerUser,
    required this.unusedRegistryPatternCount,
    required this.unusedMirrorKeyCount,
    required this.validationPassed,
    required this.pipelineIntegrityPassed,
    required this.patternActivationPassed,
    required this.validationIssues,
    required this.coverage,
    required this.deadZones,
  });

  final int themeCount;
  final int mirrorFindingCount;
  final int fusionFindingCount;
  final int humanPatternCount;
  final int activatedPatternCount;
  final double activationRate;
  final double averageActivationsPerUser;
  final int unusedRegistryPatternCount;
  final int unusedMirrorKeyCount;
  final bool validationPassed;
  final bool pipelineIntegrityPassed;
  final bool patternActivationPassed;
  final List<String> validationIssues;
  final RuntimeCoverageStatistics coverage;
  final RuntimeDeadZoneReport deadZones;

  Map<String, dynamic> toMap() {
    return {
      'themeCount': themeCount,
      'mirrorFindingCount': mirrorFindingCount,
      'fusionFindingCount': fusionFindingCount,
      'humanPatternCount': humanPatternCount,
      'activatedPatternCount': activatedPatternCount,
      'activationRate': activationRate,
      'averageActivationsPerUser': averageActivationsPerUser,
      'unusedRegistryPatternCount': unusedRegistryPatternCount,
      'unusedMirrorKeyCount': unusedMirrorKeyCount,
      'validationPassed': validationPassed,
      'pipelineIntegrityPassed': pipelineIntegrityPassed,
      'patternActivationPassed': patternActivationPassed,
      'validationIssues': validationIssues,
      'coverage': {
        'registryPatternCount': coverage.registryPatternCount,
        'activatedPatternCount': coverage.activatedPatternCount,
        'activationRate': coverage.activationRate,
        'activatedDimensionCount': coverage.activatedDimensionCount,
        'dimensionCoverageRate': coverage.dimensionCoverageRate,
        'activatedPatternIds': coverage.activatedPatternIds,
      },
      'deadZones': {
        'unmappedFusionFindingIds': deadZones.unmappedFusionFindingIds,
        'neverActivatedPatternIds': deadZones.neverActivatedPatternIds,
        'unusedMirrorKeys': deadZones.unusedMirrorKeys,
        'unusedThemeIds': deadZones.unusedThemeIds,
      },
    };
  }
}

abstract final class ArchitectureCoverageReportBuilder {
  static ArchitectureCoverageReport build(KnowMeRuntimePipelineResult result) {
    final validation = RuntimeValidation.validate(result);
    final coverage = RuntimeCoverageAudit.analyze(result);
    final deadZones = RuntimeDeadZoneAudit.analyze(result);

    final mirrorFindings = result.astrologyMirrorSnapshot.metadata.findingCount +
        result.personalityMirrorSnapshot.metadata.findingCount;

    final fusionFindings = result.globalFusionSnapshot.agreements.length +
        result.globalFusionSnapshot.tensions.length +
        result.globalFusionSnapshot.reinforcements.length +
        result.globalFusionSnapshot.blindSpots.length;

    return ArchitectureCoverageReport(
      themeCount: result.themeCount,
      mirrorFindingCount: mirrorFindings,
      fusionFindingCount: fusionFindings,
      humanPatternCount: result.humanModelSnapshot.patterns.length,
      activatedPatternCount: coverage.activatedPatternCount,
      activationRate: coverage.activationRate,
      averageActivationsPerUser: coverage.averageActivationsPerUser,
      unusedRegistryPatternCount: deadZones.neverActivatedPatternIds.length,
      unusedMirrorKeyCount: deadZones.unusedMirrorKeys.length,
      validationPassed: validation.passed,
      pipelineIntegrityPassed: validation.pipelineIntegrityPassed,
      patternActivationPassed: validation.patternActivationPassed,
      validationIssues: validation.issues,
      coverage: coverage,
      deadZones: deadZones,
    );
  }
}
