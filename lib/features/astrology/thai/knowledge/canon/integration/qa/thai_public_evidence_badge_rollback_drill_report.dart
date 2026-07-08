import 'thai_public_evidence_badge_rollback_drill_validator.dart';

/// JSON report for rollback drill.
abstract final class ThaiPublicEvidenceBadgeRollbackDrillReport {
  static Map<String, Object?> toMap(
    ThaiPublicEvidenceBadgeRollbackDrillAudit audit,
  ) {
    return {
      'phase': 'Public Evidence Badge Rollback Drill',
      'featureFlag': 'thai_public_evidence_badge_beta',
      'rollbackAction': 'off',
      'reEnableAction': 'internal_only',
      'fixtureCount': audit.fixtureCount,
      'overallPassed': audit.overallPassed,
      'rollbackOffPassed': audit.rollbackOffPassed,
      'reEnableInternalOnlyPassed': audit.reEnableInternalOnlyPassed,
      'fingerprintStableAcrossStates': audit.fingerprintStableAcrossStates,
      'systemsNotRolledBack': audit.systemsNotRolledBack,
      'leakageViolations': audit.leakageViolations,
      'totalEligibleBetaBadges': audit.totalEligibleBetaBadges,
      'systemsRolledBack': <String>[],
      'systemsNotRequiringRollback': [
        'canon_dataset',
        'evidence_mapping',
        'engine',
        'mirror_copy',
        'prediction_copy',
        'thai_beta_report_data',
        'firestore_data',
        'public_ui',
      ],
    };
  }
}
