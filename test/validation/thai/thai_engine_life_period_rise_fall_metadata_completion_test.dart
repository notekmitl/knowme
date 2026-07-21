import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

/// Engine Life Period Rise/Fall Metadata Completion — runtime status path.
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

  ThaiLifePeriodPositionMetadata? positionFor({
    required ThaiMirrorPipelineResult pipeline,
    required PeriodState period,
  }) {
    final archetype = archetypeFor(pipeline);
    if (archetype == null) return null;
    final context = ThaiLifePeriodContextResolver.resolve(
      period: period,
      archetypeMetadata: archetype,
      canonIndex: repository.index,
    );
    if (context == null) return null;
    return ThaiLifePeriodPositionMetadataResolver.resolve(
      period: period,
      archetypeMetadata: archetype,
      periodContextMetadata: context,
      canonIndex: repository.index,
    );
  }

  group('ThaiLifePeriodRiseFallResolver', () {
    test('produces runtime status only when position metadata exists', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final first = pipeline.lifePeriods!.periods.first;
      final position = positionFor(pipeline: pipeline, period: first);

      expect(position, isNotNull);
      expect(
        ThaiLifePeriodRiseFallResolver.resolve(
          period: first,
          positionMetadata: position,
          canonIndex: repository.index,
        ),
        isNotNull,
      );
      expect(
        ThaiLifePeriodRiseFallResolver.resolve(
          period: first,
          positionMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('does not infer from planet alone', () {
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
        ThaiLifePeriodRiseFallResolver.canonIdForPeriod(
          period: period,
          mahabhutPositionCanonId: null,
        ),
        isNull,
      );
    });

    test('does not infer from sequence alone', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final period = pipeline.lifePeriods!.periods[3];
      expect(
        ThaiLifePeriodRiseFallResolver.resolve(
          period: period,
          positionMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('status values limited to duengKhuen and duengTok', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final timeline = pipeline.lifePeriods!;

      for (final period in timeline.periods) {
        final position = positionFor(pipeline: pipeline, period: period);
        if (position == null) continue;
        final metadata = ThaiLifePeriodRiseFallResolver.resolve(
          period: period,
          positionMetadata: position,
          canonIndex: repository.index,
        );
        if (metadata == null) continue;
        expect(
          LifePeriodStatusMetadataValues.allowedCanonIds,
          contains(metadata.periodStatusCanonId),
        );
        expect(
          metadata.periodStatusLabel,
          anyOf('ดวงขึ้น', 'ดวงตก'),
        );
      }
    });

    test('every produced runtime status has Canon p17 provenance', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      for (final period in pipeline.lifePeriods!.periods) {
        final position = positionFor(pipeline: pipeline, period: period);
        if (position == null) continue;
        final metadata = ThaiLifePeriodRiseFallResolver.resolve(
          period: period,
          positionMetadata: position,
          canonIndex: repository.index,
        );
        if (metadata == null) continue;

        final fromPosition = ThaiLifePeriodRiseFallResolver.canonIdForMahabhutPosition(
          metadata.mahabhutPositionCanonId,
        );
        expect(fromPosition, metadata.periodStatusCanonId);
        expect(metadata.source, 'runtime_position_plus_canon_rule');
        expect(metadata.confidence, 'deterministic');
        expect(metadata.positionEvidenceUnitId, isNotEmpty);
      }
    });
  });

  group('Blocker chain and trace', () {
    test('runtime status count is at most position metadata count', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.lifePeriodsWithRuntimeStatus.length,
        lessThanOrEqualTo(bundle.trace.lifePeriodsWithPositionMetadata.length),
      );
      expect(bundle.trace.lifePeriodsWithRuntimeStatus, isNotEmpty);
    });

    test('9-fixture aggregate counts and partial blocker', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      var withPosition = 0;
      var withRuntime = 0;
      var withoutRuntime = 0;
      var derived = 0;

      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        withPosition += trace.lifePeriodsWithPositionMetadata.length;
        withRuntime += trace.lifePeriodsWithRuntimeStatus.length;
        withoutRuntime += trace.lifePeriodsWithoutRuntimeStatus.length;
        derived += trace.lifePeriodsWithCanonDerivedStatus.length;

        expect(
          trace.lifePeriodsWithRuntimeStatus.length,
          lessThanOrEqualTo(trace.lifePeriodsWithPositionMetadata.length),
        );

        if (trace.lifePeriodsWithoutRuntimeStatus.isNotEmpty) {
          expect(
            trace.lifePeriodStatusMetadataBlocker,
            LifePeriodStatusMetadataBlocker.partialRuntimeStatusMetadata,
          );
          expect(
            trace.lifePeriodRiseFallFeasibilityResult,
            LifePeriodRiseFallFeasibilityResult
                .partialRuntimeStatusMetadata.wire,
          );
        } else {
          expect(trace.lifePeriodStatusMetadataBlocker, isNull);
        }
      }

      expect(withPosition, 65);
      expect(withRuntime, 65);
      expect(withRuntime, equals(withPosition));
      expect(withoutRuntime, 21);
      expect(derived, 10);
    });

    test('21 ineligible periods remain blocked not inferred', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      final ineligible = audit.fixtureResults.fold<int>(
        0,
        (sum, r) =>
            sum + r.bundle.trace.lifePeriodsIneligibleForRuntimeStatus.length,
      );
      expect(ineligible, 21);
    });

    test('canon-derived fallback still works separately', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      expect(
        audit.fixtureResults
            .expand((r) => r.bundle.trace.lifePeriodsWithCanonDerivedStatus)
            .isNotEmpty,
        isTrue,
      );
      expect(
        audit.fixtureResults
            .expand((r) => r.bundle.attachments)
            .any((a) => a.signalId.contains(':periodStatus:canonDerived:')),
        isTrue,
      );
      final qaBundle = audit.fixtureResults
          .firstWhere((r) => r.fixture.id == 'qa_sample')
          .bundle;
      expect(
        qaBundle.attachments.where(
          (a) =>
              a.signalId.startsWith('life_period:0:') &&
              a.signalId.contains(':periodStatus:canonDerived:'),
        ),
        isEmpty,
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
