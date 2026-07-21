import 'thai_public_evidence_badge_internal_only_activation_qa_validator.dart';

/// JSON report for internal-only activation QA.
abstract final class ThaiPublicEvidenceBadgeInternalOnlyActivationQaReport {
  static Map<String, Object?> toMap(
    ThaiPublicEvidenceBadgeInternalOnlyActivationQaAudit audit,
  ) {
    return {
      'phase': 'Public Evidence Badge Internal Only Activation QA',
      'featureFlag': 'thai_public_evidence_badge_beta',
      'activeFlagState': 'internal_only',
      'fixtureCount': audit.fixtureResults.length,
      'overallPassed': audit.overallPassed,
      'activationStatePassed': audit.activationStatePassed,
      'audienceIsolationPassed': audit.audienceIsolationPassed,
      'invitedBetaInactive': audit.invitedBetaInactive,
      'rollbackPassed': audit.rollbackPassed,
      'totalEligibleBetaBadges': audit.totalEligibleBetaBadges,
      'totalEligibilityViolations': audit.totalEligibilityViolations,
      'totalCopySafetyViolations': audit.totalCopySafetyViolations,
      'totalDataLeakageViolations': audit.totalDataLeakageViolations,
      'publicFingerprintUnchanged': audit.publicFingerprintUnchanged,
      'remediesHidden': audit.remediesHidden,
      'allowedSurface': 'ThaiBetaReportPage',
      'allowedAudience': 'research_admin_internal_tester',
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
