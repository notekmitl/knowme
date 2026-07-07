import 'thai_public_evidence_badge_qa_validator.dart';

/// JSON-serializable public evidence badge QA report.
abstract final class ThaiPublicEvidenceBadgeQaReport {
  static Map<String, Object?> toMap(ThaiPublicEvidenceBadgeQaAudit audit) {
    return {
      'phase': 'Public Evidence Badge QA',
      'policyLevel': 'LEVEL_1_PUBLIC_SUMMARY_BADGE',
      'previewRoute': '/internal/thai-public-evidence-preview',
      'fixtureCount': audit.fixtureResults.length,
      'overallPassed': audit.overallPassed,
      'totalEligiblePreviews': audit.totalEligiblePreviews,
      'totalEligibilityViolations': audit.totalEligibilityViolations,
      'totalCopySafetyViolations': audit.totalCopySafetyViolations,
      'totalDataLeakageViolations': audit.totalDataLeakageViolations,
      'publicFingerprintUnchanged': audit.publicFingerprintUnchanged,
      'remediesHidden': audit.remediesHidden,
      'fixtures': audit.fixtureResults.map(_fixtureMap).toList(),
      'aggregateHidden': _aggregateHidden(audit),
    };
  }

  static Map<String, Object?> _fixtureMap(
    ThaiPublicEvidenceBadgeFixtureQaResult result,
  ) {
    return {
      'id': result.fixtureId,
      'eligiblePreviewCount': result.eligiblePreviewCount,
      'eligibilityPassed': result.eligibilityPassed,
      'copySafetyPassed': result.copySafetyPassed,
      'dataLeakagePassed': result.dataLeakagePassed,
      'passed': result.passed,
      'eligibilityViolationCount': result.eligibilityViolations.length,
      'copySafetyViolationCount': result.copySafetyViolations.length,
      'dataLeakageViolationCount': result.dataLeakageViolations.length,
      'hidden': {
        'remedies': result.hiddenSummary.hiddenRemedies,
        'taksa': result.hiddenSummary.hiddenTaksa,
        'khumsap': result.hiddenSummary.hiddenKhumsap,
        'riseFall': result.hiddenSummary.hiddenRiseFall,
        'blockedAmbiguous': result.hiddenSummary.blockedAmbiguous,
        'blockedSourceConflict': result.hiddenSummary.blockedSourceConflict,
        'outOfCanonScope': result.hiddenSummary.outOfCanonScope,
      },
    };
  }

  static Map<String, int> _aggregateHidden(ThaiPublicEvidenceBadgeQaAudit audit) {
    var remedies = 0;
    var taksa = 0;
    var khumsap = 0;
    var riseFall = 0;
    var ambiguous = 0;
    var conflict = 0;
    var outOfScope = 0;
    for (final result in audit.fixtureResults) {
      final h = result.hiddenSummary;
      remedies += h.hiddenRemedies;
      taksa += h.hiddenTaksa;
      khumsap += h.hiddenKhumsap;
      riseFall += h.hiddenRiseFall;
      ambiguous += h.blockedAmbiguous;
      conflict += h.blockedSourceConflict;
      outOfScope += h.outOfCanonScope;
    }
    return {
      'hiddenRemedies': remedies,
      'hiddenTaksa': taksa,
      'hiddenKhumsap': khumsap,
      'hiddenRiseFall': riseFall,
      'blockedAmbiguous': ambiguous,
      'blockedSourceConflict': conflict,
      'outOfCanonScope': outOfScope,
    };
  }
}
