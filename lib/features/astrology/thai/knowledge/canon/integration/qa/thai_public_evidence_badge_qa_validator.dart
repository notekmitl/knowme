import '../presentation/thai_internal_evidence_badge.dart';
import '../presentation/thai_public_evidence_badge_preview.dart';
import '../presentation/thai_public_evidence_badge_preview_mapper.dart';
import '../thai_canon_evidence_attachment.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_mirror_canon_evidence_bundle.dart';

/// Per-fixture public evidence badge QA result.
class ThaiPublicEvidenceBadgeFixtureQaResult {
  const ThaiPublicEvidenceBadgeFixtureQaResult({
    required this.fixtureId,
    required this.eligiblePreviewCount,
    required this.eligibilityViolations,
    required this.copySafetyViolations,
    required this.dataLeakageViolations,
    required this.hiddenSummary,
  });

  final String fixtureId;
  final int eligiblePreviewCount;
  final List<String> eligibilityViolations;
  final List<String> copySafetyViolations;
  final List<String> dataLeakageViolations;
  final ThaiPublicEvidenceBadgeHiddenSummary hiddenSummary;

  bool get eligibilityPassed => eligibilityViolations.isEmpty;
  bool get copySafetyPassed => copySafetyViolations.isEmpty;
  bool get dataLeakagePassed => dataLeakageViolations.isEmpty;
  bool get passed =>
      eligibilityPassed && copySafetyPassed && dataLeakagePassed;
}

/// Aggregate public evidence badge QA audit.
class ThaiPublicEvidenceBadgeQaAudit {
  const ThaiPublicEvidenceBadgeQaAudit({
    required this.fixtureResults,
    required this.totalEligiblePreviews,
    required this.totalEligibilityViolations,
    required this.totalCopySafetyViolations,
    required this.totalDataLeakageViolations,
    required this.publicFingerprintUnchanged,
    required this.remediesHidden,
  });

  final List<ThaiPublicEvidenceBadgeFixtureQaResult> fixtureResults;
  final int totalEligiblePreviews;
  final int totalEligibilityViolations;
  final int totalCopySafetyViolations;
  final int totalDataLeakageViolations;
  final bool publicFingerprintUnchanged;
  final bool remediesHidden;

  bool get overallPassed =>
      totalEligibilityViolations == 0 &&
      totalCopySafetyViolations == 0 &&
      totalDataLeakageViolations == 0 &&
      publicFingerprintUnchanged &&
      remediesHidden &&
      fixtureResults.every((r) => r.passed);
}

/// Formal LEVEL 1 public evidence badge QA validator.
abstract final class ThaiPublicEvidenceBadgeQaValidator {
  static ThaiPublicEvidenceBadgeFixtureQaResult auditFixture({
    required String fixtureId,
    required ThaiMirrorCanonEvidenceBundle bundle,
  }) {
    final eligibilityViolations = <String>[];
    final copySafetyViolations = <String>[];
    final dataLeakageViolations = <String>[];

    final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
    final hidden =
        ThaiPublicEvidenceBadgePreviewMapper.hiddenSummaryFromBundle(bundle);

    _auditEligibility(bundle, eligibilityViolations);
    _auditCopySafety(previews, copySafetyViolations);
    _auditDataLeakage(bundle, previews, dataLeakageViolations);

    return ThaiPublicEvidenceBadgeFixtureQaResult(
      fixtureId: fixtureId,
      eligiblePreviewCount: previews.length,
      eligibilityViolations: eligibilityViolations,
      copySafetyViolations: copySafetyViolations,
      dataLeakageViolations: dataLeakageViolations,
      hiddenSummary: hidden,
    );
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

      if (_mustNeverProducePreview(attachment, badge) && eligible) {
        violations.add(
          'ineligible attachment produced preview candidate: '
          '${attachment.signalId} (${badge.wire})',
        );
      }

      if (eligible &&
          attachment.evidenceType != ThaiCanonEvidenceType.mahabhutPosition &&
          attachment.evidenceType != ThaiCanonEvidenceType.planetSignification) {
        violations.add(
          'eligible preview from non-mahabhut/planet domain: '
          '${attachment.signalId}',
        );
      }

      if (eligible && badge != ThaiInternalEvidenceBadgeCategory.canonSupported) {
        violations.add(
          'eligible preview without CANON_SUPPORTED: ${attachment.signalId}',
        );
      }
    }

    final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
    for (final preview in previews) {
      if (!preview.eligible) {
        violations.add('preview marked ineligible: ${preview.sectionId}');
      }
      if (preview.sourceLevel !=
          ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge) {
        violations.add('preview not LEVEL_1: ${preview.sectionId}');
      }
      if (!preview.internalOnlyPreview) {
        violations.add('preview not internal-only: ${preview.sectionId}');
      }
    }
  }

  static bool _mustNeverProducePreview(
    ThaiCanonEvidenceAttachment attachment,
    ThaiInternalEvidenceBadgeCategory badge,
  ) {
    if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
      return true;
    }
    if (attachment.evidenceType == ThaiCanonEvidenceType.taksa) return true;
    if (attachment.evidenceType ==
        ThaiCanonEvidenceType.periodStatusStructural) {
      return true;
    }
    if (attachment.signalId.contains('mahabhuta_khumsap') ||
        attachment.signalId.contains('khumsap') ||
        attachment.signalId.contains('mahabhuta_thaya')) {
      return true;
    }
    if (attachment.signalId.toLowerCase().contains('taksa')) return true;
    if (attachment.signalId.toLowerCase().contains('periodstatus')) {
      return true;
    }
    for (final ref in attachment.evidenceRefs) {
      if (ref.domain == 'lookupTables') return true;
    }

    return switch (badge) {
      ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported ||
      ThaiInternalEvidenceBadgeCategory.canonDerivedInternal ||
      ThaiInternalEvidenceBadgeCategory.partialCanonSupport ||
      ThaiInternalEvidenceBadgeCategory.outOfCanonScope ||
      ThaiInternalEvidenceBadgeCategory.blockedAmbiguous ||
      ThaiInternalEvidenceBadgeCategory.blockedSourceConflict ||
      ThaiInternalEvidenceBadgeCategory.internalOnly ||
      ThaiInternalEvidenceBadgeCategory.remedyHidden ||
      ThaiInternalEvidenceBadgeCategory.noCanonEvidence =>
        true,
      ThaiInternalEvidenceBadgeCategory.canonSupported => false,
    };
  }

  static void _auditCopySafety(
    List<ThaiPublicEvidenceBadgePreview> previews,
    List<String> violations,
  ) {
    for (final preview in previews) {
      if (preview.explanationText != ThaiPublicEvidenceBadgeCopy.cautionCopy) {
        violations.add(
          'missing required caution copy on ${preview.sectionId}',
        );
      }
      if (!ThaiPublicEvidenceBadgeCopy.allowedBadgeLabels
          .contains(preview.badgeLabel)) {
        violations.add('unapproved badge label on ${preview.sectionId}');
      }

      final text = preview.badgeLabel;
      for (final forbidden in ThaiPublicEvidenceBadgeCopy.forbiddenWording) {
        if (text.contains(forbidden)) {
          violations.add(
            'forbidden wording "$forbidden" on ${preview.sectionId}',
          );
        }
      }
    }
  }

  static void _auditDataLeakage(
    ThaiMirrorCanonEvidenceBundle bundle,
    List<ThaiPublicEvidenceBadgePreview> previews,
    List<String> violations,
  ) {
    final serialized = previews
        .map((p) => '${p.sectionId}|${p.badgeLabel}|${p.explanationText}')
        .join('\n');

    if (RegExp(r'\bp\d+\b').hasMatch(serialized)) {
      violations.add('page reference leaked in preview text');
    }
    if (serialized.contains('%')) {
      violations.add('confidence percentage leaked in preview text');
    }
    if (RegExp(r'unit\.[a-z0-9_]+').hasMatch(serialized)) {
      violations.add('raw unit id leaked in preview text');
    }
    if (RegExp(r'planet\.[a-z]+|mahabhutPosition\.[a-z]+')
        .hasMatch(serialized)) {
      violations.add('raw ontology id leaked in preview text');
    }
    if (serialized.contains('ดวงขึ้น') || serialized.contains('ดวงตก')) {
      violations.add('rise/fall label leaked in preview text');
    }

    for (final ref in bundle.attachments.expand((a) => a.evidenceRefs)) {
      if (ref.condition != null &&
          ref.condition!.length > 40 &&
          serialized.contains(ref.condition!)) {
        violations.add('source-like prose leaked from ${ref.unitId}');
      }
    }
  }
}
