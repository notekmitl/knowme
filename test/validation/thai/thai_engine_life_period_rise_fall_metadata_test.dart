import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_life_period_rise_fall_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Engine Life Period Rise/Fall Metadata — feasibility audit + blocked path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Feasibility audit', () {
    test('production pipeline is PARTIAL_RUNTIME_STATUS_METADATA', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final feasibility = ThaiLifePeriodRiseFallFeasibility.audit(
        timeline: pipeline.lifePeriods,
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      expect(
        feasibility.result,
        LifePeriodRiseFallFeasibilityResult.partialRuntimeStatusMetadata,
      );
      expect(feasibility.hasGoverningPlanetPerPeriod, isTrue);
      expect(feasibility.hasPerPeriodMahabhutPosition, isFalse);
      expect(feasibility.hasPerPeriodArchetypeContext, isTrue);
      expect(feasibility.hasExistingRiseFallField, isTrue);
      expect(feasibility.periodsWithRuntimeStatus, greaterThan(0));
      expect(feasibility.canClassifyFromExistingFields, isFalse);
    });

    test('feasibility wire matches trace on enricher path', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.lifePeriodRiseFallFeasibilityResult,
        LifePeriodRiseFallFeasibilityResult.partialRuntimeStatusMetadata.wire,
      );
      expect(
        bundle.trace.lifePeriodStatusMetadataBlocker,
        LifePeriodStatusMetadataBlocker.partialRuntimeStatusMetadata,
      );
    });
  });

  group('ThaiLifePeriodRiseFallResolver', () {
    test('returns duengKhuen for frozen p17 rise positions only', () {
      for (final id in ThaiLifePeriodRiseFallP17Rules.risePositionIds) {
        expect(
          ThaiLifePeriodRiseFallResolver.canonIdForMahabhutPosition(id),
          LifePeriodStatusMetadataValues.duengKhuen,
        );
      }
    });

    test('returns duengTok for frozen p17 fall positions only', () {
      for (final id in ThaiLifePeriodRiseFallP17Rules.fallPositionIds) {
        expect(
          ThaiLifePeriodRiseFallResolver.canonIdForMahabhutPosition(id),
          LifePeriodStatusMetadataValues.duengTok,
        );
      }
    });

    test('returns null when Mahabhut position is missing', () {
      const period = PeriodState(
        index: 0,
        planet: LifePlanet.jupiter,
        startAge: 1,
        endAge: 19,
        strength: 19,
        isCurrent: false,
        isPast: true,
        progress: 1.0,
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

    test('allowed values are only the two Canon ids', () {
      expect(
        LifePeriodStatusMetadataValues.allowedCanonIds,
        {
          'periodStatus.duengKhuen',
          'periodStatus.duengTok',
        },
      );
    });
  });

  group('Canon evidence integration (runtime metadata path)', () {
    test('9-fixture aggregate counts', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      int sumTrace(List<String> Function(ThaiCanonEvidenceTrace t) pick) =>
          audit.fixtureResults.fold<int>(
            0,
            (sum, result) => sum + pick(result.bundle.trace).length,
          );

      expect(
        sumTrace((t) => t.lifePeriodsWithCanonDerivedStatus),
        49,
      );
      expect(
        sumTrace((t) => t.lifePeriodsWithoutCanonStatusMarker),
        30,
      );
      expect(audit.totalLifePeriodsWithoutRuntimeStatus, 79);
      expect(
        sumTrace((t) => t.lifePeriodsWithRuntimeStatus),
        7,
      );
    });

    test('canon-derived fallback still attaches for periods without runtime',
        () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(bundle.trace.lifePeriodsWithRuntimeStatus, hasLength(1));
      expect(bundle.trace.lifePeriodsWithCanonDerivedStatus, isNotEmpty);
      expect(
        bundle.attachments.any(
          (a) => a.signalId.contains(':periodStatus:canonDerived:'),
        ),
        isTrue,
      );
    });

    test('QA runtime label populates lifePeriodsWithRuntimeStatus', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
        periodStatusLabelsByIndex: {0: 'ดวงขึ้น'},
      );

      expect(bundle.trace.lifePeriodsWithRuntimeStatus, hasLength(1));
      expect(
        bundle.trace.lifePeriodsWithRuntimeStatus.first,
        startsWith('life_period:0:'),
      );
    });

    test('remedies remain skipped and never user-facing', () async {
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

  group('Public surface isolation', () {
    test('life-period sequence unchanged', () {
      final birth = ThaiMirrorPipeline.sampleQaBirthData();
      final first = ThaiMirrorPipeline.generate(birth);
      final second = ThaiMirrorPipeline.generate(birth);

      String fingerprint(LifeTimeline timeline) => timeline.periods
          .map(
            (p) =>
                '${p.index}:${p.planet.name}:${p.startAge}-${p.endAge}',
          )
          .join('|');

      expect(
        fingerprint(first.lifePeriods!),
        fingerprint(second.lifePeriods!),
      );
      expect(first.lifePeriods!.periods, isNotEmpty);
    });

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
      final birth = ThaiMirrorPipeline.sampleQaBirthData();
      final pipeline = ThaiMirrorPipeline.generate(birth);
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );

      final timeline = view.lifeTimeline!;
      for (final period in timeline.periods) {
        expect(period.summary.contains('ดวงขึ้น'), isFalse);
        expect(period.summary.contains('ดวงตก'), isFalse);
      }
    });
  });
}
