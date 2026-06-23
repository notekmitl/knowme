import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';
import 'package:knowme/features/astrology/domain/astrology_generation_status.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_regeneration_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_repository.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/tests/fusion/application/fusion_astrology_mirror.dart';
import 'package:knowme/services/astrology_api_service.dart';
import 'package:knowme/services/astrology_firestore_service.dart';
import 'package:knowme/services/bazi_api_service.dart';
import 'package:knowme/services/profile_service.dart';

typedef GenerateBaziFn = Future<void> Function(String uid, ProfileModel profile);

typedef AstrologyGenerationProgress = void Function(
  AstrologyGenerationSnapshot snapshot,
);

typedef GenerateWesternFn = Future<void> Function(String uid, ProfileModel profile);

/// Central coordinator — auto-generates missing astrology from canonical profile.
class AstrologyGenerationCoordinator {
  AstrologyGenerationCoordinator({
    ProfileService? profileService,
    AstrologyFusionLensProbe? lensProbe,
    AstrologyFusionRegenerationService? fusionService,
    AstrologyFusionRepository? fusionRepository,
    GenerateBaziFn? generateBazi,
    GenerateWesternFn? generateWestern,
  })  : _profileService = profileService ?? ProfileService(),
        _lensProbe = lensProbe ?? FirestoreAstrologyFusionLensProbe(),
        _fusionService =
            fusionService ?? AstrologyFusionRegenerationService(),
        _fusionRepository =
            fusionRepository ?? AstrologyFusionRepositoryImpl(),
        _generateBaziFn = generateBazi ?? _defaultGenerateBazi,
        _generateWesternFn = generateWestern ?? _defaultGenerateWestern;

  final ProfileService _profileService;
  final AstrologyFusionLensProbe _lensProbe;
  final AstrologyFusionRegenerationService _fusionService;
  final AstrologyFusionRepository _fusionRepository;
  final GenerateBaziFn _generateBaziFn;
  final GenerateWesternFn _generateWesternFn;

  static final Map<String, Future<AstrologyGenerationSnapshot>> _inFlight = {};

  Future<AstrologyGenerationSnapshot> ensureGenerated(
    String uid, {
    AstrologyGenerationProgress? onProgress,
    String? retrySystemId,
  }) {
    if (uid.isEmpty) {
      return Future.value(_notReadySnapshot());
    }

    final key = retrySystemId == null ? uid : '$uid:$retrySystemId';
    final existing = _inFlight[key];
    if (existing != null) return existing;

    final future = _run(
      uid,
      onProgress: onProgress,
      retrySystemId: retrySystemId,
    );
    _inFlight[key] = future;
    future.whenComplete(() => _inFlight.remove(key));
    return future;
  }

  Future<AstrologyGenerationSnapshot> probeOnly(String uid) async {
    if (uid.isEmpty) return _notReadySnapshot();

    final profile = await _profileService.loadProfileForUid(uid);
    if (!BirthProfileReadiness.isComplete(profile)) {
      return _notReadySnapshot();
    }

    final probe = await _lensProbe.probe(uid);
    final fusionExists = await _hasFusionSnapshot(uid);
    return _snapshotFromProbe(
      probe.completedLensIds,
      fusionExists: fusionExists,
    );
  }

  Future<AstrologyGenerationSnapshot> _run(
    String uid, {
    AstrologyGenerationProgress? onProgress,
    String? retrySystemId,
  }) async {
    final profile = await _profileService.loadProfileForUid(uid);
    if (!BirthProfileReadiness.isComplete(profile) || profile == null) {
      final snap = _notReadySnapshot();
      onProgress?.call(snap);
      return snap;
    }

    void emit(AstrologyGenerationSnapshot snap) => onProgress?.call(snap);

    var snapshot = await _buildProbeSnapshot(uid);
    emit(snapshot);

    final failures = <String, String>{};

    Future<void> runBazi() async {
      if (!_shouldGenerate(snapshot, 'bazi', retrySystemId)) return;
      snapshot = snapshot.withSystem(
        const AstrologySystemSnapshot(
          systemId: 'bazi',
          status: AstrologyGenerationStatus.generating,
        ),
      );
      emit(snapshot);
      try {
        await _generateBaziFn(uid, profile);
      } catch (e) {
        failures['bazi'] = e.toString();
      }
    }

    Future<void> runWestern() async {
      if (!_shouldGenerate(snapshot, 'western', retrySystemId)) return;
      snapshot = snapshot.withSystem(
        const AstrologySystemSnapshot(
          systemId: 'western',
          status: AstrologyGenerationStatus.generating,
        ),
      );
      emit(snapshot);
      try {
        await _generateWesternFn(uid, profile);
      } catch (e) {
        failures['western'] = e.toString();
      }
    }

    await Future.wait([runBazi(), runWestern()]);

    snapshot = await _buildProbeSnapshot(uid);
    for (final entry in failures.entries) {
      if (!snapshot.system(entry.key).isReady) {
        snapshot = snapshot.withSystem(
          AstrologySystemSnapshot(
            systemId: entry.key,
            status: AstrologyGenerationStatus.failed,
            errorMessage: entry.value,
          ),
        );
      }
    }
    emit(snapshot);

    if (_shouldGenerateFusion(snapshot, retrySystemId)) {
      snapshot = snapshot.withSystem(
        const AstrologySystemSnapshot(
          systemId: 'fusion',
          status: AstrologyGenerationStatus.generating,
        ),
      );
      emit(snapshot);
      try {
        final probe = await _lensProbe.probe(uid);
        if (probe.completedLensIds.isNotEmpty) {
          await _fusionService.loadOrGenerate(uid: uid, input: probe.input);
        }
        snapshot = await _buildProbeSnapshot(uid);
      } catch (e) {
        snapshot = snapshot.withSystem(
          AstrologySystemSnapshot(
            systemId: 'fusion',
            status: AstrologyGenerationStatus.failed,
            errorMessage: e.toString(),
          ),
        );
      }
      emit(snapshot);
    }

    return snapshot;
  }

  bool _shouldGenerate(
    AstrologyGenerationSnapshot snapshot,
    String systemId,
    String? retrySystemId,
  ) {
    if (retrySystemId != null && retrySystemId != systemId) return false;
    return !snapshot.system(systemId).isReady;
  }

  bool _shouldGenerateFusion(
    AstrologyGenerationSnapshot snapshot,
    String? retrySystemId,
  ) {
    if (retrySystemId != null && retrySystemId != 'fusion') return false;
    if (snapshot.system('fusion').isReady) return false;
    return snapshot.system('thai').isReady ||
        snapshot.system('bazi').isReady ||
        snapshot.system('western').isReady;
  }

  Future<AstrologyGenerationSnapshot> _buildProbeSnapshot(String uid) async {
    final probe = await _lensProbe.probe(uid);
    final fusionExists = await _hasFusionSnapshot(uid);
    return _snapshotFromProbe(
      probe.completedLensIds,
      fusionExists: fusionExists,
    );
  }

  Future<bool> _hasFusionSnapshot(String uid) async {
    final snap = await _fusionRepository.loadFusion(uid);
    return snap != null;
  }

  static Future<void> _defaultGenerateBazi(String uid, ProfileModel profile) async {
    await BaziApiService.generateBazi(
      uid: uid,
      birthDate: BirthProfileReadiness.apiBirthDate(profile),
      birthTime: profile.birthTime.trim(),
      timezone: profile.timezone.isNotEmpty ? profile.timezone : 'Asia/Bangkok',
      latitude: profile.latitude,
      longitude: profile.longitude,
    );
  }

  static Future<void> _defaultGenerateWestern(
    String uid,
    ProfileModel profile,
  ) async {
    await AstrologyApiService.generateChart(
      uid: uid,
      birthDate: BirthProfileReadiness.apiBirthDate(profile),
      birthTime: profile.birthTime.trim(),
      latitude: profile.latitude,
      longitude: profile.longitude,
    );
    final chart =
        await AstrologyFirestoreService().getWesternNatalChart(uid);
    if (chart != null) {
      await FusionAstrologyMirror.mirrorFromChart(uid: uid, chart: chart);
    }
  }

  AstrologyGenerationSnapshot _snapshotFromProbe(
    List<String> completedLensIds, {
    required bool fusionExists,
  }) {
    AstrologySystemSnapshot forLens(String systemId, String lensId) {
      final status = completedLensIds.contains(lensId)
          ? AstrologyGenerationStatus.completed
          : AstrologyGenerationStatus.queued;
      return AstrologySystemSnapshot(systemId: systemId, status: status);
    }

    return AstrologyGenerationSnapshot(
      birthProfileComplete: true,
      systems: {
        'thai': forLens('thai', AstrologyLens.thaiAstrology.lensId),
        'bazi': forLens('bazi', AstrologyLens.chineseBazi.lensId),
        'western': forLens('western', AstrologyLens.westernNatal.lensId),
        'fusion': AstrologySystemSnapshot(
          systemId: 'fusion',
          status: fusionExists
              ? AstrologyGenerationStatus.completed
              : AstrologyGenerationStatus.queued,
        ),
      },
    );
  }

  AstrologyGenerationSnapshot _notReadySnapshot() {
    return AstrologyGenerationSnapshot(
      birthProfileComplete: false,
      systems: {
        for (final id in AstrologyGenerationSnapshot.systemIds)
          id: AstrologySystemSnapshot(
            systemId: id,
            status: AstrologyGenerationStatus.notReady,
          ),
      },
    );
  }
}
