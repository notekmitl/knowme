import 'thai_public_evidence_badge_invited_beta_activation_qa_validator.dart';

/// JSON report for invited-beta activation QA.
abstract final class ThaiPublicEvidenceBadgeInvitedBetaActivationQaReport {
  static Map<String, Object?> toMap(
    ThaiPublicEvidenceBadgeInvitedBetaActivationQaAudit audit,
  ) {
    return {
      'phase': 'Public Evidence Badge Invited Beta Activation QA',
      'featureFlag': 'thai_public_evidence_badge_beta',
      'activeFlagState': 'invited_beta',
      'fixtureCount': audit.fixtureResults.length,
      'overallPassed': audit.overallPassed,
      'activationStatePassed': audit.activationStatePassed,
      'audienceIsolationPassed': audit.audienceIsolationPassed,
      'registryPassed': audit.registryPassed,
      'rollbackPassed': audit.rollbackPassed,
      'internalOnlyPreserved': audit.internalOnlyPreserved,
      'invalidFlagOff': audit.invalidFlagOff,
      'totalEligibleBetaBadges': audit.totalEligibleBetaBadges,
      'totalEligibilityViolations': audit.totalEligibilityViolations,
      'totalCopySafetyViolations': audit.totalCopySafetyViolations,
      'totalDataLeakageViolations': audit.totalDataLeakageViolations,
      'publicFingerprintUnchanged': audit.publicFingerprintUnchanged,
      'remediesHidden': audit.remediesHidden,
      'allowedSurface': 'ThaiBetaReportPage',
      'allowedAudience': 'invited_beta_allow_list_uid',
      'fixtures': audit.fixtureResults
          .map(
            (r) => {
              'id': r.fixtureId,
              'eligibleBetaBadgeCount': r.eligibleBetaBadgeCount,
              'passed': r.passed,
              'eligibilityViolationCount': r.eligibilityViolations.length,
              'copySafetyViolationCount': r.copySafetyViolations.length,
              'dataLeakageViolationCount': r.dataLeakageViolations.length,
            },
          )
          .toList(),
    };
  }
}
