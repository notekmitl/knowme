import 'fusion_reading_depth.dart';

/// Validation event names for Astrology Fusion product metrics.
abstract final class AstrologyFusionValidationEvents {
  static const fusionOpened = 'Fusion Opened';
  static const fusionFullyViewed = 'Fusion Fully Viewed';
  static const sharedSignalsViewed = 'Shared Signals Viewed';
  static const differentPerspectivesViewed = 'Different Perspectives Viewed';
  static const fusionInsightViewed = 'Fusion Insight Viewed';
  static const whyThisAppearsViewed = 'Why This Appears Viewed';
  static const growthOpportunitiesViewed = 'Growth Opportunities Viewed';
  static const futureTendenciesViewed = 'Future Tendencies Viewed';
  static const fusionCardSeen = 'Fusion Card Seen';
  static const fusionCardClicked = 'Fusion Card Clicked';
  static const journeyStepOpened = 'Journey Step Opened';
  static const journeyStepCompleted = 'Journey Step Completed';
}

class FusionOpenedPayload {
  const FusionOpenedPayload({
    required this.lensCount,
    required this.status,
    required this.snapshotUsed,
  });

  final int lensCount;
  final String status;
  final bool snapshotUsed;

  Map<String, Object?> toMap() => {
        'lensCount': lensCount,
        'status': status,
        'snapshotUsed': snapshotUsed,
      };
}

class FusionValidationEventRecord {
  const FusionValidationEventRecord({
    required this.name,
    required this.timestamp,
    this.properties = const {},
  });

  final String name;
  final DateTime timestamp;
  final Map<String, Object?> properties;
}

class FusionValidationMetrics {
  const FusionValidationMetrics({
    required this.timeOnPage,
    required this.sectionsViewed,
    required this.readingDepth,
    required this.lensCount,
    required this.partialOrFull,
  });

  final Duration timeOnPage;
  final Set<String> sectionsViewed;
  final FusionReadingDepth readingDepth;
  final int lensCount;

  /// `partial` when only one lens is available; `full` when two or more.
  final String partialOrFull;

  Map<String, Object?> toMap() => {
        'timeOnPageMs': timeOnPage.inMilliseconds,
        'sectionsViewed': sectionsViewed.toList(),
        'readingDepth': readingDepth.name,
        'lensCount': lensCount,
        'partialOrFull': partialOrFull,
      };
}

class FusionValidationSnapshot {
  const FusionValidationSnapshot({
    required this.totalOpens,
    required this.fullReads,
    required this.completionRate,
    required this.sectionViews,
  });

  final int totalOpens;
  final int fullReads;
  final double completionRate;
  final Map<String, int> sectionViews;
}
