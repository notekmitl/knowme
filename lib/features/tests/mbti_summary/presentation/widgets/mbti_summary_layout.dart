/// Spacing rhythm for MBTI Summary fusion UI (8 / 12 / 20).
abstract final class MbtiSummaryLayout {
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 20;
  static const double sectionGap = 24;

  static const double cardPaddingH = 20;
  static const double cardPaddingV = 20;
  static const double cardTitleGap = 12;

  static const double heroPaddingH = 20;
  static const double heroPaddingV = 24;
  static const double heroEyebrowGap = 12;
  static const double heroIdentityRoleGap = 16;
  static const double heroRoleEnGap = 3;
  static const double heroSummaryGap = 20;

  /// Caps line length on wide layouts; on narrow screens uses nearly full inner width.
  static const double heroSynthesisIdealMaxWidth = 520;

  static const double profileSubtitleGap = 12;
  static const double profileBlockGap = 12;

  static const double insightBlockGap = 18;
  static const double insightHeadlineAnchorGap = 6;
  static const double insightAnchorBodyGap = 12;

  static const double disclosureGap = 6;
  static const double disclosureItemGap = 5;
  static const double confidenceExtrasTopGap = 14;

  static const double insightHeadlineSize = 16;
  static const double insightBodySize = 15;
  static const double profileBodySize = 14.5;

  /// Readable synthesis width: full card on phones, capped ideal measure on tablets.
  static double heroSynthesisMaxWidth(double innerWidth) {
    if (innerWidth <= heroSynthesisIdealMaxWidth) return innerWidth;
    return heroSynthesisIdealMaxWidth;
  }
}
