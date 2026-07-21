import 'astrology_fusion_validation_events.dart';
import 'fusion_analytics.dart';
import 'fusion_analytics_tracker.dart';
import 'fusion_reading_depth.dart';

/// Tracks reading depth and section views for one fusion result session.
class FusionValidationSession {
  FusionValidationSession({
    required this.lensCount,
    FusionAnalyticsTracker? tracker,
    DateTime? startedAt,
  })  : _tracker = tracker ?? FusionAnalytics.tracker,
        _startedAt = startedAt ?? DateTime.now();

  final FusionAnalyticsTracker _tracker;
  final DateTime _startedAt;
  final int lensCount;

  final Set<String> _sectionsViewed = {};
  bool _fullyViewed = false;
  bool _completed = false;

  void markSectionViewed(String sectionId) {
    if (!_sectionsViewed.add(sectionId)) return;

    switch (sectionId) {
      case FusionReadingDepthCalculator.sharedSignals:
        _tracker.trackSharedSignalsViewed();
      case FusionReadingDepthCalculator.differentPerspectives:
        _tracker.trackDifferentPerspectivesViewed();
      case FusionReadingDepthCalculator.fusionInsight:
        _tracker.trackFusionInsightViewed();
      case FusionReadingDepthCalculator.whyThisAppears:
        _tracker.trackWhyThisAppearsViewed();
      case FusionReadingDepthCalculator.growthOpportunities:
        _tracker.trackGrowthOpportunitiesViewed();
      case FusionReadingDepthCalculator.futureTendencies:
        _tracker.trackFutureTendenciesViewed();
    }
  }

  void markFullyViewed() {
    if (_fullyViewed) return;
    _fullyViewed = true;
    _tracker.trackFusionFullyViewed();
    _tracker.trackJourneyStepCompleted(
      stepId: 'astrology_fusion',
      lensCount: lensCount,
      readingDepth: readingDepth.name,
    );
  }

  FusionReadingDepth get readingDepth =>
      FusionReadingDepthCalculator.fromSections(
        sectionsViewed: _sectionsViewed,
        fullyViewed: _fullyViewed,
      );

  FusionValidationMetrics buildMetrics() {
    return FusionValidationMetrics(
      timeOnPage: DateTime.now().difference(_startedAt),
      sectionsViewed: Set.unmodifiable(_sectionsViewed),
      readingDepth: readingDepth,
      lensCount: lensCount,
      partialOrFull: lensCount >= 2 ? 'full' : 'partial',
    );
  }

  void complete() {
    if (_completed) return;
    _completed = true;
    _tracker.trackSessionMetrics(buildMetrics());
  }
}
