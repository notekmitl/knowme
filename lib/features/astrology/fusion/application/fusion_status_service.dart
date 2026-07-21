import '../domain/entities/astrology_fusion_status.dart';
import '../domain/models/astrology_fusion_snapshot.dart';
import '../domain/models/source_lens_versions.dart';

/// Resolves Astrology Fusion persistence status for Home/Journey later.
class FusionStatusService {
  const FusionStatusService();

  AstrologyFusionStatus resolve({
    required AstrologyFusionSnapshot? snapshot,
    required SourceLensVersions currentVersions,
  }) {
    if (snapshot == null) {
      return AstrologyFusionStatus.notGenerated;
    }

    if (snapshot.sourceLensVersions.requiresRegeneration(currentVersions)) {
      return AstrologyFusionStatus.outdated;
    }

    return AstrologyFusionStatus.upToDate;
  }
}
