import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/mahabhut_planet_position_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_planet_placement_index.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_life_map_mahabhut_resolution.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

/// Regression: Production Life Map must receive Frozen Canon index.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    ThaiCanonEvidenceRepository.clearCachedForTest();
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    ThaiCanonEvidenceRepository.bindCachedForTest(repository);
  });

  tearDownAll(ThaiCanonEvidenceRepository.clearCachedForTest);

  group('Production presenter receives canonIndex', () {
    test('tryCreate succeeds when Frozen Canon is loaded', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final resolution = ThaiLifeMapMahabhutResolution.tryCreate(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      expect(resolution, isNotNull);
      expect(resolution!.hasCanonIndex, isTrue);
      expect(resolution.archetypeMetadata, isNotNull);
    });

    test(
      'consumer path without index stays all-unknown (proves wiring matter)',
      () {
        ThaiCanonEvidenceRepository.clearCachedForTest();
        addTearDown(() {
          ThaiCanonEvidenceRepository.bindCachedForTest(repository);
        });

        final pipeline = ThaiMirrorPipeline.generate(
          ThaiMirrorPipeline.sampleQaBirthData(),
        );
        final view = ThaiMirrorConsumerPresenter.present(
          pipeline.mirrorResult!,
          lifePeriods: pipeline.lifePeriods,
          profile: pipeline.profile,
          birthData: pipeline.birthData,
        );

        final labels = view.lifeTimeline!.periods
            .map((p) => p.mahabhutPositionLabel)
            .toList();
        expect(labels, hasLength(8));
        expect(
          labels.every((l) => l.isEmpty),
          isTrue,
          reason:
              'without Canon index, user labels must stay empty (no unknown copy)',
        );
        expect(
          view.lifeTimeline!.periods.every((p) => !p.mahabhutKnown),
          isTrue,
        );
        expect(
          view.lifeTimeline!.periods.every(
            (p) => p.mahabhutUnknownReason.isNotEmpty,
          ),
          isTrue,
          reason: 'internal unresolved reason must remain for diagnostics',
        );
      },
    );

    test(
      'consumer path with canonIndex resolves real names for QA fixture',
      () {
        final pipeline = ThaiMirrorPipeline.generate(
          ThaiMirrorPipeline.sampleQaBirthData(),
        );
        final view = ThaiMirrorConsumerPresenter.present(
          pipeline.mirrorResult!,
          lifePeriods: pipeline.lifePeriods,
          profile: pipeline.profile,
          birthData: pipeline.birthData,
          canonIndex: repository.index,
        );

        final periods = view.lifeTimeline!.periods;
        expect(periods, hasLength(8));

        final known = periods.where((p) => p.mahabhutKnown).toList();
        final unknown = periods.where((p) => !p.mahabhutKnown).toList();

        expect(
          known,
          isNotEmpty,
          reason: 'QA fixture must not show unknown on all 8 periods',
        );
        expect(known.length + unknown.length, 8);
        expect(
          unknown.every((p) => p.mahabhutPositionLabel.isEmpty),
          isTrue,
          reason: 'unresolved periods must not leak unknown copy to user label',
        );
        expect(
          unknown.every((p) => p.mahabhutUnknownReason.isNotEmpty),
          isTrue,
        );

        const allowed = {
          'ภังคะ',
          'ปูติ',
          'ขุมทรัพย์',
          'มรณะ',
          'อธิบดี',
          'ราชา',
          'ธงชัย',
          '',
        };
        for (final p in periods) {
          expect(
            allowed.contains(p.mahabhutPositionLabel),
            isTrue,
            reason: 'unexpected label: ${p.mahabhutPositionLabel}',
          );
        }
      },
    );
  });

  group('Resolver semantics preserved', () {
    test('unique placement shows Canon Thai name', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final resolution = ThaiLifeMapMahabhutResolution.tryCreate(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      )!;

      MahabhutPlanetPosition? unique;
      for (final period in pipeline.lifePeriods!.periods) {
        final pos = resolution.resolve(period);
        if (pos.known) {
          unique = pos;
          break;
        }
      }
      expect(unique, isNotNull);
      expect(unique!.thaiName, isNotNull);
      expect(unique.thaiName, isNot(MahabhutPlanetPosition.unknownLabel));
      expect(unique.canonId, startsWith('mahabhutPosition.'));
    });

    test('source-conflict Jupiter in นักวิชาการ stays unknown', () {
      final index = ThaiArchetypePlanetPlacementIndex.build(repository.index);
      final entry = index.entryFor(
        archetypeChartCanonId: 'archetypeChart.nakwichakan',
        planetCanonId: 'planet.jupiter',
      );
      expect(entry, isNotNull);
      expect(
        entry!.classification,
        ArchetypePlanetPlacementClassification.sourceConflict,
      );

      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final conflictPeriod = _withPlanet(
        pipeline.lifePeriods!.periods.first,
        LifePlanet.jupiter,
      );
      final conflicted = MahabhutPlanetPositionEngine.resolve(
        period: conflictPeriod,
        archetypeMetadata: const ThaiArchetypeContextMetadata(
          archetypeChartCanonId: 'archetypeChart.nakwichakan',
          rotationIndexCanonId: 'rotationIndex.remainder6',
          remainderValue: 6,
          mappingEvidenceUnitId: 'test.mapping',
          source: 'test',
        ),
        canonIndex: repository.index,
        placementIndex: index,
      );

      expect(conflicted.known, isFalse);
      expect(
        conflicted.unknownReason,
        'SOURCE_CONFLICT_ARCHETYPE_PLANET_PLACEMENT',
      );
      expect(conflicted.displayLabel, MahabhutPlanetPosition.unknownLabel);
    });
  });

  group('Thai Beta / Mirror / QA parity', () {
    test('runAsync and consumer present agree for same birth input', () async {
      final input = ThaiBetaInput(
        firstName: 'QA',
        lastName: 'User',
        birthDate: DateTime(1972, 4, 4),
        birthHour: 2,
        birthMinute: 0,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      );
      final analysis = await ThaiBetaAnalysisRunner.runAsync(input);
      expect(analysis.isSuccess, isTrue);

      final pipeline = analysis.pipelineResult!;
      final mirrorView = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      final betaLabels = analysis.consumerViewState!.lifeTimeline!.periods
          .map((p) => p.mahabhutPositionLabel)
          .toList();
      final mirrorLabels = mirrorView.lifeTimeline!.periods
          .map((p) => p.mahabhutPositionLabel)
          .toList();

      expect(betaLabels, mirrorLabels);
      expect(betaLabels.where((l) => l.isNotEmpty), isNotEmpty);
    });

    test(
      'user-entered birth (not only sample fixture) resolves some positions',
      () async {
        final input = ThaiBetaInput(
          firstName: 'Real',
          lastName: 'Entry',
          birthDate: DateTime(1988, 11, 15),
          birthHour: 14,
          birthMinute: 20,
          province: 'เชียงใหม่',
          provinceKey: 'chiangmai',
        );
        final analysis = await ThaiBetaAnalysisRunner.runAsync(input);
        expect(analysis.isSuccess, isTrue);

        final labels = analysis.consumerViewState!.lifeTimeline!.periods
            .map((p) => p.mahabhutPositionLabel)
            .toList();
        expect(labels, hasLength(8));
        expect(
          labels.any((l) => l.isNotEmpty),
          isTrue,
          reason: 'user birth must not be all-unknown when Canon confirms',
        );
      },
    );
  });

  group('Life Map structure no regression', () {
    test('sub-periods and annual taksa still present with canon wiring', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      for (final period in view.lifeTimeline!.periods) {
        expect(period.subPeriods, isNotEmpty);
        expect(period.annualTaksaYears, isNotEmpty);
      }
    });
  });
}

PeriodState _withPlanet(PeriodState period, LifePlanet planet) {
  return PeriodState(
    index: period.index,
    planet: planet,
    startAge: period.startAge,
    endAge: period.endAge,
    strength: period.strength,
    isCurrent: period.isCurrent,
    isPast: period.isPast,
    progress: period.progress,
    remainingYears: period.remainingYears,
    previousPlanet: period.previousPlanet,
    nextPlanet: period.nextPlanet,
  );
}
