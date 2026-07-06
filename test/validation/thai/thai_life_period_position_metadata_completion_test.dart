import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

/// Life Period Position Metadata Completion — deterministic Canon placement path.
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

  group('ThaiLifePeriodPositionMetadataResolver', () {
    test('produces metadata only when period context metadata exists', () {
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
      expect(
        ThaiLifePeriodPositionMetadataResolver.resolve(
          period: first,
          archetypeMetadata: archetype,
          periodContextMetadata: context,
          canonIndex: repository.index,
        ),
        isNotNull,
      );
      expect(
        ThaiLifePeriodPositionMetadataResolver.resolve(
          period: first,
          archetypeMetadata: archetype,
          periodContextMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('does not produce metadata from planet alone', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
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

      expect(
        ThaiLifePeriodPositionMetadataResolver.mahabhutPositionCanonId(
          period: period,
          archetypeChartCanonId: 'archetypeChart.nakwichakan',
          periodContextValue: 'แรกเกิด',
        ),
        isNull,
      );
    });

    test('does not produce metadata from sequence alone', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final period = pipeline.lifePeriods!.periods[3];

      expect(
        ThaiLifePeriodContextResolver.resolve(
          period: period,
          archetypeMetadata: archetype,
          canonIndex: repository.index,
        ),
        isNull,
      );
      expect(
        ThaiLifePeriodPositionMetadataResolver.resolve(
          period: period,
          archetypeMetadata: archetype,
          periodContextMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('does not produce metadata from age order alone', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final period = pipeline.lifePeriods!.periods[5];

      expect(
        ThaiLifePeriodPositionMetadataResolver.resolve(
          period: period,
          archetypeMetadata: archetype,
          periodContextMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('exact Canon life_period context match is required', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final first = pipeline.lifePeriods!.periods.first;
      final context = ThaiLifePeriodContextResolver.resolve(
        period: first,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      )!;

      final metadata = ThaiLifePeriodPositionMetadataResolver.resolve(
        period: first,
        archetypeMetadata: archetype,
        periodContextMetadata: context,
        canonIndex: repository.index,
      );

      expect(metadata, isNotNull);
      expect(metadata!.contextValue, context.canonLifePeriodContextValue);
      expect(metadata.contextType, 'life_period');
      expect(metadata.canonEvidenceUnitId, isNotEmpty);
      expect(metadata.sourcePage, isNotEmpty);
      expect(metadata.mahabhutPositionCanonId, startsWith('mahabhutPosition.'));
    });

    test('planet mismatch returns null', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final context = ThaiLifePeriodContextResolver.resolve(
        period: pipeline.lifePeriods!.periods.first,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      )!;
      const wrongPlanet = PeriodState(
        index: 99,
        planet: LifePlanet.venus,
        startAge: 1,
        endAge: 8,
        strength: 8,
        isCurrent: false,
        isPast: true,
        progress: 1,
        remainingYears: 0,
        previousPlanet: null,
        nextPlanet: null,
      );

      expect(
        ThaiLifePeriodPositionMetadataResolver.resolveDetailed(
          period: wrongPlanet,
          archetypeMetadata: archetype,
          periodContextMetadata: context,
          canonIndex: repository.index,
        ).missingReason,
        'PLANET_MISMATCH',
      );
    });

    test('missing Canon placement returns null for unmatched period', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final period = pipeline.lifePeriods!.periods[2];

      expect(
        ThaiLifePeriodPositionMetadataResolver.resolve(
          period: period,
          archetypeMetadata: archetype,
          periodContextMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('every produced metadata has Canon provenance', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = archetypeFor(pipeline)!;
      final timeline = pipeline.lifePeriods!;

      for (final period in timeline.periods) {
        final context = ThaiLifePeriodContextResolver.resolve(
          period: period,
          archetypeMetadata: archetype,
          canonIndex: repository.index,
        );
        if (context == null) continue;

        final metadata = ThaiLifePeriodPositionMetadataResolver.resolve(
          period: period,
          archetypeMetadata: archetype,
          periodContextMetadata: context,
          canonIndex: repository.index,
        );
        if (metadata == null) continue;

        final unit = repository.index.unitById(metadata.canonEvidenceUnitId);
        expect(unit, isNotNull);
        expect(unit!.object, metadata.mahabhutPositionCanonId);
        expect(unit.context?.value, metadata.canonLifePeriodContextValue);
        expect(metadata.confidence, 'deterministic');
      }
    });
  });

  group('Blocker chain and trace', () {
    test('position count may exceed period context count via archetype planet path',
        () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.lifePeriodsWithPositionMetadata.length,
        greaterThan(
          bundle.trace.lifePeriodsWithPeriodContextMetadata.length,
        ),
      );
      expect(bundle.trace.lifePeriodsWithPositionMetadata, isNotEmpty);
      expect(bundle.trace.lifePeriodsWithoutPositionMetadata, isNotEmpty);
    });

    test('9-fixture aggregate counts and partial blocker', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      var withContext = 0;
      var withoutContext = 0;
      var withPosition = 0;
      var withoutPosition = 0;

      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        withContext += trace.lifePeriodsWithPeriodContextMetadata.length;
        withoutContext += trace.lifePeriodsWithoutPeriodContextMetadata.length;
        withPosition += trace.lifePeriodsWithPositionMetadata.length;
        withoutPosition += trace.lifePeriodsWithoutPositionMetadata.length;

        expect(
          trace.lifePeriodsWithPositionMetadata.length,
          greaterThanOrEqualTo(
            trace.lifePeriodsWithPeriodContextMetadata.length,
          ),
        );
        if (trace.lifePeriodsWithPositionMetadata.isNotEmpty) {
          expect(
            trace.lifePeriodPositionMetadataBlocker,
            LifePeriodPositionMetadataBlocker.partialPositionMetadata,
          );
        }
        expect(
          trace.periodContextMetadataBlocker,
          PeriodContextMetadataBlocker.needsPeriodContextMapping,
        );
        expect(
          trace.positionMetadataEligiblePeriods.length,
          trace.lifePeriodsWithPositionMetadata.length +
              trace.lifePeriodsWithoutPositionMetadata.length,
        );
        expect(trace.positionMetadataIneligiblePeriods, isEmpty);
      }

      expect(withContext, 8);
      expect(withoutContext, 78);
      expect(withPosition, 65);
      expect(withPosition, greaterThan(withContext));
      expect(withoutPosition, 21);
    });

    test('rise/fall audit shows eligible vs ineligible periods', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiLifePeriodRiseFallFeasibility.audit(
        timeline: pipeline.lifePeriods,
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      expect(
        audit.result,
        LifePeriodRiseFallFeasibilityResult.partialRuntimeStatusMetadata,
      );
      expect(audit.periodsWithPositionMetadata, greaterThan(0));
      expect(audit.periodsEligibleForRiseFall, audit.periodsWithPositionMetadata);
      expect(audit.periodsIneligibleForRiseFall, greaterThan(0));
    });

    test('21 unmatched periods remain blocked not inferred', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      final withoutPosition = audit.fixtureResults.fold<int>(
        0,
        (sum, r) =>
            sum + r.bundle.trace.lifePeriodsWithoutPositionMetadata.length,
      );
      expect(withoutPosition, 21);
      for (final result in audit.fixtureResults) {
        if (result.bundle.trace.lifePeriodsWithoutPositionMetadata.isNotEmpty) {
          expect(
            result.bundle.trace.lifePeriodsWithoutPositionMetadata,
            isNotEmpty,
          );
        }
      }
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
