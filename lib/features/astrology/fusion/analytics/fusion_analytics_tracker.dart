import 'astrology_fusion_validation_events.dart';

/// Analytics abstraction — swap implementations for Firebase, Mixpanel, PostHog, etc.
abstract class FusionAnalyticsTracker {
  void trackFusionOpened(FusionOpenedPayload payload);

  void trackFusionFullyViewed();

  void trackSharedSignalsViewed();

  void trackDifferentPerspectivesViewed();

  void trackFusionInsightViewed();

  void trackWhyThisAppearsViewed();

  void trackGrowthOpportunitiesViewed();

  void trackFutureTendenciesViewed();

  void trackFusionCardSeen({
    required String status,
    required int lensCount,
  });

  void trackFusionCardClicked({
    required String status,
    required int lensCount,
  });

  void trackJourneyStepOpened({
    required String stepId,
    required String status,
    required int lensCount,
  });

  void trackJourneyStepCompleted({
    required String stepId,
    required int lensCount,
    required String readingDepth,
  });

  void trackSessionMetrics(FusionValidationMetrics metrics);
}
