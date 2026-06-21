import '../domain/entities/astrology_fusion_status.dart';
import '../domain/models/astrology_fusion_real_input.dart';
import '../domain/models/astrology_fusion_snapshot.dart';
import '../domain/models/source_lens_versions.dart';
import 'astrology_fusion_generator.dart';
import 'astrology_fusion_repository.dart';
import 'fusion_status_service.dart';
import 'source_lens_version_resolver.dart';

class AstrologyFusionLoadResult {
  const AstrologyFusionLoadResult({
    required this.snapshot,
    required this.status,
    required this.usedSnapshot,
  });

  final AstrologyFusionSnapshot snapshot;
  final AstrologyFusionStatus status;
  final bool usedSnapshot;
}

/// Loads a saved snapshot or regenerates when source lens versions change.
class AstrologyFusionRegenerationService {
  AstrologyFusionRegenerationService({
    AstrologyFusionRepository? repository,
    FusionStatusService? statusService,
  })  : _repository = repository ?? AstrologyFusionRepositoryImpl(),
        _statusService = statusService ?? const FusionStatusService();

  final AstrologyFusionRepository _repository;
  final FusionStatusService _statusService;

  Future<AstrologyFusionLoadResult> loadOrGenerate({
    required String uid,
    required AstrologyFusionRealInput input,
  }) async {
    final currentVersions = SourceLensVersionResolver.fromInput(input);
    final existing = await _repository.loadFusion(uid);
    final status = _statusService.resolve(
      snapshot: existing,
      currentVersions: currentVersions,
    );

    if (status == AstrologyFusionStatus.upToDate && existing != null) {
      return AstrologyFusionLoadResult(
        snapshot: existing,
        status: status,
        usedSnapshot: true,
      );
    }

    final generated = AstrologyFusionGenerator.generateSnapshot(
      input,
      sourceLensVersions: currentVersions,
    );
    await _repository.saveFusion(uid, generated);

    return AstrologyFusionLoadResult(
      snapshot: generated,
      status: status == AstrologyFusionStatus.notGenerated
          ? AstrologyFusionStatus.upToDate
          : AstrologyFusionStatus.outdated,
      usedSnapshot: false,
    );
  }

  Future<AstrologyFusionStatus> peekStatus({
    required String uid,
    required SourceLensVersions currentVersions,
  }) async {
    final existing = await _repository.loadFusion(uid);
    return _statusService.resolve(
      snapshot: existing,
      currentVersions: currentVersions,
    );
  }
}
