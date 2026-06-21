import 'debug_fusion_analytics_tracker.dart';
import 'fusion_analytics_tracker.dart';

/// Global analytics facade — replace [tracker] to connect external SDKs later.
abstract final class FusionAnalytics {
  static FusionAnalyticsTracker tracker = DebugFusionAnalyticsTracker();

  static void useTracker(FusionAnalyticsTracker value) {
    tracker = value;
  }

  static void resetTracker() {
    tracker = DebugFusionAnalyticsTracker();
  }
}
