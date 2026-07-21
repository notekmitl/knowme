import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/astrology_generation_coordinator.dart';
import 'package:knowme/features/astrology/domain/astrology_generation_status.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_regeneration_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_repository.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_status.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_scenario.dart';
import 'package:knowme/services/profile_service.dart';

ProfileModel _completeProfile() {
  return const ProfileModel(
    name: 'Test User',
    gender: 'male',
    birthDate: '1990-05-12',
    birthTime: '15:30',
    birthPlace: 'Bangkok, Thailand',
    latitude: 13.7563,
    longitude: 100.5018,
    timezone: 'Asia/Bangkok',
  );
}

class _FakeLensProbe implements AstrologyFusionLensProbe {
  _FakeLensProbe(this._completedLensIds);

  List<String> _completedLensIds;

  set completedLensIds(List<String> value) => _completedLensIds = value;

  @override
  Future<AstrologyFusionLensProbeResult> probe(String uid) async {
    return AstrologyFusionLensProbeResult(
      completedLensIds: List.unmodifiable(_completedLensIds),
      input: AstrologyFusionRealInput(),
    );
  }
}

class _StubFusionRepository implements AstrologyFusionRepository {
  _StubFusionRepository({required this.hasFusion});

  final bool hasFusion;

  @override
  Future<void> deleteFusion(String uid) async {}

  @override
  Future<AstrologyFusionSnapshot?> loadFusion(String uid) async {
    if (!hasFusion) return null;
    return HomeCohesionGoldenFixtures
        .load(HomeCohesionGoldenScenario.fusionReady)
        .astrologySnapshot;
  }

  @override
  Future<void> saveFusion(String uid, AstrologyFusionSnapshot snapshot) async {}
}

class _TrackingFusionService extends AstrologyFusionRegenerationService {
  _TrackingFusionService(this._onGenerate)
      : super(repository: InMemoryAstrologyFusionRepository());

  final Future<void> Function(String uid) _onGenerate;
  var generateCount = 0;

  @override
  Future<AstrologyFusionLoadResult> loadOrGenerate({
    required String uid,
    required AstrologyFusionRealInput input,
  }) async {
    generateCount++;
    await _onGenerate(uid);
    final snapshot = HomeCohesionGoldenFixtures
        .load(HomeCohesionGoldenScenario.fusionReady)
        .astrologySnapshot!;
    return AstrologyFusionLoadResult(
      snapshot: snapshot,
      status: AstrologyFusionStatus.upToDate,
      usedSnapshot: false,
    );
  }
}

void main() {
  AstrologyFusionRegenerationService noopFusionService() {
    return AstrologyFusionRegenerationService(
      repository: InMemoryAstrologyFusionRepository(),
    );
  }

  group('AstrologyGenerationCoordinator', () {
    test('incomplete profile returns notReady snapshot', () async {
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => null),
        lensProbe: _FakeLensProbe(const []),
        fusionRepository: _StubFusionRepository(hasFusion: false),
        fusionService: noopFusionService(),
      );

      final snapshot = await coordinator.ensureGenerated('uid-1');

      expect(snapshot.birthProfileComplete, isFalse);
      expect(
        snapshot.system('bazi').status,
        AstrologyGenerationStatus.notReady,
      );
    });

    test('complete profile with all lenses does not regenerate', () async {
      var baziCalls = 0;
      var westernCalls = 0;
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => _completeProfile()),
        lensProbe: _FakeLensProbe([
          AstrologyLens.thaiAstrology.lensId,
          AstrologyLens.chineseBazi.lensId,
          AstrologyLens.westernNatal.lensId,
        ]),
        fusionRepository: _StubFusionRepository(hasFusion: true),
        fusionService: noopFusionService(),
        generateBazi: (_, __) async => baziCalls++,
        generateWestern: (_, __) async => westernCalls++,
      );

      final snapshot = await coordinator.ensureGenerated('uid-2');

      expect(snapshot.birthProfileComplete, isTrue);
      expect(snapshot.system('bazi').isReady, isTrue);
      expect(snapshot.system('western').isReady, isTrue);
      expect(snapshot.system('fusion').isReady, isTrue);
      expect(baziCalls, 0);
      expect(westernCalls, 0);
    });

    test('retry bazi regenerates only bazi', () async {
      var baziCalls = 0;
      var westernCalls = 0;
      final probe = _FakeLensProbe([
        AstrologyLens.thaiAstrology.lensId,
        AstrologyLens.westernNatal.lensId,
      ]);
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => _completeProfile()),
        lensProbe: probe,
        fusionRepository: _StubFusionRepository(hasFusion: true),
        fusionService: noopFusionService(),
        generateBazi: (_, __) async {
          baziCalls++;
          probe.completedLensIds = [
            AstrologyLens.thaiAstrology.lensId,
            AstrologyLens.chineseBazi.lensId,
            AstrologyLens.westernNatal.lensId,
          ];
        },
        generateWestern: (_, __) async => westernCalls++,
      );

      await coordinator.ensureGenerated('uid-3', retrySystemId: 'bazi');

      expect(baziCalls, 1);
      expect(westernCalls, 0);
    });

    test('retry western regenerates only western', () async {
      var baziCalls = 0;
      var westernCalls = 0;
      final probe = _FakeLensProbe([
        AstrologyLens.thaiAstrology.lensId,
        AstrologyLens.chineseBazi.lensId,
      ]);
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => _completeProfile()),
        lensProbe: probe,
        fusionRepository: _StubFusionRepository(hasFusion: true),
        fusionService: noopFusionService(),
        generateBazi: (_, __) async => baziCalls++,
        generateWestern: (_, __) async {
          westernCalls++;
          probe.completedLensIds = [
            AstrologyLens.thaiAstrology.lensId,
            AstrologyLens.chineseBazi.lensId,
            AstrologyLens.westernNatal.lensId,
          ];
        },
      );

      await coordinator.ensureGenerated('uid-4', retrySystemId: 'western');

      expect(baziCalls, 0);
      expect(westernCalls, 1);
    });

    test('API failure preserves error details on failed systems', () async {
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => _completeProfile()),
        lensProbe: _FakeLensProbe([AstrologyLens.thaiAstrology.lensId]),
        fusionRepository: _StubFusionRepository(hasFusion: false),
        fusionService: noopFusionService(),
        generateBazi: (_, __) async {
          throw Exception('AstrologyApiFailure(/generate-bazi): network down');
        },
        generateWestern: (_, __) async {
          throw Exception('AstrologyApiFailure(/generate-chart): network down');
        },
      );

      final snapshot = await coordinator.ensureGenerated('uid-fail');

      expect(snapshot.system('bazi').status, AstrologyGenerationStatus.failed);
      expect(snapshot.system('western').status, AstrologyGenerationStatus.failed);
      expect(snapshot.system('bazi').errorMessage, contains('generate-bazi'));
      expect(snapshot.system('western').errorMessage, contains('generate-chart'));
    });

    test('retry fusion regenerates only fusion', () async {
      var baziCalls = 0;
      var westernCalls = 0;
      var fusionCalls = 0;
      final fusionService = _TrackingFusionService((_) async => fusionCalls++);
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => _completeProfile()),
        lensProbe: _FakeLensProbe([
          AstrologyLens.thaiAstrology.lensId,
          AstrologyLens.chineseBazi.lensId,
          AstrologyLens.westernNatal.lensId,
        ]),
        fusionRepository: _StubFusionRepository(hasFusion: false),
        fusionService: fusionService,
        generateBazi: (_, __) async => baziCalls++,
        generateWestern: (_, __) async => westernCalls++,
      );

      await coordinator.ensureGenerated('uid-5', retrySystemId: 'fusion');

      expect(baziCalls, 0);
      expect(westernCalls, 0);
      expect(fusionCalls, 1);
      expect(fusionService.generateCount, 1);
    });
  });
}
