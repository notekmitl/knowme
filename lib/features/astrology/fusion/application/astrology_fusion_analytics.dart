import '../analytics/astrology_fusion_validation_events.dart';
import '../analytics/fusion_analytics.dart';

/// Legacy entry point — delegates to [FusionAnalytics] validation layer.
abstract final class AstrologyFusionAnalytics {
  static void fusionOpened({
    required int lensCount,
    required bool fromSnapshot,
    String? status,
  }) {
    FusionAnalytics.tracker.trackFusionOpened(
      FusionOpenedPayload(
        lensCount: lensCount,
        status: status ?? 'unknown',
        snapshotUsed: fromSnapshot,
      ),
    );
  }
}
