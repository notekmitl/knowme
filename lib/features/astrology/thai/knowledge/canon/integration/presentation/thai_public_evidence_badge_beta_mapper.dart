import '../thai_mirror_canon_evidence_bundle.dart';
import 'thai_public_evidence_badge_beta_view_model.dart';
import 'thai_public_evidence_badge_preview.dart';
import 'thai_public_evidence_badge_preview_mapper.dart';

/// Maps Canon evidence bundle to controlled-beta-safe badge view models.
abstract final class ThaiPublicEvidenceBadgeBetaMapper {
  static List<ThaiPublicEvidenceBadgeBetaViewModel> fromBundle(
    ThaiMirrorCanonEvidenceBundle bundle,
  ) {
    final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
    return previews
        .map(
          (preview) => ThaiPublicEvidenceBadgeBetaViewModel(
            sectionId: preview.sectionId,
            badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
            cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
            sourceLevel:
                ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
            eligible: preview.eligible,
          ),
        )
        .toList();
  }
}
