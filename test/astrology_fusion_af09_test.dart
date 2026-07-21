import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_regeneration_service.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_repository.dart';
import 'package:knowme/features/astrology/fusion/application/fusion_status_service.dart';
import 'package:knowme/features/astrology/fusion/application/source_lens_version_resolver.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_status.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/astrology/fusion/domain/models/fusion_snapshot_codec.dart';
import 'package:knowme/features/astrology/fusion/domain/models/source_lens_versions.dart';

AstrologyChartModel _ariesWesternChart() {
  return AstrologyChartModel.fromMap({
    'big3': {'sun': 'Aries', 'moon': 'Cancer', 'rising': 'Leo'},
    'planets': {},
    'insight': {},
    'overall_summary': {},
  });
}

AstrologyChartModel _taurusWesternChart() {
  return AstrologyChartModel.fromMap({
    'big3': {'sun': 'Taurus', 'moon': 'Cancer', 'rising': 'Leo'},
    'planets': {},
    'insight': {},
    'overall_summary': {},
  });
}

BaziChartModel _sampleBaziChart({String dayMasterStem = '甲'}) {
  return BaziChartModel.fromMap({
    'version': 'bazi_v1',
    'engine_version': 'lunar_python@1.4.8',
    'day_master': {
      'stem': dayMasterStem,
      'stem_roman': 'Jia',
      'element': 'Wood',
      'polarity': 'Yang',
      'pillar_label': 'Day',
    },
    'pillars': {},
    'element_balance': {},
    'year_animal': {},
  });
}

AstrologyFusionRealInput _sampleInput({
  AstrologyChartModel? western,
  BaziChartModel? bazi,
}) {
  return AstrologyFusionRealInput(
    western: western ?? _ariesWesternChart(),
    bazi: bazi ?? _sampleBaziChart(),
  );
}

void main() {
  group('FusionSnapshotCodec', () {
    test('round-trips snapshot through Firestore map', () {
      final input = _sampleInput();
      final versions = SourceLensVersionResolver.fromInput(input);
      final original = AstrologyFusionGenerator.generateSnapshot(
        input,
        sourceLensVersions: versions,
        generatedAt: DateTime.utc(2026, 6, 11, 12),
      );

      final map = FusionSnapshotCodec.toMap(original);
      final restored = FusionSnapshotCodec.fromMap(map);

      expect(restored.version, original.version);
      expect(restored.generatedAt, original.generatedAt);
      expect(restored.signals.length, original.signals.length);
      expect(restored.agreements.length, original.agreements.length);
      expect(restored.tensions.length, original.tensions.length);
      expect(restored.reflection.summary, original.reflection.summary);
      expect(restored.fusionInsight.primary?.title,
          original.fusionInsight.primary?.title);
      expect(restored.growthOpportunities.length,
          original.growthOpportunities.length);
      expect(restored.futureTendencies.length, original.futureTendencies.length);
      expect(restored.sourceLensVersions, original.sourceLensVersions);
      expect(map['generatedAt'], isA<Timestamp>());
    });
  });

  group('SourceLensVersions', () {
    test('detects western version change', () {
      const saved = SourceLensVersions(
        westernVersion: 'western_natal_v1|Aries|Cancer|Leo',
      );
      const current = SourceLensVersions(
        westernVersion: 'western_natal_v1|Taurus|Cancer|Leo',
      );

      expect(saved.requiresRegeneration(current), isTrue);
    });

    test('detects newly available bazi lens', () {
      const saved = SourceLensVersions(westernVersion: 'western_natal_v1|Aries');
      const current = SourceLensVersions(
        westernVersion: 'western_natal_v1|Aries',
        baziVersion: 'bazi_v1|lunar_python@1.4.8|甲',
      );

      expect(saved.requiresRegeneration(current), isTrue);
    });

    test('is up to date when versions match', () {
      const versions = SourceLensVersions(
        westernVersion: 'western_natal_v1|Aries|Cancer|Leo',
        baziVersion: 'bazi_v1|lunar_python@1.4.8|甲',
      );

      expect(versions.requiresRegeneration(versions), isFalse);
    });
  });

  group('FusionStatusService', () {
    const statusService = FusionStatusService();

    test('returns notGenerated when snapshot missing', () {
      final status = statusService.resolve(
        snapshot: null,
        currentVersions: const SourceLensVersions(),
      );

      expect(status, AstrologyFusionStatus.notGenerated);
    });

    test('returns outdated when source versions differ', () {
      final input = _sampleInput(western: _taurusWesternChart());
      final snapshot = AstrologyFusionGenerator.generateSnapshot(
        _sampleInput(western: _ariesWesternChart()),
        sourceLensVersions: const SourceLensVersions(
          westernVersion: 'western_natal_v1|Aries|Cancer|Leo',
        ),
      );

      final status = statusService.resolve(
        snapshot: snapshot,
        currentVersions: SourceLensVersionResolver.fromInput(input),
      );

      expect(status, AstrologyFusionStatus.outdated);
    });
  });

  group('AstrologyFusionRepository', () {
    test('save and load fusion snapshot in memory', () async {
      final repository = InMemoryAstrologyFusionRepository();
      final input = _sampleInput();
      final snapshot = AstrologyFusionGenerator.generateSnapshot(
        input,
        sourceLensVersions: SourceLensVersionResolver.fromInput(input),
      );

      await repository.saveFusion('user_1', snapshot);
      final loaded = await repository.loadFusion('user_1');

      expect(loaded, isNotNull);
      expect(loaded!.reflection.summary, snapshot.reflection.summary);
      expect(loaded.sourceLensVersions, snapshot.sourceLensVersions);

      await repository.deleteFusion('user_1');
      expect(await repository.loadFusion('user_1'), isNull);
    });
  });

  group('AstrologyFusionRegenerationService', () {
    test('generates and saves when snapshot missing', () async {
      final repository = InMemoryAstrologyFusionRepository();
      final service = AstrologyFusionRegenerationService(
        repository: repository,
      );
      final input = _sampleInput();

      final result = await service.loadOrGenerate(
        uid: 'user_1',
        input: input,
      );

      expect(result.usedSnapshot, isFalse);
      expect(result.status, AstrologyFusionStatus.upToDate);
      expect(result.snapshot.reflection.summary, isNotEmpty);
      expect(await repository.loadFusion('user_1'), isNotNull);
    });

    test('uses snapshot when source versions are unchanged', () async {
      final repository = InMemoryAstrologyFusionRepository();
      final service = AstrologyFusionRegenerationService(
        repository: repository,
      );
      final input = _sampleInput();
      final versions = SourceLensVersionResolver.fromInput(input);

      final first = await service.loadOrGenerate(uid: 'user_1', input: input);
      final second = await service.loadOrGenerate(uid: 'user_1', input: input);

      expect(first.usedSnapshot, isFalse);
      expect(second.usedSnapshot, isTrue);
      expect(second.snapshot.generatedAt, first.snapshot.generatedAt);
      expect(second.snapshot.reflection.summary,
          first.snapshot.reflection.summary);
      expect(second.status, AstrologyFusionStatus.upToDate);
      expect(versions.hasAny, isTrue);
    });

    test('regenerates when western source version changes', () async {
      final repository = InMemoryAstrologyFusionRepository();
      final service = AstrologyFusionRegenerationService(
        repository: repository,
      );

      final firstInput = _sampleInput(western: _ariesWesternChart());
      final first = await service.loadOrGenerate(
        uid: 'user_1',
        input: firstInput,
      );

      final secondInput = _sampleInput(western: _taurusWesternChart());
      final second = await service.loadOrGenerate(
        uid: 'user_1',
        input: secondInput,
      );

      expect(first.usedSnapshot, isFalse);
      expect(second.usedSnapshot, isFalse);
      expect(second.status, AstrologyFusionStatus.outdated);
      expect(
        second.snapshot.sourceLensVersions.westernVersion,
        SourceLensVersionResolver.westernVersion(_taurusWesternChart()),
      );
      expect(
        second.snapshot.generatedAt.isAfter(first.snapshot.generatedAt) ||
            !identical(second.snapshot, first.snapshot),
        isTrue,
      );
    });

    test('peekStatus reports outdated without regenerating', () async {
      final repository = InMemoryAstrologyFusionRepository();
      final service = AstrologyFusionRegenerationService(
        repository: repository,
      );

      await service.loadOrGenerate(
        uid: 'user_1',
        input: _sampleInput(western: _ariesWesternChart()),
      );

      final status = await service.peekStatus(
        uid: 'user_1',
        currentVersions: SourceLensVersionResolver.fromInput(
          _sampleInput(western: _taurusWesternChart()),
        ),
      );

      expect(status, AstrologyFusionStatus.outdated);
    });
  });

  group('Generator snapshot', () {
    test('includes agreements from real input pipeline', () {
      final input = _sampleInput();
      final snapshot = AstrologyFusionGenerator.generateSnapshot(
        input,
        sourceLensVersions: SourceLensVersionResolver.fromInput(input),
      );

      expect(snapshot.agreements, isNotEmpty);
      expect(snapshot.signals, isNotEmpty);
      expect(snapshot.toResult().reflection.summary, isNotEmpty);
    });

    test('mock lens generator still produces richer presentation fields', () {
      final fromMocks = AstrologyFusionGenerator.generate(allMockLenses());
      expect(fromMocks.topThemes, isNotEmpty);
      expect(fromMocks.lensOrigins, isNotEmpty);
    });
  });
}
