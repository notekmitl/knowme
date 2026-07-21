import '../domain/fusion_recovery_enums.dart';
import '../domain/global_fusion_supplemental_findings.dart';

/// FCR3 — recoverable mirror findings grouped by risk.
class RecoverableFindingEntry {
  const RecoverableFindingEntry({
    required this.sourceFindingId,
    required this.findingType,
    required this.mirrorKey,
    required this.themeIds,
    required this.riskLevel,
    required this.recoveryRuleId,
  });

  final String sourceFindingId;
  final String findingType;
  final String mirrorKey;
  final List<String> themeIds;
  final FusionRecoveryRiskLevel riskLevel;
  final String recoveryRuleId;
}

class RecoverableFindingsAuditReport {
  const RecoverableFindingsAuditReport({
    required this.lowRisk,
    required this.mediumRisk,
    required this.highRisk,
    required this.totalRecoverable,
  });

  final List<RecoverableFindingEntry> lowRisk;
  final List<RecoverableFindingEntry> mediumRisk;
  final List<RecoverableFindingEntry> highRisk;
  final int totalRecoverable;
}

abstract final class RecoverableFindingsAudit {
  static RecoverableFindingsAuditReport fromSupplemental({
    required List<GlobalFusionSupplementalReinforcement> reinforcements,
    required List<GlobalFusionSupplementalAgreement> agreements,
    required List<GlobalFusionSupplementalThemeSignal> themeSignals,
  }) {
    final low = <RecoverableFindingEntry>[];
    final medium = <RecoverableFindingEntry>[];
    final high = <RecoverableFindingEntry>[];

    void add(FusionRecoveryRiskLevel level, RecoverableFindingEntry entry) {
      switch (level) {
        case FusionRecoveryRiskLevel.low:
          low.add(entry);
        case FusionRecoveryRiskLevel.medium:
          medium.add(entry);
        case FusionRecoveryRiskLevel.high:
          high.add(entry);
      }
    }

    for (final item in reinforcements) {
      for (final sourceId in item.sourceFindingIds) {
        add(
          item.riskLevel,
          RecoverableFindingEntry(
            sourceFindingId: sourceId,
            findingType: 'reinforcement',
            mirrorKey: item.mirrorKey,
            themeIds: item.themeIds,
            riskLevel: item.riskLevel,
            recoveryRuleId: item.recoveryRuleId,
          ),
        );
      }
    }

    for (final item in agreements) {
      for (final sourceId in item.sourceFindingIds) {
        add(
          item.riskLevel,
          RecoverableFindingEntry(
            sourceFindingId: sourceId,
            findingType: 'agreement',
            mirrorKey: item.mirrorKey,
            themeIds: item.themeIds,
            riskLevel: item.riskLevel,
            recoveryRuleId: item.recoveryRuleId,
          ),
        );
      }
    }

    for (final item in themeSignals) {
      add(
        item.riskLevel,
        RecoverableFindingEntry(
          sourceFindingId: item.mirrorFindingId,
          findingType: 'theme_signal',
          mirrorKey: item.mirrorKey,
          themeIds: [item.themeId],
          riskLevel: item.riskLevel,
          recoveryRuleId: item.recoveryRuleId,
        ),
      );
    }

    return RecoverableFindingsAuditReport(
      lowRisk: low,
      mediumRisk: medium,
      highRisk: high,
      totalRecoverable: low.length + medium.length + high.length,
    );
  }
}
