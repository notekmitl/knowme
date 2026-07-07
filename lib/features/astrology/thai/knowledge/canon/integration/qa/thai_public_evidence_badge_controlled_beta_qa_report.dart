import 'thai_public_evidence_badge_controlled_beta_qa_validator.dart';

/// JSON report for controlled beta QA.
abstract final class ThaiPublicEvidenceBadgeControlledBetaQaReport {
  static Map<String, Object?> toMap(
    ThaiPublicEvidenceBadgeControlledBetaQaAudit audit,
  ) {
    return {
      'phase': 'Public Evidence Badge Controlled Beta QA',
      'featureFlag': 'thai_public_evidence_badge_beta',
      'defaultFlagState': 'off',
      'fixtureCount': audit.fixtureResults.length,
      'overallPassed': audit.overallPassed,
      'flagQaPassed': audit.flagQaPassed,
      'audienceGatingPassed': audit.audienceGatingPassed,
      'defaultFlagOff': audit.defaultFlagOff,
      'totalEligibleBetaBadges': audit.totalEligibleBetaBadges,
      'totalEligibilityViolations': audit.totalEligibilityViolations,
      'totalCopySafetyViolations': audit.totalCopySafetyViolations,
      'totalDataLeakageViolations': audit.totalDataLeakageViolations,
      'telemetrySafe': audit.telemetrySafe,
      'telemetryProductionEnabled': false,
      'publicFingerprintUnchanged': audit.publicFingerprintUnchanged,
      'remediesHidden': audit.remediesHidden,
      'allowedSurface': 'ThaiBetaReportPage',
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
