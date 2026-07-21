import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';

import '../presentation/thai_internal_evidence_badge.dart';
import '../presentation/thai_public_evidence_badge_beta_gate.dart';
import '../presentation/thai_public_evidence_badge_beta_mapper.dart';
import '../presentation/thai_public_evidence_badge_preview.dart';
import '../presentation/thai_public_evidence_badge_preview_mapper.dart';
import '../thai_canon_evidence_attachment.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_mirror_canon_evidence_bundle.dart';

/// Per-fixture controlled beta QA result.
class ThaiPublicEvidenceBadgeControlledBetaFixtureQaResult {
  const ThaiPublicEvidenceBadgeControlledBetaFixtureQaResult({
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

/// Aggregate controlled beta QA audit.
class ThaiPublicEvidenceBadgeControlledBetaQaAudit {
  const ThaiPublicEvidenceBadgeControlledBetaQaAudit({
    required this.fixtureResults,
    required this.flagQaPassed,
    required this.audienceGatingPassed,
    required this.defaultFlagOff,
    required this.totalEligibleBetaBadges,
    required this.totalEligibilityViolations,
    required this.totalCopySafetyViolations,
    required this.totalDataLeakageViolations,
    required this.telemetrySafe,
    required this.publicFingerprintUnchanged,
    required this.remediesHidden,
  });

  final List<ThaiPublicEvidenceBadgeControlledBetaFixtureQaResult> fixtureResults;
  final bool flagQaPassed;
  final bool audienceGatingPassed;
  final bool defaultFlagOff;
  final int totalEligibleBetaBadges;
  final int totalEligibilityViolations;
  final int totalCopySafetyViolations;
  final int totalDataLeakageViolations;
  final bool telemetrySafe;
  final bool publicFingerprintUnchanged;
  final bool remediesHidden;

  bool get overallPassed =>
      flagQaPassed &&
      audienceGatingPassed &&
      defaultFlagOff &&
      totalEligibilityViolations == 0 &&
      totalCopySafetyViolations == 0 &&
      totalDataLeakageViolations == 0 &&
      telemetrySafe &&
      publicFingerprintUnchanged &&
      remediesHidden &&
      fixtureResults.every((r) => r.passed);
}

/// Formal QA validator for controlled beta implementation.
abstract final class ThaiPublicEvidenceBadgeControlledBetaQaValidator {
  static const allowedTelemetryEvents = <String>{
    'thai_evidence_badge_rendered',
    'thai_evidence_badge_seen',
    'thai_evidence_badge_feedback_started',
  };

  static const forbiddenTelemetryKeys = <String>[
    'unitId',
    'unit_id',
    'sourcePage',
    'source_page',
    'evidenceRef',
    'remedy',
    'birthDate',
    'birthTime',
    'birthPlace',
    'prediction',
  ];

  static ThaiPublicEvidenceBadgeControlledBetaFixtureQaResult auditFixture({
    required String fixtureId,
    required ThaiMirrorCanonEvidenceBundle bundle,
  }) {
    final eligibilityViolations = <String>[];
    final copyViolations = <String>[];
    final leakageViolations = <String>[];

    _auditEligibility(bundle, eligibilityViolations);

    final betaBadges = ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle);
    _auditCopySafety(betaBadges, copyViolations);
    _auditDataLeakage(betaBadges, leakageViolations);

    return ThaiPublicEvidenceBadgeControlledBetaFixtureQaResult(
      fixtureId: fixtureId,
      eligibleBetaBadgeCount: betaBadges.length,
      eligibilityViolations: eligibilityViolations,
      copySafetyViolations: copyViolations,
      dataLeakageViolations: leakageViolations,
    );
  }

  static bool auditFlagBehavior() {
    if (ThaiEvidenceBadgeFeatureFlag.parse(null) !=
        ThaiEvidenceBadgeFeatureFlagState.off) {
      return false;
    }
    if (ThaiEvidenceBadgeFeatureFlag.parse('') !=
        ThaiEvidenceBadgeFeatureFlagState.off) {
      return false;
    }
    if (ThaiEvidenceBadgeFeatureFlag.parse('bogus') !=
        ThaiEvidenceBadgeFeatureFlagState.off) {
      return false;
    }
    ThaiEvidenceBadgeFeatureFlag.resetToDefault();
    if (ThaiEvidenceBadgeFeatureFlag.state !=
        ThaiEvidenceBadgeFeatureFlagState.off) {
      return false;
    }
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges()) {
      return false;
    }
    return true;
  }

  static bool auditAudienceGating() {
    const anonymous = ThaiBetaEvidenceBadgeAudience.anonymous();
    const internal = ThaiBetaEvidenceBadgeAudience.internalTester();
    const invited = ThaiBetaEvidenceBadgeAudience.invitedBetaTester();

    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.off,
      audience: internal,
    )) {
      return false;
    }

    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      audience: internal,
    )) {
      return false;
    }
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      audience: anonymous,
    )) {
      return false;
    }

    if (!ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      audience: invited,
    )) {
      return false;
    }
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      audience: anonymous,
    )) {
      return false;
    }
    if (ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      audience: internal,
    )) {
      return false;
    }

    return true;
  }

  static bool auditTelemetrySafety(List<Map<String, Object?>> captured) {
    for (final event in captured) {
      final name = event['name'] as String?;
      if (name == null || !allowedTelemetryEvents.contains(name)) {
        return false;
      }
      final props = event['props'];
      if (props is Map) {
        for (final key in props.keys) {
          final lower = key.toString().toLowerCase();
          for (final forbidden in forbiddenTelemetryKeys) {
            if (lower.contains(forbidden.toLowerCase())) {
              return false;
            }
          }
          if (RegExp(r'unit\.|planet\.|p\d+').hasMatch(props[key].toString())) {
            return false;
          }
        }
      }
    }
    return true;
  }

  static void _auditEligibility(
    ThaiMirrorCanonEvidenceBundle bundle,
    List<String> violations,
  ) {
    for (final attachment in bundle.attachments) {
      final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
        attachment,
        trace: bundle.trace,
      );
      final eligible = ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
        attachment,
        bundle: bundle,
      );
      final betaEligible = eligible &&
          badge == ThaiInternalEvidenceBadgeCategory.canonSupported &&
          (attachment.evidenceType ==
                  ThaiCanonEvidenceType.mahabhutPosition ||
              attachment.evidenceType ==
                  ThaiCanonEvidenceType.planetSignification);

      if (_mustNeverRender(attachment, badge) && betaEligible) {
        violations.add(
          'ineligible produced beta candidate: ${attachment.signalId}',
        );
      }
    }

    final betaBadges = ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle);
    for (final badge in betaBadges) {
      if (badge.badgeLabel != ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel) {
        violations.add('beta label not fixed: ${badge.sectionId}');
      }
    }
  }

  static bool _mustNeverRender(
    ThaiCanonEvidenceAttachment attachment,
    ThaiInternalEvidenceBadgeCategory badge,
  ) {
    if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal ||
        attachment.evidenceType == ThaiCanonEvidenceType.taksa ||
        attachment.evidenceType == ThaiCanonEvidenceType.periodStatusStructural) {
      return true;
    }
    if (attachment.signalId.contains('khumsap') ||
        attachment.signalId.contains('mahabhuta_khumsap') ||
        attachment.signalId.contains('taksa')) {
      return true;
    }
    for (final ref in attachment.evidenceRefs) {
      if (ref.domain == 'lookupTables') return true;
    }
    return badge != ThaiInternalEvidenceBadgeCategory.canonSupported;
  }

  static void _auditCopySafety(
    List<dynamic> betaBadges,
    List<String> violations,
  ) {
    for (final badge in betaBadges) {
      if (badge.cautionCopy != ThaiPublicEvidenceBadgeCopy.cautionCopy) {
        violations.add('missing caution on ${badge.sectionId}');
      }
      if (badge.badgeLabel != ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel) {
        violations.add('wrong label on ${badge.sectionId}');
      }
      for (final forbidden in ThaiPublicEvidenceBadgeCopy.forbiddenWording) {
        if (badge.badgeLabel.contains(forbidden)) {
          violations.add('forbidden "$forbidden" on ${badge.sectionId}');
        }
      }
    }
  }

  static void _auditDataLeakage(
    List<dynamic> betaBadges,
    List<String> violations,
  ) {
    final serialized = betaBadges
        .map((b) => '${b.sectionId}|${b.badgeLabel}|${b.cautionCopy}')
        .join('\n');
    if (RegExp(r'\bp\d+\b').hasMatch(serialized)) {
      violations.add('page reference in beta output');
    }
    if (serialized.contains('%')) {
      violations.add('confidence percentage in beta output');
    }
    if (RegExp(r'unit\.|planet\.|mahabhutPosition\.').hasMatch(serialized)) {
      violations.add('ontology/unit id in beta output');
    }
    if (serialized.contains('ดวงขึ้น') || serialized.contains('ดวงตก')) {
      violations.add('rise/fall in beta output');
    }
  }
}
