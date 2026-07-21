import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

/// Life Period Position Strategy Correction — archetype + planet placement path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  ThaiArchetypeContextMetadata? archetypeFor(ThaiMirrorPipelineResult pipeline) {
    return ThaiArchetypeContextResolver.resolve(
      remainderMetadata: ThaiRemainderMetadataResolver.resolve(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
      ),
      canonIndex: repository.index,
    ).metadata;
  }

  group('Placement index audit', () {
    test('feasibility is PARTIAL_READY_WITH_AMBIGUITIES', () {
      final index = ThaiArchetypePlanetPlacementIndex.build(repository.index);
      final audit = index.audit();

      expect(audit.uniqueCount, greaterThan(0));
      expect(audit.conflictCount, 1);
      expect(audit.ambiguousCount, greaterThan(0));
      expect(
        audit.result,
        ArchetypePlanetPositionStrategyFeasibilityResult
            .partialReadyWithAmbiguities,
      );
    });

    test('Jupiter in นักวิชาการ is SOURCE_CONFLICT', () {
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
      expect(entry.distinctPositions.length, greaterThan(1));
    });
  });

  group('ThaiLifePeriodArchetypePlanetPositionResolver', () {
    test('unique archetype + planet resolves position metadata', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final period = pipeline.lifePeriods!.periods[1];

      final metadata = ThaiLifePeriodArchetypePlanetPositionResolver.resolve(
        period: period,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );

      expect(metadata, isNotNull);
      expect(
        metadata!.matchMethod,
        PositionMatchMethod.archetypePlanetUniquePosition,
      );
      expect(metadata.canonEvidenceUnitIds, isNotEmpty);
      expect(metadata.sourcePages, isNotEmpty);
      expect(metadata.mahabhutPositionCanonId, startsWith('mahabhutPosition.'));
    });

    test('planet alone never resolves position metadata', () {
      const period = PeriodState(
        index: 0,
        planet: LifePlanet.jupiter,
        startAge: 1,
        endAge: 19,
        strength: 19,
        isCurrent: false,
        isPast: true,
        progress: 1,
        remainingYears: 0,
        previousPlanet: null,
        nextPlanet: LifePlanet.rahu,
      );

      expect(
        ThaiLifePeriodArchetypePlanetPositionResolver.resolve(
          period: period,
          archetypeMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('sequence index does not drive archetype planet resolution', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final template = pipeline.lifePeriods!.periods[1];

      final periodIndexOne = PeriodState(
        index: 1,
        planet: template.planet,
        startAge: template.startAge,
        endAge: template.endAge,
        strength: template.strength,
        isCurrent: template.isCurrent,
        isPast: template.isPast,
        progress: template.progress,
        remainingYears: template.remainingYears,
        previousPlanet: template.previousPlanet,
        nextPlanet: template.nextPlanet,
      );
      final periodIndexNinetyNine = PeriodState(
        index: 99,
        planet: template.planet,
        startAge: template.startAge,
        endAge: template.endAge,
        strength: template.strength,
        isCurrent: template.isCurrent,
        isPast: template.isPast,
        progress: template.progress,
        remainingYears: template.remainingYears,
        previousPlanet: template.previousPlanet,
        nextPlanet: template.nextPlanet,
      );

      final atOne = ThaiLifePeriodArchetypePlanetPositionResolver.resolve(
        period: periodIndexOne,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );
      final atNinetyNine = ThaiLifePeriodArchetypePlanetPositionResolver.resolve(
        period: periodIndexNinetyNine,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );

      expect(atOne, isNotNull);
      expect(atNinetyNine?.mahabhutPositionCanonId, atOne?.mahabhutPositionCanonId);
    });

    test('exact life_period context matching still works', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final first = pipeline.lifePeriods!.periods.first;
      final context = ThaiLifePeriodContextResolver.resolve(
        period: first,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );

      expect(context, isNotNull);
      final metadata = ThaiLifePeriodPositionMetadataResolver.resolveCombined(
        period: first,
        archetypeMetadata: archetype,
        periodContextMetadata: context,
        canonIndex: repository.index,
      );

      expect(metadata, isNotNull);
      expect(
        metadata!.matchMethod,
        PositionMatchMethod.exactLifePeriodContext,
      );
    });

    test('ambiguous archetype+planet pair returns null', () {
      final index = ThaiArchetypePlanetPlacementIndex.build(repository.index);
      final ambiguousPair = index.pairsWithClassification(
        ArchetypePlanetPlacementClassification.ambiguousPosition,
      ).first;
      final parts = ambiguousPair.split(':');
      final archetypeId = parts[0];
      final planetName = parts[1].replaceFirst('planet.', '');

      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = ThaiArchetypeContextMetadata(
        archetypeChartCanonId: archetypeId,
        rotationIndexCanonId: 'rotationIndex.remainder1',
        remainderValue: 1,
        mappingEvidenceUnitId: 'test.mapping',
        source: 'test',
      );
      const period = PeriodState(
        index: 0,
        planet: LifePlanet.mars,
        startAge: 1,
        endAge: 10,
        strength: 10,
        isCurrent: false,
        isPast: false,
        progress: 0,
        remainingYears: 10,
        previousPlanet: null,
        nextPlanet: null,
      );

      final planet = LifePlanet.values.byName(planetName);
      final testPeriod = PeriodState(
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

      expect(
        ThaiLifePeriodArchetypePlanetPositionResolver.resolveDetailed(
          period: testPeriod,
          archetypeMetadata: archetype,
          placementIndex: index,
        ).metadata,
        isNull,
      );
    });

    test('ดวงนักวิชาการ Jupiter conflict returns null', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = ThaiArchetypeContextMetadata(
        archetypeChartCanonId: 'archetypeChart.nakwichakan',
        rotationIndexCanonId: 'rotationIndex.remainder6',
        remainderValue: 6,
        mappingEvidenceUnitId: 'test.mapping',
        source: 'test',
      );
      const period = PeriodState(
        index: 0,
        planet: LifePlanet.jupiter,
        startAge: 1,
        endAge: 19,
        strength: 19,
        isCurrent: false,
        isPast: true,
        progress: 1,
        remainingYears: 0,
        previousPlanet: null,
        nextPlanet: LifePlanet.rahu,
      );

      final resolution =
          ThaiLifePeriodArchetypePlanetPositionResolver.resolveDetailed(
        period: period,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );

      expect(resolution.metadata, isNull);
      expect(
        resolution.missingReason,
        'SOURCE_CONFLICT_ARCHETYPE_PLANET_PLACEMENT',
      );
    });

    test('missing placement returns null', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      const period = PeriodState(
        index: 0,
        planet: LifePlanet.sun,
        startAge: 1,
        endAge: 10,
        strength: 10,
        isCurrent: false,
        isPast: false,
        progress: 0,
        remainingYears: 10,
        previousPlanet: null,
        nextPlanet: null,
      );

      final entry = ThaiArchetypePlanetPlacementIndex.build(repository.index)
          .entryFor(
        archetypeChartCanonId: archetype.archetypeChartCanonId,
        planetCanonId: 'planet.sun',
      );

      if (entry == null ||
          entry.classification ==
              ArchetypePlanetPlacementClassification.missingPosition) {
        expect(
          ThaiLifePeriodArchetypePlanetPositionResolver.resolve(
            period: period,
            archetypeMetadata: archetype,
            canonIndex: repository.index,
          ),
          isNull,
        );
      }
    });

    test('every produced metadata has Canon provenance', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      for (final result in audit.fixtureResults) {
        for (final anchor in result.bundle.trace.lifePeriodsWithPositionMetadata) {
          expect(anchor, startsWith('life_period:'));
        }
        expect(
          result.bundle.trace.positionMatchMethods,
          isNotEmpty,
        );
      }
    });
  });

  group('Trace and downstream', () {
    test('9-fixture aggregate counts documented', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      var withPosition = 0;
      var withoutPosition = 0;
      var withRuntime = 0;
      var withContext = 0;

      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        withPosition += trace.lifePeriodsWithPositionMetadata.length;
        withoutPosition += trace.lifePeriodsWithoutPositionMetadata.length;
        withRuntime += trace.lifePeriodsWithRuntimeStatus.length;
        withContext += trace.lifePeriodsWithPeriodContextMetadata.length;

        expect(
          trace.archetypePlanetPositionStrategyFeasibilityResult,
          ArchetypePlanetPositionStrategyFeasibilityResult
              .partialReadyWithAmbiguities.wire,
        );
        expect(withRuntime, equals(withPosition));
        expect(withPosition, greaterThan(withContext));
        expect(
          trace.positionMetadataEligiblePeriods.length,
          trace.lifePeriodsWithPositionMetadata.length +
              trace.lifePeriodsWithoutPositionMetadata.length,
        );
      }

      expect(withContext, 8);
      expect(withPosition, 65);
      expect(withoutPosition, 21);
      expect(withRuntime, 65);
      expect(
        audit.fixtureResults.first.bundle.trace.conflictedArchetypePlanetPairs,
        contains('archetypeChart.nakwichakan:planet.jupiter'),
      );
    });
  });

  group('Public surface isolation', () {
    test('ThaiMirrorPipeline user-facing fingerprint unchanged', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final before =
          ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);
      await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      expect(
        ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline),
        before,
      );
    });

    test('consumer report timeline text unchanged', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );

      for (final period in view.lifeTimeline!.periods) {
        expect(period.summary.contains('ดวงขึ้น'), isFalse);
        expect(period.summary.contains('ดวงตก'), isFalse);
      }
    });

    test('remedies remain internal and skipped', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(bundle.trace.skippedRemedyEvidenceCount, 87);
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
      }
    });
  });
}
