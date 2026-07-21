import '../thai_canon_evidence_attachment.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import '../thai_mahabhut_khumsap_runtime_key.dart';
import 'thai_canon_evidence_review_summary.dart';
import 'thai_internal_evidence_badge.dart';
import 'thai_public_evidence_badge_preview.dart';

/// Maps internal Canon evidence to LEVEL 1 public-safe badge previews.
///
/// Presentation-only — does not mutate evidence or enable public display.
abstract final class ThaiPublicEvidenceBadgePreviewMapper {
  static List<ThaiPublicEvidenceBadgePreview> fromBundle(
    ThaiMirrorCanonEvidenceBundle bundle,
  ) {
    final previews = <ThaiPublicEvidenceBadgePreview>[];
    final seen = <String>{};

    for (final attachment in bundle.attachments) {
      final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
        attachment,
        trace: bundle.trace,
      );
      final sectionId = attachment.sectionId ?? 'profile';
      final dedupeKey = '$sectionId:${attachment.signalId}';

      final blocked = _blockedReason(attachment, badge);
      if (blocked != null) {
        continue;
      }

      if (badge != ThaiInternalEvidenceBadgeCategory.canonSupported) {
        continue;
      }
      if (!_isStrongMahabhutOrPlanetDomain(attachment)) {
        continue;
      }
      if (seen.contains(dedupeKey)) continue;
      seen.add(dedupeKey);

      previews.add(
        ThaiPublicEvidenceBadgePreview(
          sectionId: sectionId,
          badgeLabel: _badgeLabelFor(sectionId, attachment.signalId),
          explanationText: ThaiPublicEvidenceBadgeCopy.cautionCopy,
          eligible: true,
          sourceLevel: ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
          internalOnlyPreview: true,
        ),
      );
    }

    previews.sort((a, b) {
      final section = a.sectionId.compareTo(b.sectionId);
      if (section != 0) return section;
      return a.badgeLabel.compareTo(b.badgeLabel);
    });
    return previews;
  }

  static ThaiPublicEvidenceBadgeHiddenSummary hiddenSummaryFromBundle(
    ThaiMirrorCanonEvidenceBundle bundle,
  ) {
    final summary = ThaiCanonEvidenceReviewSummary.fromBundle(bundle);
    final badgeSummary = summary.badgeSummary;

    final riseFallAttachments = bundle.attachments
        .where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural,
        )
        .length;

    return ThaiPublicEvidenceBadgeHiddenSummary(
      hiddenRemedies: summary.remedySkippedCount,
      hiddenTaksa: summary.taksaEvidenceAttachedCount +
          summary.taksaEvidenceTraceOnlyCount,
      hiddenKhumsap: summary.khumsapEvidenceAttachedCount,
      hiddenRiseFall: riseFallAttachments +
          badgeSummary.count(
            ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported,
          ),
      blockedAmbiguous: summary.blockedAmbiguousCount,
      blockedSourceConflict: summary.blockedSourceConflictCount,
      outOfCanonScope:
          badgeSummary.count(ThaiInternalEvidenceBadgeCategory.outOfCanonScope),
    );
  }

  static String? blockedReasonForAttachment(
    ThaiCanonEvidenceAttachment attachment, {
    ThaiMirrorCanonEvidenceBundle? bundle,
  }) {
    final trace = bundle?.trace;
    final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
      attachment,
      trace: trace,
    );
    return _blockedReason(attachment, badge);
  }

  static bool isEligibleCanonSupported(
    ThaiCanonEvidenceAttachment attachment, {
    ThaiMirrorCanonEvidenceBundle? bundle,
  }) {
    final trace = bundle?.trace;
    final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
      attachment,
      trace: trace,
    );
    if (badge != ThaiInternalEvidenceBadgeCategory.canonSupported) {
      return false;
    }
    if (_blockedReason(attachment, badge) != null) return false;
    return _isStrongMahabhutOrPlanetDomain(attachment);
  }

  static String? _blockedReason(
    ThaiCanonEvidenceAttachment attachment,
    ThaiInternalEvidenceBadgeCategory badge,
  ) {
    if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
      return 'remedy_hidden';
    }
    if (attachment.evidenceType == ThaiCanonEvidenceType.taksa) {
      return 'taksa_hidden';
    }
    if (attachment.evidenceType == ThaiCanonEvidenceType.periodStatusStructural) {
      return 'rise_fall_hidden';
    }
    if (_isKhumsapSignal(attachment)) {
      return 'khumsap_hidden';
    }
    if (_isRiseFallSignal(attachment.signalId)) {
      return 'rise_fall_hidden';
    }
    if (_isTaksaSignal(attachment)) {
      return 'taksa_hidden';
    }
    if (_hasLookupTableEvidence(attachment)) {
      return 'lookup_table_hidden';
    }
    if (badge != ThaiInternalEvidenceBadgeCategory.canonSupported) {
      return 'internal_badge:${badge.wire}';
    }
    if (!_isStrongMahabhutOrPlanetDomain(attachment)) {
      return 'domain_not_eligible';
    }
    return null;
  }

  static bool _isStrongMahabhutOrPlanetDomain(
    ThaiCanonEvidenceAttachment attachment,
  ) {
    return attachment.evidenceType == ThaiCanonEvidenceType.mahabhutPosition ||
        attachment.evidenceType == ThaiCanonEvidenceType.planetSignification;
  }

  static bool _isKhumsapSignal(ThaiCanonEvidenceAttachment attachment) {
    final signal = attachment.signalId;
    return ThaiMahabhutKhumsapRuntimeKey.isKhumsapRuntimeKey(
          _extractContentKey(signal),
        ) ||
        signal.contains(ThaiMahabhutKhumsapRuntimeKey.khumsap) ||
        signal.contains('khumsap') ||
        signal.contains('mahabhuta_thaya');
  }

  static bool _isTaksaSignal(ThaiCanonEvidenceAttachment attachment) {
    final signal = attachment.signalId.toLowerCase();
    return attachment.sectionId == 'taksaInternal' ||
        signal.contains('taksa') ||
        signal.contains('taksarotation');
  }

  static bool _hasLookupTableEvidence(ThaiCanonEvidenceAttachment attachment) {
    if (attachment.signalId.contains('lookup') ||
        attachment.signalId.contains('lookupTable')) {
      return true;
    }
    for (final ref in attachment.evidenceRefs) {
      if (ref.domain == 'lookupTables') return true;
      if (ref.unitId.startsWith('lookup.')) return true;
    }
    return false;
  }

  static bool _isRiseFallSignal(String signalId) {
    final lower = signalId.toLowerCase();
    return lower.contains('periodstatus') ||
        lower.contains('ดวงขึ้น') ||
        lower.contains('ดวงตก') ||
        lower.contains('risefall') ||
        lower.contains('runtimestatus');
  }

  static String? _extractContentKey(String signalId) {
    final parts = signalId.split(':');
    if (parts.length >= 3 && parts[1] == 'mahabhuta_position') {
      return parts[2];
    }
    return null;
  }

  static String _badgeLabelFor(String sectionId, String signalId) {
    final labels = ThaiPublicEvidenceBadgeCopy.allowedBadgeLabels;
    final index =
        (sectionId.hashCode ^ signalId.hashCode).abs() % labels.length;
    return labels[index];
  }
}
