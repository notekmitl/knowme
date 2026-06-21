import 'astrology_fusion_validation_events.dart';
import 'fusion_analytics_tracker.dart';
import 'fusion_reading_depth.dart';

/// Collects validation events in memory for tests and future dashboard export.
class InMemoryFusionAnalyticsTracker implements FusionAnalyticsTracker {
  final List<FusionValidationEventRecord> events = [];

  @override
  void trackFusionOpened(FusionOpenedPayload payload) {
    _add(
      AstrologyFusionValidationEvents.fusionOpened,
      payload.toMap(),
    );
  }

  @override
  void trackFusionFullyViewed() {
    _add(AstrologyFusionValidationEvents.fusionFullyViewed);
  }

  @override
  void trackSharedSignalsViewed() {
    _add(AstrologyFusionValidationEvents.sharedSignalsViewed);
  }

  @override
  void trackDifferentPerspectivesViewed() {
    _add(AstrologyFusionValidationEvents.differentPerspectivesViewed);
  }

  @override
  void trackFusionInsightViewed() {
    _add(AstrologyFusionValidationEvents.fusionInsightViewed);
  }

  @override
  void trackWhyThisAppearsViewed() {
    _add(AstrologyFusionValidationEvents.whyThisAppearsViewed);
  }

  @override
  void trackGrowthOpportunitiesViewed() {
    _add(AstrologyFusionValidationEvents.growthOpportunitiesViewed);
  }

  @override
  void trackFutureTendenciesViewed() {
    _add(AstrologyFusionValidationEvents.futureTendenciesViewed);
  }

  @override
  void trackFusionCardSeen({
    required String status,
    required int lensCount,
  }) {
    _add(
      AstrologyFusionValidationEvents.fusionCardSeen,
      {'status': status, 'lensCount': lensCount},
    );
  }

  @override
  void trackFusionCardClicked({
    required String status,
    required int lensCount,
  }) {
    _add(
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
    _add(
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
    _add(
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
    _add('Session Metrics', metrics.toMap());
  }

  FusionValidationSnapshot buildSnapshot() {
    final opens = _count(AstrologyFusionValidationEvents.fusionOpened);
    final fullReads = _count(AstrologyFusionValidationEvents.fusionFullyViewed);

    return FusionValidationSnapshot(
      totalOpens: opens,
      fullReads: fullReads,
      completionRate: opens == 0 ? 0 : fullReads / opens,
      sectionViews: {
        AstrologyFusionValidationEvents.sharedSignalsViewed:
            _count(AstrologyFusionValidationEvents.sharedSignalsViewed),
        AstrologyFusionValidationEvents.differentPerspectivesViewed:
            _count(AstrologyFusionValidationEvents.differentPerspectivesViewed),
        AstrologyFusionValidationEvents.fusionInsightViewed:
            _count(AstrologyFusionValidationEvents.fusionInsightViewed),
        AstrologyFusionValidationEvents.whyThisAppearsViewed:
            _count(AstrologyFusionValidationEvents.whyThisAppearsViewed),
        AstrologyFusionValidationEvents.growthOpportunitiesViewed:
            _count(AstrologyFusionValidationEvents.growthOpportunitiesViewed),
        AstrologyFusionValidationEvents.futureTendenciesViewed:
            _count(AstrologyFusionValidationEvents.futureTendenciesViewed),
      },
    );
  }

  int countByLensBucket(String eventName, {required bool partial}) {
    return events.where((event) {
      if (event.name != eventName) return false;
      final lensCount = event.properties['lensCount'];
      if (lensCount is! int) return false;
      return partial ? lensCount == 1 : lensCount >= 2;
    }).length;
  }

  int _count(String name) =>
      events.where((event) => event.name == name).length;

  void _add(String name, [Map<String, Object?> properties = const {}]) {
    events.add(
      FusionValidationEventRecord(
        name: name,
        timestamp: DateTime.now().toUtc(),
        properties: properties,
      ),
    );
  }
}
