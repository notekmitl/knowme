import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Engine Life Period Rise/Fall Metadata Re-run — post position strategy correction.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Rise/fall re-run trace', () {
    test('runtime status count equals position metadata count', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      var withPosition = 0;
      var withRuntime = 0;

      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        withPosition += trace.lifePeriodsWithPositionMetadata.length;
        withRuntime += trace.lifePeriodsWithRuntimeStatus.length;
        expect(
          trace.lifePeriodsWithRuntimeStatus.length,
          trace.lifePeriodsWithPositionMetadata.length,
        );
      }

      expect(withPosition, 65);
      expect(withRuntime, 65);
    });

    test('status source breakdown sums to runtime count', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      var exact = 0;
      var archetype = 0;
      var runtime = 0;

      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        exact += trace.runtimeStatusFromExactLifePeriodContext.length;
        archetype +=
            trace.runtimeStatusFromUniqueArchetypePlanetPosition.length;
        runtime += trace.lifePeriodsWithRuntimeStatus.length;
      }

      expect(exact + archetype, runtime);
      expect(exact, 7);
      expect(archetype, 58);
    });

    test('remaining 21 periods explicitly classified', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      var withoutRuntime = 0;
      var breakdown = 0;
      var ambiguous = 0;
      var conflict = 0;
      var missing = 0;
      var noP17 = 0;

      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        withoutRuntime += trace.lifePeriodsWithoutRuntimeStatus.length;
        breakdown += trace.runtimeStatusWithoutPositionBreakdown.length;
        ambiguous += trace.runtimeStatusBlockedByAmbiguousPosition.length;
        conflict += trace.runtimeStatusBlockedBySourceConflict.length;
        missing += trace.runtimeStatusBlockedByMissingPosition.length;
        noP17 += trace.runtimeStatusBlockedByNoP17Rule.length;

        expect(
          trace.runtimeStatusWithoutPositionBreakdown.length,
          trace.lifePeriodsWithoutPositionMetadata.length,
        );
        expect(
          trace.runtimeStatusBlockedByAmbiguousPosition.length +
              trace.runtimeStatusBlockedBySourceConflict.length +
              trace.runtimeStatusBlockedByMissingPosition.length +
              trace.runtimeStatusBlockedByNoP17Rule.length,
          trace.lifePeriodsWithoutPositionMetadata.length,
        );
      }

      expect(withoutRuntime, 21);
      expect(breakdown, 21);
      expect(noP17, 0);
      expect(ambiguous + conflict + missing, 21);
    });
  });

  group('ThaiLifePeriodRiseFallResolver re-run', () {
    test('runtime status is not produced without position metadata', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final period = pipeline.lifePeriods!.periods[8];

      expect(
        ThaiLifePeriodRiseFallResolver.resolve(
          period: period,
          positionMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('ambiguous archetype+planet pair returns null', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = ThaiArchetypeContextResolver.resolve(
        remainderMetadata: ThaiRemainderMetadataResolver.resolve(
          profile: pipeline.profile,
          birthData: pipeline.birthData,
        ),
        canonIndex: repository.index,
      ).metadata!;
      final period = pipeline.lifePeriods!.periods[8];

      expect(
        ThaiLifePeriodArchetypePlanetPositionResolver.resolve(
          period: period,
          archetypeMetadata: archetype,
          canonIndex: repository.index,
        ),
        isNull,
      );
      expect(
        ThaiLifePeriodRiseFallResolver.resolve(
          period: period,
          positionMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('ดวงนักวิชาการ Jupiter conflict remains unresolved', () {
      final archetype = ThaiArchetypeContextMetadata(
        archetypeChartCanonId: 'archetypeChart.nakwichakan',
        rotationIndexCanonId: 'rotationIndex.remainder6',
        remainderValue: 6,
        mappingEvidenceUnitId: 'test.mapping',
        source: 'test',
      );
      const period = PeriodState(
        index: 1,
        planet: LifePlanet.jupiter,
        startAge: 19,
        endAge: 38,
        strength: 19,
        isCurrent: false,
        isPast: false,
        progress: 0.5,
        remainingYears: 19,
        previousPlanet: null,
        nextPlanet: LifePlanet.saturn,
      );

      expect(
        ThaiLifePeriodArchetypePlanetPositionResolver.resolveDetailed(
          period: period,
          archetypeMetadata: archetype,
          canonIndex: repository.index,
        ).metadata,
        isNull,
      );
      expect(
        ThaiLifePeriodRiseFallResolver.resolve(
          period: period,
          positionMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('periodStatus evidence attaches for runtime periods with p17 provenance',
        () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      for (final result in audit.fixtureResults) {
        final runtimeAttachments = result.bundle.attachments.where(
          (a) =>
              a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural &&
              !a.signalId.contains(':periodStatus:canonDerived:'),
        );
        expect(
          runtimeAttachments.length,
          greaterThanOrEqualTo(
            result.bundle.trace.lifePeriodsWithRuntimeStatus.length,
          ),
        );
        for (final attachment in runtimeAttachments) {
          expect(attachment.userFacingAllowed, isFalse);
          expect(attachment.internalOnly, isTrue);
          expect(
            attachment.signalId.contains('ดวงขึ้น') ||
                attachment.signalId.contains('ดวงตก'),
            isTrue,
          );
        }
      }
    });

    test('Canon-derived marker fallback remains separate', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        final derived = result.bundle.attachments.where(
          (a) => a.signalId.contains(':periodStatus:canonDerived:'),
        );
        final runtime = result.bundle.attachments.where(
          (a) =>
              a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural &&
              !a.signalId.contains(':periodStatus:canonDerived:'),
        );

        if (derived.isNotEmpty) {
          expect(trace.lifePeriodsWithCanonDerivedStatus, isNotEmpty);
        }
        for (final attachment in derived) {
          expect(
            trace.lifePeriodsWithRuntimeStatus.any(
              (s) => attachment.signalId.startsWith(s),
            ),
            isFalse,
          );
        }
        expect(runtime.length + derived.length, greaterThan(0));
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
