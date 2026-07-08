import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/application/thai_research_admin_access.dart';

import '../presentation/thai_public_evidence_badge_beta_gate.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import 'thai_public_evidence_badge_controlled_beta_qa_validator.dart';

/// Per-fixture internal-only activation QA result.
class ThaiPublicEvidenceBadgeInternalOnlyActivationFixtureQaResult {
  const ThaiPublicEvidenceBadgeInternalOnlyActivationFixtureQaResult({
    required this.fixtureId,
    required this.eligibleBetaBadgeCount,
    required this.eligibilityViolations,
    required this.copySafetyViolations,
    required this.dataLeakageViolations,
  });

  final String fixtureId;
  final int eligibleBetaBadgeCount;
  final List<String> eligibilityViolations;
  final List<String> copySafetyViolations;
  final List<String> dataLeakageViolations;

  bool get passed =>
      eligibilityViolations.isEmpty &&
      copySafetyViolations.isEmpty &&
      dataLeakageViolations.isEmpty;
}

/// Aggregate internal-only activation QA audit.
class ThaiPublicEvidenceBadgeInternalOnlyActivationQaAudit {
  const ThaiPublicEvidenceBadgeInternalOnlyActivationQaAudit({
    required this.fixtureResults,
    required this.activationStatePassed,
    required this.audienceIsolationPassed,
    required this.invitedBetaInactive,
    required this.rollbackPassed,
    required this.totalEligibleBetaBadges,
    required this.totalEligibilityViolations,
    required this.totalCopySafetyViolations,
    required this.totalDataLeakageViolations,
    required this.publicFingerprintUnchanged,
    required this.remediesHidden,
  });

  final List<ThaiPublicEvidenceBadgeInternalOnlyActivationFixtureQaResult>
      fixtureResults;
  final bool activationStatePassed;
  final bool audienceIsolationPassed;
  final bool invitedBetaInactive;
  final bool rollbackPassed;
  final int totalEligibleBetaBadges;
  final int totalEligibilityViolations;
  final int totalCopySafetyViolations;
  final int totalDataLeakageViolations;
  final bool publicFingerprintUnchanged;
  final bool remediesHidden;

  bool get overallPassed =>
      activationStatePassed &&
      audienceIsolationPassed &&
      invitedBetaInactive &&
      rollbackPassed &&
      totalEligibilityViolations == 0 &&
      totalCopySafetyViolations == 0 &&
      totalDataLeakageViolations == 0 &&
      publicFingerprintUnchanged &&
      remediesHidden &&
      fixtureResults.every((r) => r.passed);
}

/// Formal QA validator for activated internal-only phase.
abstract final class ThaiPublicEvidenceBadgeInternalOnlyActivationQaValidator {
  static bool auditActivationState() {
    if (ThaiEvidenceBadgeActivation.configuredState != 'internal_only') {
      return false;
    }
    ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
    if (ThaiEvidenceBadgeFeatureFlag.state !=
        ThaiEvidenceBadgeFeatureFlagState.internalOnly) {
      return false;
    }
    if (ThaiEvidenceBadgeFeatureFlag.configuredState !=
        ThaiEvidenceBadgeFeatureFlagState.internalOnly) {
      return false;
    }
    return true;
  }

  static bool auditAudienceIsolation() {
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

    final anonymousFromSignedOut =
        ThaiBetaEvidenceBadgeAudienceResolver.fromResearchAccess(
      ThaiResearchAccess.signedOut,
    );
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      audience: anonymousFromSignedOut,
    )) {
      return false;
    }

    return true;
  }

  static bool auditInvitedBetaInactive() {
    if (ThaiEvidenceBadgeActivation.configuredState == 'invited_beta') {
      return false;
    }
    ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
    return ThaiEvidenceBadgeFeatureFlag.state !=
        ThaiEvidenceBadgeFeatureFlagState.invitedBeta;
  }

  static bool auditRollbackBehavior() {
    ThaiEvidenceBadgeFeatureFlag.state =
        ThaiEvidenceBadgeFeatureFlagState.internalOnly;
    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
    )) {
      return false;
    }
    ThaiEvidenceBadgeFeatureFlag.state = ThaiEvidenceBadgeFeatureFlagState.off;
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
    )) {
      return false;
    }
    return true;
  }

  static ThaiPublicEvidenceBadgeInternalOnlyActivationFixtureQaResult auditFixture({
    required String fixtureId,
    required ThaiMirrorCanonEvidenceBundle bundle,
  }) {
    final base = ThaiPublicEvidenceBadgeControlledBetaQaValidator.auditFixture(
      fixtureId: fixtureId,
      bundle: bundle,
    );
    return ThaiPublicEvidenceBadgeInternalOnlyActivationFixtureQaResult(
      fixtureId: base.fixtureId,
      eligibleBetaBadgeCount: base.eligibleBetaBadgeCount,
      eligibilityViolations: base.eligibilityViolations,
      copySafetyViolations: base.copySafetyViolations,
      dataLeakageViolations: base.dataLeakageViolations,
    );
  }
}
