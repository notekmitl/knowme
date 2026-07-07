import 'thai_public_evidence_badge_preview.dart';

/// Safe LEVEL 1 badge view model for controlled beta UI — no raw evidence.
class ThaiPublicEvidenceBadgeBetaViewModel {
  const ThaiPublicEvidenceBadgeBetaViewModel({
    required this.sectionId,
    required this.badgeLabel,
    required this.cautionCopy,
    this.sourceLevel = ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
    this.eligible = true,
  });

  final String sectionId;
  final String badgeLabel;
  final String cautionCopy;
  final ThaiPublicEvidenceDisclosureLevel sourceLevel;
  final bool eligible;
}
