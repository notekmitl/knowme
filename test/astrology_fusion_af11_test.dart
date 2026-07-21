import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/analytics/astrology_fusion_validation_events.dart';
import 'package:knowme/features/astrology/fusion/analytics/debug_fusion_analytics_tracker.dart';
import 'package:knowme/features/astrology/fusion/analytics/fusion_analytics.dart';
import 'package:knowme/features/astrology/fusion/analytics/fusion_analytics_tracker.dart';
import 'package:knowme/features/astrology/fusion/analytics/fusion_reading_depth.dart';
import 'package:knowme/features/astrology/fusion/analytics/fusion_validation_session.dart';
import 'package:knowme/features/astrology/fusion/analytics/in_memory_fusion_analytics_tracker.dart';

void main() {
  group('AF-11 validation analytics', () {
    late InMemoryFusionAnalyticsTracker tracker;

    setUp(() {
      tracker = InMemoryFusionAnalyticsTracker();
      FusionAnalytics.useTracker(tracker);
    });

    tearDown(() {
      FusionAnalytics.resetTracker();
    });

    test('Fusion Opened event carries lensCount status snapshotUsed', () {
      tracker.trackFusionOpened(
        const FusionOpenedPayload(
          lensCount: 2,
          status: 'upToDate',
          snapshotUsed: true,
        ),
      );

      expect(tracker.events, hasLength(1));
      expect(tracker.events.first.name,
          AstrologyFusionValidationEvents.fusionOpened);
      expect(tracker.events.first.properties['lensCount'], 2);
      expect(tracker.events.first.properties['status'], 'upToDate');
      expect(tracker.events.first.properties['snapshotUsed'], isTrue);
    });

    test('section viewed events are emitted once per session', () {
      final session = FusionValidationSession(lensCount: 3, tracker: tracker);

      session.markSectionViewed(FusionReadingDepthCalculator.sharedSignals);
      session.markSectionViewed(FusionReadingDepthCalculator.sharedSignals);
      session.markSectionViewed(FusionReadingDepthCalculator.fusionInsight);

      expect(
        tracker._count(AstrologyFusionValidationEvents.sharedSignalsViewed),
        1,
      );
      expect(
        tracker._count(AstrologyFusionValidationEvents.fusionInsightViewed),
        1,
      );
    });

    test('reading depth progresses hero_only through full_read', () {
      expect(
        FusionReadingDepthCalculator.fromSections(
          sectionsViewed: {},
          fullyViewed: false,
        ),
        FusionReadingDepth.heroOnly,
      );

      expect(
        FusionReadingDepthCalculator.fromSections(
          sectionsViewed: {FusionReadingDepthCalculator.sharedSignals},
          fullyViewed: false,
        ),
        FusionReadingDepth.signals,
      );

      expect(
        FusionReadingDepthCalculator.fromSections(
          sectionsViewed: {FusionReadingDepthCalculator.fusionInsight},
          fullyViewed: false,
        ),
        FusionReadingDepth.insight,
      );

      expect(
        FusionReadingDepthCalculator.fromSections(
          sectionsViewed: {FusionReadingDepthCalculator.growthOpportunities},
          fullyViewed: false,
        ),
        FusionReadingDepth.opportunities,
      );

      expect(
        FusionReadingDepthCalculator.fromSections(
          sectionsViewed: {FusionReadingDepthCalculator.sharedSignals},
          fullyViewed: true,
        ),
        FusionReadingDepth.fullRead,
      );
    });

    test('session metrics capture time sections depth lens partialOrFull', () {
      final session = FusionValidationSession(
        lensCount: 1,
        tracker: tracker,
        startedAt: DateTime.utc(2026, 1, 1),
      );

      session.markSectionViewed(FusionReadingDepthCalculator.futureTendencies);
      session.complete();

      final metricsEvent = tracker.events.last;
      expect(metricsEvent.name, 'Session Metrics');
      expect(metricsEvent.properties['lensCount'], 1);
      expect(metricsEvent.properties['partialOrFull'], 'partial');
      expect(metricsEvent.properties['readingDepth'],
          FusionReadingDepth.opportunities.name);
      expect(
        metricsEvent.properties['sectionsViewed'],
        contains(FusionReadingDepthCalculator.futureTendencies),
      );
      expect(metricsEvent.properties['timeOnPageMs'], isA<int>());
    });

    test('fully viewed emits completion and journey step completed', () {
      final session = FusionValidationSession(lensCount: 3, tracker: tracker);

      session.markFullyViewed();

      expect(
        tracker._count(AstrologyFusionValidationEvents.fusionFullyViewed),
        1,
      );
      expect(
        tracker._count(AstrologyFusionValidationEvents.journeyStepCompleted),
        1,
      );
      final completed = tracker.events.lastWhere(
        (event) =>
            event.name == AstrologyFusionValidationEvents.journeyStepCompleted,
      );
      expect(completed.properties['stepId'], 'astrology_fusion');
      expect(completed.properties['lensCount'], 3);
    });

    test('validation snapshot aggregates opens completion and section views',
        () {
      tracker.trackFusionOpened(
        const FusionOpenedPayload(
          lensCount: 1,
          status: 'partiallyAvailable',
          snapshotUsed: false,
        ),
      );
      tracker.trackFusionOpened(
        const FusionOpenedPayload(
          lensCount: 3,
          status: 'available',
          snapshotUsed: true,
        ),
      );
      tracker.trackFusionFullyViewed();
      tracker.trackFusionInsightViewed();
      tracker.trackFusionInsightViewed();
      tracker.trackFutureTendenciesViewed();

      final snapshot = tracker.buildSnapshot();

      expect(snapshot.totalOpens, 2);
      expect(snapshot.fullReads, 1);
      expect(snapshot.completionRate, 0.5);
      expect(
        snapshot.sectionViews[
            AstrologyFusionValidationEvents.fusionInsightViewed],
        2,
      );
      expect(
        snapshot.sectionViews[
            AstrologyFusionValidationEvents.futureTendenciesViewed],
        1,
      );
    });

    test('lens bucket comparison supports 1 lens vs 3 lens engagement', () {
      tracker.trackFusionOpened(
        const FusionOpenedPayload(
          lensCount: 1,
          status: 'partiallyAvailable',
          snapshotUsed: false,
        ),
      );
      tracker.trackFusionOpened(
        const FusionOpenedPayload(
          lensCount: 3,
          status: 'available',
          snapshotUsed: true,
        ),
      );
      tracker.trackFusionFullyViewed();

      expect(
        tracker.countByLensBucket(
          AstrologyFusionValidationEvents.fusionOpened,
          partial: true,
        ),
        1,
      );
      expect(
        tracker.countByLensBucket(
          AstrologyFusionValidationEvents.fusionOpened,
          partial: false,
        ),
        1,
      );
    });

    test('home and journey events are tracked', () {
      tracker.trackFusionCardSeen(status: 'available', lensCount: 3);
      tracker.trackFusionCardClicked(status: 'available', lensCount: 3);
      tracker.trackJourneyStepOpened(
        stepId: 'astrology_fusion',
        status: 'available',
        lensCount: 3,
      );

      expect(
        tracker._count(AstrologyFusionValidationEvents.fusionCardSeen),
        1,
      );
      expect(
        tracker._count(AstrologyFusionValidationEvents.fusionCardClicked),
        1,
      );
      expect(
        tracker._count(AstrologyFusionValidationEvents.journeyStepOpened),
        1,
      );
    });

    test('FusionAnalyticsTracker abstraction is swappable', () {
      final debugTracker = DebugFusionAnalyticsTracker();
      FusionAnalytics.useTracker(debugTracker);

      expect(FusionAnalytics.tracker, isA<FusionAnalyticsTracker>());
      expect(FusionAnalytics.tracker, isA<DebugFusionAnalyticsTracker>());

      FusionAnalytics.tracker.trackFusionOpened(
        const FusionOpenedPayload(
          lensCount: 2,
          status: 'upToDate',
          snapshotUsed: true,
        ),
      );
    });
  });
}

extension on InMemoryFusionAnalyticsTracker {
  int _count(String name) =>
      events.where((event) => event.name == name).length;
}
