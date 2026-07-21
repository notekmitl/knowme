import 'package:flutter/foundation.dart';

import 'astrology_fusion_validation_events.dart';
import 'fusion_analytics_tracker.dart';

/// Debug-only tracker — logs events without sending to external SDKs.
class DebugFusionAnalyticsTracker implements FusionAnalyticsTracker {
  @override
  void trackFusionOpened(FusionOpenedPayload payload) {
    _log(AstrologyFusionValidationEvents.fusionOpened, payload.toMap());
  }

  @override
  void trackFusionFullyViewed() {
    _log(AstrologyFusionValidationEvents.fusionFullyViewed);
  }

  @override
  void trackSharedSignalsViewed() {
    _log(AstrologyFusionValidationEvents.sharedSignalsViewed);
  }

  @override
  void trackDifferentPerspectivesViewed() {
    _log(AstrologyFusionValidationEvents.differentPerspectivesViewed);
  }

  @override
  void trackFusionInsightViewed() {
    _log(AstrologyFusionValidationEvents.fusionInsightViewed);
  }

  @override
  void trackWhyThisAppearsViewed() {
    _log(AstrologyFusionValidationEvents.whyThisAppearsViewed);
  }

  @override
  void trackGrowthOpportunitiesViewed() {
    _log(AstrologyFusionValidationEvents.growthOpportunitiesViewed);
  }

  @override
  void trackFutureTendenciesViewed() {
    _log(AstrologyFusionValidationEvents.futureTendenciesViewed);
  }

  @override
  void trackFusionCardSeen({
    required String status,
    required int lensCount,
  }) {
    _log(
      AstrologyFusionValidationEvents.fusionCardSeen,
      {'status': status, 'lensCount': lensCount},
    );
  }

  @override
  void trackFusionCardClicked({
    required String status,
    required int lensCount,
  }) {
    _log(
      AstrologyFusionValidationEvents.fusionCardClicked,
      {'status': status, 'lensCount': lensCount},
    );
  }

  @override
  void trackJourneyStepOpened({
    required String stepId,
    required String status,
    required int lensCount,
  }) {
    _log(
      AstrologyFusionValidationEvents.journeyStepOpened,
      {
        'stepId': stepId,
        'status': status,
        'lensCount': lensCount,
      },
    );
  }

  @override
  void trackJourneyStepCompleted({
    required String stepId,
    required int lensCount,
    required String readingDepth,
  }) {
    _log(
      AstrologyFusionValidationEvents.journeyStepCompleted,
      {
        'stepId': stepId,
        'lensCount': lensCount,
        'readingDepth': readingDepth,
      },
    );
  }

  @override
  void trackSessionMetrics(FusionValidationMetrics metrics) {
    _log('Session Metrics', metrics.toMap());
  }

  void _log(String event, [Map<String, Object?> properties = const {}]) {
    if (kDebugMode) {
      debugPrint('[FusionAnalytics] $event $properties');
    }
  }
}
