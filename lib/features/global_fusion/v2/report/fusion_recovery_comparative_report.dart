import '../audit/fusion_compression_audit.dart';

/// FCR6 — before/after comparative metrics for recovery simulation.
class FusionRecoveryComparativeReport {
  const FusionRecoveryComparativeReport({
    required this.beforeMirrorThemeCount,
    required this.beforeFusionThemeCount,
    required this.afterFusionThemeCount,
    required this.beforeFusionFindings,
    required this.afterFusionFindings,
    required this.beforeHumanMeanings,
    required this.afterHumanMeanings,
    required this.beforePatternActivations,
    required this.afterPatternActivations,
    required this.beforeActivationRate,
    required this.afterActivationRate,
    required this.supplementalFindingCount,
    required this.fusionThemeRecoveryRate,
    required this.activationImprovementRate,
    required this.compressionAudit,
  });

  final int beforeMirrorThemeCount;
  final int beforeFusionThemeCount;
  final int afterFusionThemeCount;
  final int beforeFusionFindings;
  final int afterFusionFindings;
  final int beforeHumanMeanings;
  final int afterHumanMeanings;
  final int beforePatternActivations;
  final int afterPatternActivations;
  final double beforeActivationRate;
  final double afterActivationRate;
  final int supplementalFindingCount;
  final double fusionThemeRecoveryRate;
  final double activationImprovementRate;
  final FusionCompressionAuditReport compressionAudit;

  Map<String, dynamic> toMap() {
    return {
      'beforeMirrorThemeCount': beforeMirrorThemeCount,
      'beforeFusionThemeCount': beforeFusionThemeCount,
      'afterFusionThemeCount': afterFusionThemeCount,
      'beforeFusionFindings': beforeFusionFindings,
      'afterFusionFindings': afterFusionFindings,
      'beforeHumanMeanings': beforeHumanMeanings,
      'afterHumanMeanings': afterHumanMeanings,
      'beforePatternActivations': beforePatternActivations,
      'afterPatternActivations': afterPatternActivations,
      'beforeActivationRate': beforeActivationRate,
      'afterActivationRate': afterActivationRate,
      'supplementalFindingCount': supplementalFindingCount,
      'fusionThemeRecoveryRate': fusionThemeRecoveryRate,
      'activationImprovementRate': activationImprovementRate,
    };
  }
}

abstract final class FusionRecoveryComparativeReportBuilder {
  static FusionRecoveryComparativeReport build({
    required int beforeMirrorThemeCount,
    required int beforeFusionThemeCount,
    required int afterFusionThemeCount,
    required int beforeFusionFindings,
    required int afterFusionFindings,
    required int beforeHumanMeanings,
    required int afterHumanMeanings,
    required int beforePatternActivations,
    required int afterPatternActivations,
    required double beforeActivationRate,
    required double afterActivationRate,
    required int supplementalFindingCount,
    required FusionCompressionAuditReport compressionAudit,
  }) {
    final themeRecovery = beforeFusionThemeCount == 0
        ? 0.0
        : (afterFusionThemeCount - beforeFusionThemeCount) /
            beforeFusionThemeCount;

    final activationImprovement = beforeActivationRate == 0
        ? afterActivationRate
        : (afterActivationRate - beforeActivationRate) / beforeActivationRate;

    return FusionRecoveryComparativeReport(
      beforeMirrorThemeCount: beforeMirrorThemeCount,
      beforeFusionThemeCount: beforeFusionThemeCount,
      afterFusionThemeCount: afterFusionThemeCount,
      beforeFusionFindings: beforeFusionFindings,
      afterFusionFindings: afterFusionFindings,
      beforeHumanMeanings: beforeHumanMeanings,
      afterHumanMeanings: afterHumanMeanings,
      beforePatternActivations: beforePatternActivations,
      afterPatternActivations: afterPatternActivations,
      beforeActivationRate: beforeActivationRate,
      afterActivationRate: afterActivationRate,
      supplementalFindingCount: supplementalFindingCount,
      fusionThemeRecoveryRate: themeRecovery.clamp(-1.0, 10.0),
      activationImprovementRate: activationImprovement,
      compressionAudit: compressionAudit,
    );
  }
}
