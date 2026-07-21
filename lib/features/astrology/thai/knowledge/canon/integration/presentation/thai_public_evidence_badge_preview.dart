/// LEVEL 1 public-safe evidence badge preview — internal beta only.
///
/// Not user-facing. See [docs/THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md].
enum ThaiPublicEvidenceDisclosureLevel {
  level0InternalOnly,
  level1PublicSummaryBadge,
}

/// One internal-beta preview of a future public evidence summary badge.
class ThaiPublicEvidenceBadgePreview {
  const ThaiPublicEvidenceBadgePreview({
    required this.sectionId,
    required this.badgeLabel,
    required this.explanationText,
    required this.eligible,
    this.sourceLevel = ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
    this.internalOnlyPreview = true,
    this.blockedReason,
  });

  final String sectionId;
  final String badgeLabel;
  final String explanationText;
  final bool eligible;
  final ThaiPublicEvidenceDisclosureLevel sourceLevel;
  final bool internalOnlyPreview;
  final String? blockedReason;
}

/// Policy-approved copy for LEVEL 1 preview badges (not implemented on public UI).
abstract final class ThaiPublicEvidenceBadgeCopy {
  static const cautionCopy =
      'ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์';

  static const primaryBadgeLabel = 'มีแหล่งอ้างอิงใน Canon';

  static const allowedBadgeLabels = <String>[
    primaryBadgeLabel,
    'อ้างอิงจากฐานความรู้ที่ตรวจแล้ว',
    'ตรวจสอบกับ Canon แล้ว',
    'มีหลักฐานอ้างอิงภายในระบบ',
  ];

  static const forbiddenWording = <String>[
    'แม่นแน่นอน',
    'ยืนยันว่าแม่น',
    'ฟันธง',
    'พิสูจน์แล้ว',
    '100%',
    'ต้องทำ',
    'ห้ามทำ',
    'โชคร้ายแน่นอน',
    'แก้แล้วดีขึ้นแน่นอน',
    'การันตี',
    'แน่นอน',
  ];

  static const previewHeader =
      'Public Evidence Badge Preview — Internal Beta Only';

  static const previewPolicyWarning =
      'This preview is not visible to public users.';
}

/// Counts of categories hidden from LEVEL 1 public preview.
class ThaiPublicEvidenceBadgeHiddenSummary {
  const ThaiPublicEvidenceBadgeHiddenSummary({
    required this.hiddenRemedies,
    required this.hiddenTaksa,
    required this.hiddenKhumsap,
    required this.hiddenRiseFall,
    required this.blockedAmbiguous,
    required this.blockedSourceConflict,
    required this.outOfCanonScope,
  });

  final int hiddenRemedies;
  final int hiddenTaksa;
  final int hiddenKhumsap;
  final int hiddenRiseFall;
  final int blockedAmbiguous;
  final int blockedSourceConflict;
  final int outOfCanonScope;
}
