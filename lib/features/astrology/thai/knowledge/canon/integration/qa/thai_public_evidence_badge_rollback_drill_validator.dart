import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';

import 'package:knowme/features/thai_beta/application/thai_research_admin_access.dart';

import '../presentation/thai_public_evidence_badge_beta_gate.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import 'thai_public_evidence_badge_controlled_beta_qa_validator.dart';

/// Aggregate rollback drill audit.
class ThaiPublicEvidenceBadgeRollbackDrillAudit {
  const ThaiPublicEvidenceBadgeRollbackDrillAudit({
    required this.rollbackOffPassed,
    required this.reEnableInternalOnlyPassed,
    required this.fingerprintStableAcrossStates,
    required this.systemsNotRolledBack,
    required this.leakageViolations,
    required this.fixtureCount,
    required this.totalEligibleBetaBadges,
  });

  final bool rollbackOffPassed;
  final bool reEnableInternalOnlyPassed;
  final bool fingerprintStableAcrossStates;
  final bool systemsNotRolledBack;
  final int leakageViolations;
  final int fixtureCount;
  final int totalEligibleBetaBadges;

  bool get overallPassed =>
      rollbackOffPassed &&
      reEnableInternalOnlyPassed &&
      fingerprintStableAcrossStates &&
      systemsNotRolledBack &&
      leakageViolations == 0;
}

/// Formal rollback drill validator.
abstract final class ThaiPublicEvidenceBadgeRollbackDrillValidator {
  static bool auditRollbackOff() {
    const audiences = [
      ThaiBetaEvidenceBadgeAudience.internalTester(),
      ThaiBetaEvidenceBadgeAudience.anonymous(),
      ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
    ];

    if (ThaiEvidenceBadgeFeatureFlag.parse('off') !=
        ThaiEvidenceBadgeFeatureFlagState.off) {
      return false;
    }

    for (final audience in audiences) {
      if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        audience: audience,
      )) {
        return false;
      }
    }

    final normalAudience = ThaiBetaEvidenceBadgeAudienceResolver.fromResearchAccess(
      ThaiResearchAccess.notAdmin,
    );
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.off,
      audience: normalAudience,
    )) {
      return false;
    }

    return true;
  }

  static bool auditReEnableInternalOnly() {
    const internal = ThaiBetaEvidenceBadgeAudience.internalTester();
    const anonymous = ThaiBetaEvidenceBadgeAudience.anonymous();
    const invited = ThaiBetaEvidenceBadgeAudience.invitedBetaTester();

    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      audience: internal,
    )) {
      return false;
    }

    for (final audience in [anonymous, invited]) {
      if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        audience: audience,
      )) {
        return false;
      }
    }

    final normalAudience = ThaiBetaEvidenceBadgeAudienceResolver.fromResearchAccess(
      ThaiResearchAccess.notAdmin,
    );
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      audience: normalAudience,
    )) {
      return false;
    }

    return true;
  }

  static int auditLeakageAcrossBundles(List<ThaiMirrorCanonEvidenceBundle> bundles) {
    var violations = 0;
    for (final bundle in bundles) {
      final base = ThaiPublicEvidenceBadgeControlledBetaQaValidator.auditFixture(
        fixtureId: 'rollback_drill',
        bundle: bundle,
      );
      violations += base.dataLeakageViolations.length;
    }
    return violations;
  }
}
