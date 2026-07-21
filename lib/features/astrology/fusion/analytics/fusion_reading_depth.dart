/// Deepest reading level reached in a fusion result session.
enum FusionReadingDepth {
  heroOnly,
  signals,
  insight,
  opportunities,
  fullRead,
}

abstract final class FusionReadingDepthCalculator {
  static const String sharedSignals = 'shared_signals';
  static const String differentPerspectives = 'different_perspectives';
  static const String fusionInsight = 'fusion_insight';
  static const String whyThisAppears = 'why_this_appears';
  static const String growthOpportunities = 'growth_opportunities';
  static const String futureTendencies = 'future_tendencies';

  static FusionReadingDepth fromSections({
    required Set<String> sectionsViewed,
    required bool fullyViewed,
  }) {
    if (fullyViewed) return FusionReadingDepth.fullRead;

    if (sectionsViewed.contains(growthOpportunities) ||
        sectionsViewed.contains(futureTendencies)) {
      return FusionReadingDepth.opportunities;
    }

    if (sectionsViewed.contains(fusionInsight) ||
        sectionsViewed.contains(whyThisAppears)) {
      return FusionReadingDepth.insight;
    }

    if (sectionsViewed.contains(sharedSignals) ||
        sectionsViewed.contains(differentPerspectives)) {
      return FusionReadingDepth.signals;
    }

    return FusionReadingDepth.heroOnly;
  }
}
