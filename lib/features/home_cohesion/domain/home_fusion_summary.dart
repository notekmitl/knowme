import 'package:knowme/features/global_fusion/domain/global_confidence_band.dart';

/// Read-only Global Fusion summary for Home (HC-F0).
class HomeFusionSummary {
  const HomeFusionSummary({
    required this.available,
    required this.ready,
    required this.reflectionCount,
    this.confidenceBand,
  });

  final bool available;
  final bool ready;
  final int reflectionCount;
  final GlobalConfidenceBand? confidenceBand;

  static const empty = HomeFusionSummary(
    available: false,
    ready: false,
    reflectionCount: 0,
  );
}
