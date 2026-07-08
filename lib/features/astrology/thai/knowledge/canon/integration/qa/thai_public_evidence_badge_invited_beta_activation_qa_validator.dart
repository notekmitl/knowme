import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_invited_tester_registry.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/application/thai_research_admin_access.dart';

import '../presentation/thai_public_evidence_badge_beta_gate.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import 'thai_public_evidence_badge_controlled_beta_qa_validator.dart';

/// Per-fixture invited-beta activation QA result.
class ThaiPublicEvidenceBadgeInvitedBetaActivationFixtureQaResult {
  const ThaiPublicEvidenceBadgeInvitedBetaActivationFixtureQaResult({
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

/// Aggregate invited-beta activation QA audit.
class ThaiPublicEvidenceBadgeInvitedBetaActivationQaAudit {
  const ThaiPublicEvidenceBadgeInvitedBetaActivationQaAudit({
    required this.fixtureResults,
    required this.activationStatePassed,
    required this.audienceIsolationPassed,
    required this.registryPassed,
    required this.rollbackPassed,
    required this.internalOnlyPreserved,
    required this.invalidFlagOff,
    required this.totalEligibleBetaBadges,
    required this.totalEligibilityViolations,
    required this.totalCopySafetyViolations,
    required this.totalDataLeakageViolations,
    required this.publicFingerprintUnchanged,
    required this.remediesHidden,
  });

  final List<ThaiPublicEvidenceBadgeInvitedBetaActivationFixtureQaResult>
      fixtureResults;
  final bool activationStatePassed;
  final bool audienceIsolationPassed;
  final bool registryPassed;
  final bool rollbackPassed;
  final bool internalOnlyPreserved;
  final bool invalidFlagOff;
  final int totalEligibleBetaBadges;
  final int totalEligibilityViolations;
  final int totalCopySafetyViolations;
  final int totalDataLeakageViolations;
  final bool publicFingerprintUnchanged;
  final bool remediesHidden;

  bool get overallPassed =>
      activationStatePassed &&
      audienceIsolationPassed &&
      registryPassed &&
      rollbackPassed &&
      internalOnlyPreserved &&
      invalidFlagOff &&
      totalEligibilityViolations == 0 &&
      totalCopySafetyViolations == 0 &&
      totalDataLeakageViolations == 0 &&
      publicFingerprintUnchanged &&
      remediesHidden &&
      fixtureResults.every((r) => r.passed);
}

/// Formal QA validator for activated invited-beta phase.
abstract final class ThaiPublicEvidenceBadgeInvitedBetaActivationQaValidator {
  static const _qaInvitedUid = 'qa-invited-beta-uid';

  static bool auditActivationState() {
    if (ThaiEvidenceBadgeActivation.configuredState != 'invited_beta') {
      return false;
    }
    ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
    if (ThaiEvidenceBadgeFeatureFlag.state !=
        ThaiEvidenceBadgeFeatureFlagState.invitedBeta) {
      return false;
    }
    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
    )) {
      return false;
    }
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
    )) {
      return false;
    }
    return true;
  }

  static bool auditAudienceIsolation() {
    const invited = ThaiBetaEvidenceBadgeAudience.invitedBetaTester();
    const anonymous = ThaiBetaEvidenceBadgeAudience.anonymous();
    const internal = ThaiBetaEvidenceBadgeAudience.internalTester();

    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      audience: invited,
    )) {
      return false;
    }

    for (final audience in [anonymous, internal]) {
      if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
        flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
        audience: audience,
      )) {
        return false;
      }
    }

    final normalAudience = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
      researchAccess: ThaiResearchAccess.notAdmin,
      userId: 'normal-user-not-on-list',
    );
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      audience: normalAudience,
    )) {
      return false;
    }

    final adminNotInvited = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
      researchAccess: ThaiResearchAccess.admin,
      userId: 'admin-not-on-invite-list',
    );
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      audience: adminNotInvited,
    )) {
      return false;
    }

    return true;
  }

  static bool auditRegistryBehavior() {
    ThaiBetaInvitedTesterRegistry.reset();

    if (ThaiBetaInvitedTesterRegistry.isInvited(null)) {
      return false;
    }
    if (ThaiBetaInvitedTesterRegistry.isInvited(_qaInvitedUid)) {
      return false;
    }

    ThaiBetaInvitedTesterRegistry.invite(_qaInvitedUid);
    if (!ThaiBetaInvitedTesterRegistry.isInvited(_qaInvitedUid)) {
      return false;
    }

    final audience = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
      researchAccess: ThaiResearchAccess.notAdmin,
      userId: _qaInvitedUid,
    );
    if (!audience.isInvitedBetaTester) {
      return false;
    }

    ThaiBetaInvitedTesterRegistry.revoke(_qaInvitedUid);
    if (ThaiBetaInvitedTesterRegistry.isInvited(_qaInvitedUid)) {
      return false;
    }

    ThaiBetaInvitedTesterRegistry.invite(_qaInvitedUid);
    ThaiBetaInvitedTesterRegistry.reset();
    if (ThaiBetaInvitedTesterRegistry.isInvited(_qaInvitedUid)) {
      return false;
    }

    return true;
  }

  static bool auditRollbackBehavior() {
    const invited = ThaiBetaEvidenceBadgeAudience.invitedBetaTester();
    const internal = ThaiBetaEvidenceBadgeAudience.internalTester();
    const anonymous = ThaiBetaEvidenceBadgeAudience.anonymous();
    final normal = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
      researchAccess: ThaiResearchAccess.notAdmin,
      userId: 'normal-user',
    );

    ThaiEvidenceBadgeFeatureFlag.state =
        ThaiEvidenceBadgeFeatureFlagState.invitedBeta;
    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      audience: invited,
    )) {
      return false;
    }

    ThaiEvidenceBadgeFeatureFlag.state = ThaiEvidenceBadgeFeatureFlagState.off;
    for (final audience in [invited, internal, anonymous, normal]) {
      if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
        audience: audience,
      )) {
        return false;
      }
    }
    return true;
  }

  static bool auditInternalOnlyPreserved() {
    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
    )) {
      return false;
    }
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
    )) {
      return false;
    }
    return true;
  }

  static bool auditInvalidFlagOff() {
    if (ThaiEvidenceBadgeFeatureFlag.parse('bogus') !=
        ThaiEvidenceBadgeFeatureFlagState.off) {
      return false;
    }
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlag.parse('bogus'),
      audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
    )) {
      return false;
    }
    return true;
  }

  static ThaiPublicEvidenceBadgeInvitedBetaActivationFixtureQaResult auditFixture({
    required String fixtureId,
    required ThaiMirrorCanonEvidenceBundle bundle,
  }) {
    final base = ThaiPublicEvidenceBadgeControlledBetaQaValidator.auditFixture(
      fixtureId: fixtureId,
      bundle: bundle,
    );
    return ThaiPublicEvidenceBadgeInvitedBetaActivationFixtureQaResult(
      fixtureId: base.fixtureId,
      eligibleBetaBadgeCount: base.eligibleBetaBadgeCount,
      eligibilityViolations: base.eligibilityViolations,
      copySafetyViolations: base.copySafetyViolations,
      dataLeakageViolations: base.dataLeakageViolations,
    );
  }
}
