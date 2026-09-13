import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/astrology_generation_coordinator.dart';
import 'package:knowme/features/astrology/domain/astrology_generation_status.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_regeneration_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_repository.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_status.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_scenario.dart';
import 'package:knowme/services/profile_service.dart';

const _knownHash =
    '7e5deacba21e9abc250024b1448bcf902b6efd41f1c4f4a121be0bdcc1a0154b';

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

ProfileModel _unknownTimeProfile() {
  return const ProfileModel(
    name: 'Unknown Time',
    gender: '',
    birthDate: '1990-05-12',
    birthTime: '',
    birthPlace: '',
    latitude: 0,
    longitude: 0,
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

  bool hasFusion;
  var deleteCount = 0;

  @override
  Future<void> deleteFusion(String uid) async {
    deleteCount++;
    hasFusion = false;
  }

  @override
  Future<AstrologyFusionSnapshot?> loadFusion(String uid) async {
    if (!hasFusion) return null;
    return HomeCohesionGoldenFixtures.load(
      HomeCohesionGoldenScenario.fusionReady,
    ).astrologySnapshot;
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
    final snapshot = HomeCohesionGoldenFixtures.load(
      HomeCohesionGoldenScenario.fusionReady,
    ).astrologySnapshot!;
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
        generateBazi: (_, _) async => baziCalls++,
        generateWestern: (_, _) async => westernCalls++,
        loadBaziInputHash: (_) async => _knownHash,
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
        generateBazi: (_, _) async {
          baziCalls++;
          probe.completedLensIds = [
            AstrologyLens.thaiAstrology.lensId,
            AstrologyLens.chineseBazi.lensId,
            AstrologyLens.westernNatal.lensId,
          ];
        },
        generateWestern: (_, _) async => westernCalls++,
        loadBaziInputHash: (_) async => _knownHash,
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
        generateBazi: (_, _) async => baziCalls++,
        generateWestern: (_, _) async {
          westernCalls++;
          probe.completedLensIds = [
            AstrologyLens.thaiAstrology.lensId,
            AstrologyLens.chineseBazi.lensId,
            AstrologyLens.westernNatal.lensId,
          ];
        },
        loadBaziInputHash: (_) async => _knownHash,
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
        generateBazi: (_, _) async {
          throw Exception('AstrologyApiFailure(/generate-bazi): network down');
        },
        generateWestern: (_, _) async {
          throw Exception('AstrologyApiFailure(/generate-chart): network down');
        },
        loadBaziInputHash: (_) async => _knownHash,
      );

      final snapshot = await coordinator.ensureGenerated('uid-fail');

      expect(snapshot.system('bazi').status, AstrologyGenerationStatus.failed);
      expect(
        snapshot.system('western').status,
        AstrologyGenerationStatus.failed,
      );
      expect(snapshot.system('bazi').errorMessage, contains('generate-bazi'));
      expect(
        snapshot.system('western').errorMessage,
        contains('generate-chart'),
      );
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
        generateBazi: (_, _) async => baziCalls++,
        generateWestern: (_, _) async => westernCalls++,
        loadBaziInputHash: (_) async => _knownHash,
      );

      await coordinator.ensureGenerated('uid-5', retrySystemId: 'fusion');

      expect(baziCalls, 0);
      expect(westernCalls, 0);
      expect(fusionCalls, 1);
      expect(fusionService.generateCount, 1);
    });

    test('changed input hash regenerates an existing bazi chart', () async {
      var baziCalls = 0;
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => _completeProfile()),
        lensProbe: _FakeLensProbe([AstrologyLens.chineseBazi.lensId]),
        fusionRepository: _StubFusionRepository(hasFusion: false),
        fusionService: noopFusionService(),
        generateBazi: (_, _) async => baziCalls++,
        generateWestern: (_, _) async {},
        loadBaziInputHash: (_) async => 'stale-input-hash',
      );

      await coordinator.ensureGenerated('uid-input-changed');

      expect(baziCalls, 1);
    });

    test(
      'changed bazi input invalidates and rebuilds existing fusion',
      () async {
        var baziCalls = 0;
        var fusionCalls = 0;
        final repository = _StubFusionRepository(hasFusion: true);
        final fusionService = _TrackingFusionService((_) async {
          fusionCalls++;
          repository.hasFusion = true;
        });
        final coordinator = AstrologyGenerationCoordinator(
          profileService: ProfileService.testing(
            (_) async => _completeProfile(),
          ),
          lensProbe: _FakeLensProbe([
            AstrologyLens.thaiAstrology.lensId,
            AstrologyLens.chineseBazi.lensId,
            AstrologyLens.westernNatal.lensId,
          ]),
          fusionRepository: repository,
          fusionService: fusionService,
          generateBazi: (_, _) async => baziCalls++,
          generateWestern: (_, _) async {},
          loadBaziInputHash: (_) async => 'stale-input-hash',
        );

        final snapshot = await coordinator.ensureGenerated(
          'uid-input-changed-with-fusion',
        );

        expect(baziCalls, 1);
        expect(repository.deleteCount, 1);
        expect(fusionCalls, 1);
        expect(snapshot.system('fusion').isReady, isTrue);
      },
    );

    test('retry fusion stays closed while BaZi input is stale', () async {
      var fusionCalls = 0;
      final repository = _StubFusionRepository(hasFusion: true);
      final fusionService = _TrackingFusionService((_) async => fusionCalls++);
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => _completeProfile()),
        lensProbe: _FakeLensProbe([
          AstrologyLens.thaiAstrology.lensId,
          AstrologyLens.chineseBazi.lensId,
          AstrologyLens.westernNatal.lensId,
        ]),
        fusionRepository: repository,
        fusionService: fusionService,
        generateBazi: (_, _) async {},
        generateWestern: (_, _) async {},
        loadBaziInputHash: (_) async => 'stale-input-hash',
      );

      final snapshot = await coordinator.ensureGenerated(
        'uid-stale-bazi-retry-fusion',
        retrySystemId: 'fusion',
      );

      expect(repository.deleteCount, 1);
      expect(fusionCalls, 0);
      expect(snapshot.system('fusion').isReady, isFalse);
    });

    test('failed stale-chart refresh overrides the old ready state', () async {
      final repository = _StubFusionRepository(hasFusion: true);
      final coordinator = AstrologyGenerationCoordinator(
        profileService: ProfileService.testing((_) async => _completeProfile()),
        lensProbe: _FakeLensProbe([AstrologyLens.chineseBazi.lensId]),
        fusionRepository: repository,
        fusionService: noopFusionService(),
        generateBazi: (_, _) async => throw StateError('refresh failed'),
        generateWestern: (_, _) async {},
        loadBaziInputHash: (_) async => 'stale-input-hash',
      );

      final snapshot = await coordinator.ensureGenerated(
        'uid-stale-refresh-failure',
        retrySystemId: 'bazi',
      );

      expect(snapshot.system('bazi').status, AstrologyGenerationStatus.failed);
      expect(snapshot.system('bazi').errorMessage, contains('refresh failed'));
      expect(repository.deleteCount, 1);
      expect(snapshot.system('fusion').isReady, isFalse);
    });

    test(
      'Unknown time generates only bazi and keeps other systems closed',
      () async {
        var baziCalls = 0;
        var westernCalls = 0;
        final probe = _FakeLensProbe(const []);
        final repository = _StubFusionRepository(hasFusion: true);
        final coordinator = AstrologyGenerationCoordinator(
          profileService: ProfileService.testing(
            (_) async => _unknownTimeProfile(),
          ),
          lensProbe: probe,
          fusionRepository: repository,
          fusionService: noopFusionService(),
          generateBazi: (_, profile) async {
            expect(profile.birthTime, isEmpty);
            baziCalls++;
            probe.completedLensIds = [AstrologyLens.chineseBazi.lensId];
          },
          generateWestern: (_, _) async => westernCalls++,
          loadBaziInputHash: (_) async => null,
        );

        final snapshot = await coordinator.ensureGenerated('uid-unknown-time');

        expect(baziCalls, 1);
        expect(westernCalls, 0);
        expect(repository.deleteCount, 1);
        expect(snapshot.system('bazi').isReady, isTrue);
        expect(
          snapshot.system('western').status,
          AstrologyGenerationStatus.notReady,
        );
        expect(
          snapshot.system('thai').status,
          AstrologyGenerationStatus.notReady,
        );
        expect(
          snapshot.system('fusion').status,
          AstrologyGenerationStatus.notReady,
        );
      },
    );

    test('Fusion accepts only a BaZi chart matching the current profile', () {
      final knownChart = BaziCompatibilityOwnerFixtures.chart(
        BaziOwnerCase.known,
      );
      final unknownChart = BaziCompatibilityOwnerFixtures.chart(
        BaziOwnerCase.unknown,
      );

      expect(
        FirestoreAstrologyFusionLensProbe.isBaziFreshForProfile(
          knownChart,
          _completeProfile(),
        ),
        isTrue,
      );
      expect(
        FirestoreAstrologyFusionLensProbe.isBaziFreshForProfile(
          knownChart,
          _unknownTimeProfile(),
        ),
        isFalse,
      );
      expect(
        FirestoreAstrologyFusionLensProbe.isBaziFreshForProfile(
          unknownChart,
          _unknownTimeProfile(),
        ),
        isTrue,
      );
    });
  });
}
