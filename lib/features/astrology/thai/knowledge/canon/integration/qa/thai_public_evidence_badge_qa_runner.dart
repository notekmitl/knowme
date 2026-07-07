import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

import '../thai_canon_evidence_repository.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_report_canon_evidence_enricher.dart';
import 'thai_canon_evidence_alignment_fixtures.dart';
import 'thai_public_evidence_badge_qa_validator.dart';

/// Runs formal public evidence badge QA across deterministic fixtures.
abstract final class ThaiPublicEvidenceBadgeQaRunner {
  static Future<ThaiPublicEvidenceBadgeQaAudit> run({
    ThaiCanonEvidenceRepository? repository,
    List<ThaiCanonEvidenceAlignmentFixture>? fixtures,
  }) async {
    final repo = repository ?? await ThaiCanonEvidenceRepository.loadFromAsset();
    final fixtureList = fixtures ?? ThaiCanonEvidenceAlignmentFixtures.all;

    final results = <ThaiPublicEvidenceBadgeFixtureQaResult>[];
    var totalEligible = 0;
    var eligibilityViolations = 0;
    var copyViolations = 0;
    var leakageViolations = 0;

    var fingerprintOk = true;
    var remediesHidden = true;

    for (final fixture in fixtureList) {
      final pipeline = ThaiMirrorPipeline.generate(fixture.birthData);
      final before = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        pipeline,
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repo,
      );
      final after = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        bundle.pipelineResult,
      );
      if (before != after) fingerprintOk = false;

      for (final attachment in bundle.attachments) {
        if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
          remediesHidden = false;
        }
        if (attachment.userFacingAllowed &&
            attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
          remediesHidden = false;
        }
      }

      final result = ThaiPublicEvidenceBadgeQaValidator.auditFixture(
        fixtureId: fixture.id,
        bundle: bundle,
      );
      results.add(result);
      totalEligible += result.eligiblePreviewCount;
      eligibilityViolations += result.eligibilityViolations.length;
      copyViolations += result.copySafetyViolations.length;
      leakageViolations += result.dataLeakageViolations.length;
    }

    return ThaiPublicEvidenceBadgeQaAudit(
      fixtureResults: results,
      totalEligiblePreviews: totalEligible,
      totalEligibilityViolations: eligibilityViolations,
      totalCopySafetyViolations: copyViolations,
      totalDataLeakageViolations: leakageViolations,
      publicFingerprintUnchanged: fingerprintOk,
      remediesHidden: remediesHidden,
    );
  }
}
