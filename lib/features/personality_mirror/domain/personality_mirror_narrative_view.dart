/// Deterministic narrative output for Personality Mirror V1 (PF-6).
class PersonalityMirrorNarrativeView {
  const PersonalityMirrorNarrativeView({
    required this.heroParagraphs,
    required this.patternCards,
    required this.perspectiveCards,
    required this.lensContributionLines,
    required this.depthHint,
    required this.disclosure,
    required this.confidenceToneKey,
  });

  final List<String> heroParagraphs;
  final List<PersonalityMirrorPatternCard> patternCards;
  final List<PersonalityMirrorPerspectiveCard> perspectiveCards;
  final List<String> lensContributionLines;
  final String depthHint;
  final String disclosure;

  /// Internal i18n key for confidence tone (not shown as raw band label).
  final String confidenceToneKey;
}

/// Strong cross-lens pattern card (agreement).
class PersonalityMirrorPatternCard {
  const PersonalityMirrorPatternCard({
    required this.title,
    required this.body,
    required this.supportingLensesLabel,
    required this.themeId,
    required this.agreementKindKey,
  });

  final String title;
  final String body;
  final String supportingLensesLabel;
  final String themeId;
  final String agreementKindKey;
}

/// Different-perspective card (tension, both-and framing).
class PersonalityMirrorPerspectiveCard {
  const PersonalityMirrorPerspectiveCard({
    required this.title,
    required this.body,
    required this.reasonCode,
  });

  final String title;
  final String body;
  final String reasonCode;
}
