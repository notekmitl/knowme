import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_life_period_position_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Life Period Position Metadata — feasibility audit + blocked path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Feasibility audit', () {
    test('production pipeline is PARTIAL_POSITION_METADATA', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiLifePeriodPositionMetadataFeasibility.audit(
        timeline: pipeline.lifePeriods,
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      expect(
        audit.result,
        LifePeriodPositionMetadataFeasibilityResult.partialPositionMetadata,
      );
      expect(audit.hasGoverningPlanetPerPeriod, isTrue);
      expect(audit.hasArchetypeChartIdentity, isTrue);
      expect(audit.hasPeriodContextIdentity, isTrue);
      expect(audit.hasFullPositionIdentity, isFalse);
      expect(audit.periodsWithPositionMetadata, greaterThan(0));
      expect(audit.canonLifePeriodPlacementsPresent, isTrue);
      expect(audit.metadataBlocker,
          LifePeriodPositionMetadataBlocker.partialPositionMetadata);
    });

    test('status metadata blocker reflects partial position', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = LifePeriodStatusMetadataResolver.audit(
        pipeline.lifePeriods,
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      expect(
        audit.blocker,
        LifePeriodStatusMetadataBlocker.partialRuntimeStatusMetadata,
      );
      expect(
        audit.positionFeasibility.result,
        LifePeriodPositionMetadataFeasibilityResult.partialPositionMetadata,
      );
      expect(
        audit.feasibility.result,
        LifePeriodRiseFallFeasibilityResult.partialRuntimeStatusMetadata,
      );
    });

    test('position trace wired on enricher path', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.lifePeriodPositionFeasibilityResult,
        LifePeriodPositionMetadataFeasibilityResult
            .partialPositionMetadata.wire,
      );
      expect(
        bundle.trace.lifePeriodPositionMetadataBlocker,
        LifePeriodPositionMetadataBlocker.partialPositionMetadata,
      );
      expect(
        bundle.trace.lifePeriodStatusMetadataBlocker,
        LifePeriodStatusMetadataBlocker.partialRuntimeStatusMetadata,
      );
      expect(bundle.trace.lifePeriodArchetypeMetadataBlocker, isNull);
    });
  });

  group('ThaiLifePeriodPositionMetadataResolver', () {
    test('returns null without archetype chart identity', () {
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
        ThaiLifePeriodPositionMetadataResolver.mahabhutPositionCanonId(
          period: period,
          archetypeChartCanonId: null,
          periodContextValue: 'อาย ๓ ขวบ',
        ),
        isNull,
      );
    });

    test('returns null without period context value', () {
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
        ThaiLifePeriodPositionMetadataResolver.mahabhutPositionCanonId(
          period: period,
          archetypeChartCanonId: 'archetypeChart.nakwichakan',
          periodContextValue: null,
        ),
        isNull,
      );
    });

    test('does not infer position from planet alone', () {
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
        ThaiLifePeriodPositionMetadataResolver.mahabhutPositionCanonId(
          period: period,
          archetypeChartCanonId: 'archetypeChart.nakwichakan',
          periodContextValue: 'แรกเกิด',
        ),
        isNull,
      );
    });
  });

  group('Canon evidence integration (position metadata path)', () {
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
        10,
      );
      expect(
        sumTrace((t) => t.lifePeriodsWithoutCanonStatusMarker),
        11,
      );
      expect(audit.totalLifePeriodsWithoutRuntimeStatus, 21);
      expect(
        sumTrace((t) => t.lifePeriodsWithRuntimeStatus),
        65,
      );
    });

    test('canon-derived fallback still works', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      expect(
        audit.fixtureResults
            .expand((r) => r.bundle.attachments)
            .any((a) => a.signalId.contains(':periodStatus:canonDerived:')),
        isTrue,
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
