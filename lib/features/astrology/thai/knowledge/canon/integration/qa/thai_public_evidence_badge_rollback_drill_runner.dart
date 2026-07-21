import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

import '../thai_canon_evidence_repository.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import '../thai_report_canon_evidence_enricher.dart';
import 'thai_canon_evidence_alignment_fixtures.dart';
import 'thai_public_evidence_badge_controlled_beta_qa_validator.dart';
import 'thai_public_evidence_badge_rollback_drill_validator.dart';

/// Runs formal rollback drill across deterministic fixtures.
abstract final class ThaiPublicEvidenceBadgeRollbackDrillRunner {
  static Future<ThaiPublicEvidenceBadgeRollbackDrillAudit> run({
    ThaiCanonEvidenceRepository? repository,
    List<ThaiCanonEvidenceAlignmentFixture>? fixtures,
  }) async {
    final rollbackOff =
        ThaiPublicEvidenceBadgeRollbackDrillValidator.auditRollbackOff();
    final reEnable =
        ThaiPublicEvidenceBadgeRollbackDrillValidator.auditReEnableInternalOnly();

    final repo = repository ?? await ThaiCanonEvidenceRepository.loadFromAsset();
    final fixtureList = fixtures ?? ThaiCanonEvidenceAlignmentFixtures.all;

    final bundles = <ThaiMirrorCanonEvidenceBundle>[];
    var totalEligible = 0;
    var fingerprintStable = true;
    var systemsNotRolledBack = true;

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
      bundles.add(bundle);

      if (before != after) {
        fingerprintStable = false;
        systemsNotRolledBack = false;
      }

      final betaBadges =
          ThaiPublicEvidenceBadgeControlledBetaQaValidator.auditFixture(
        fixtureId: fixture.id,
        bundle: bundle,
      );
      totalEligible += betaBadges.eligibleBetaBadgeCount;
    }

    final leakage =
        ThaiPublicEvidenceBadgeRollbackDrillValidator.auditLeakageAcrossBundles(
      bundles,
    );

    return ThaiPublicEvidenceBadgeRollbackDrillAudit(
      rollbackOffPassed: rollbackOff,
      reEnableInternalOnlyPassed: reEnable,
      fingerprintStableAcrossStates: fingerprintStable,
      systemsNotRolledBack: systemsNotRolledBack,
      leakageViolations: leakage,
      fixtureCount: fixtureList.length,
      totalEligibleBetaBadges: totalEligible,
    );
  }
}
