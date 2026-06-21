import '../entities/astrology_fusion_entry_status.dart';

/// Lens completion summary for Astrology Fusion entry points.
class AstrologyFusionReadiness {
  const AstrologyFusionReadiness({
    required this.completedLensCount,
    required this.totalLensCount,
    required this.status,
    required this.completedLensIds,
  });

  final int completedLensCount;
  final int totalLensCount;
  final AstrologyFusionEntryStatus status;
  final List<String> completedLensIds;

  bool get canOpenFusion =>
      status == AstrologyFusionEntryStatus.partiallyAvailable ||
      status == AstrologyFusionEntryStatus.available;

  static AstrologyFusionEntryStatus statusForCount({
    required int completedLensCount,
    required int totalLensCount,
  }) {
    if (completedLensCount <= 0) {
      return AstrologyFusionEntryStatus.unavailable;
    }
    if (completedLensCount >= 2) {
      return AstrologyFusionEntryStatus.available;
    }
    return AstrologyFusionEntryStatus.partiallyAvailable;
  }
}
