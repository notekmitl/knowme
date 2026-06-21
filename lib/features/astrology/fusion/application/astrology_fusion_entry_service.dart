import '../domain/entities/astrology_fusion_entry_status.dart';
import '../domain/entities/astrology_fusion_status.dart';
import '../domain/models/astrology_fusion_readiness.dart';
import '../domain/models/source_lens_versions.dart';
import 'astrology_fusion_lens_probe.dart';
import 'astrology_fusion_readiness_service.dart';
import 'astrology_fusion_regeneration_service.dart';
import 'source_lens_version_resolver.dart';

class AstrologyFusionEntryState {
  const AstrologyFusionEntryState({
    required this.readiness,
    required this.canOpen,
    this.snapshotStatus,
  });

  final AstrologyFusionReadiness readiness;
  final bool canOpen;
  final AstrologyFusionStatus? snapshotStatus;

  bool get isSnapshotUpToDate =>
      snapshotStatus == AstrologyFusionStatus.upToDate;

  bool get needsRefresh =>
      snapshotStatus == AstrologyFusionStatus.outdated ||
      snapshotStatus == AstrologyFusionStatus.notGenerated;
}

/// Determines whether the user can open Astrology Fusion from Home/Journey.
class AstrologyFusionEntryService {
  AstrologyFusionEntryService({
    AstrologyFusionReadinessService? readinessService,
    AstrologyFusionRegenerationService? regenerationService,
    AstrologyFusionLensProbe? lensProbe,
  })  : _readinessService = readinessService ?? AstrologyFusionReadinessService(),
        _regenerationService =
            regenerationService ?? AstrologyFusionRegenerationService(),
        _lensProbe = lensProbe ?? FirestoreAstrologyFusionLensProbe();

  final AstrologyFusionReadinessService _readinessService;
  final AstrologyFusionRegenerationService _regenerationService;
  final AstrologyFusionLensProbe _lensProbe;

  Future<AstrologyFusionEntryState> evaluate(String uid) async {
    final readiness = await _readinessService.evaluate(uid);

    if (readiness.status == AstrologyFusionEntryStatus.unavailable) {
      return AstrologyFusionEntryState(
        readiness: readiness,
        canOpen: false,
        snapshotStatus: null,
      );
    }

    final probe = await _lensProbe.probe(uid);
    final currentVersions = SourceLensVersionResolver.fromInput(probe.input);
    final snapshotStatus = await _regenerationService.peekStatus(
      uid: uid,
      currentVersions: currentVersions,
    );

    return AstrologyFusionEntryState(
      readiness: readiness,
      canOpen: readiness.canOpenFusion,
      snapshotStatus: snapshotStatus,
    );
  }
}
