import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Period Context Mapping — feasibility + deterministic resolver path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Feasibility audit', () {
    test('result is READY_TO_MAP_PERIOD_CONTEXT', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiLifePeriodContextFeasibility.audit(
        timeline: pipeline.lifePeriods,
        canonIndex: repository.index,
      );

      expect(audit.hasStablePeriodIndex, isTrue);
      expect(audit.hasStructuredAgeRange, isTrue);
      expect(audit.hasGoverningPlanet, isTrue);
      expect(audit.hasCanonLifePeriodLabels, isTrue);
      expect(audit.canonContextDiffersAcrossArchetypes, isTrue);
      expect(audit.canMatchWithoutSequenceAlone, isTrue);
      expect(
        audit.result,
        PeriodContextMappingFeasibilityResult.readyToMapPeriodContext,
      );
    });
  });

  group('ThaiCanonLifePeriodContextNormalizer', () {
    test('parses birth label', () {
      final parsed = ThaiCanonLifePeriodContextNormalizer.parse('แรกเกิด');
      expect(parsed.isBirthLabel, isTrue);
    });

    test('parses point age labels with Thai digits', () {
      final parsed = ThaiCanonLifePeriodContextNormalizer.parse('อาย ๓๒');
      expect(parsed.parsedAge, 32);
    });

    test('parses age range labels', () {
      final parsed =
          ThaiCanonLifePeriodContextNormalizer.parse('อาย ๒๒ ถึง ๕๕');
      expect(parsed.parsedAgeRangeStart, 22);
      expect(parsed.parsedAgeRangeEnd, 55);
    });

    test('strips rise/fall markers before parsing', () {
      final parsed = ThaiCanonLifePeriodContextNormalizer.parse(
        'อาย ๓๓ ถึง ๒๒ [ดวงตก]',
      );
      expect(parsed.parsedAgeRangeStart, 22);
      expect(parsed.parsedAgeRangeEnd, 33);
    });
  });

  group('ThaiLifePeriodContextResolver', () {
    test('maps first period with แรกเกิด when archetype metadata exists', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = ThaiArchetypeContextResolver.resolve(
        remainderMetadata: ThaiRemainderMetadataResolver.resolve(
          profile: pipeline.profile,
          birthData: pipeline.birthData,
        ),
        canonIndex: repository.index,
      ).metadata;

      final first = pipeline.lifePeriods!.periods.first;
      final metadata = ThaiLifePeriodContextResolver.resolve(
        period: first,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );

      expect(metadata, isNotNull);
      expect(metadata!.canonLifePeriodContextValue, 'แรกเกิด');
      expect(metadata.matchMethod, PeriodContextMatchMethod.exactPeriodLabel);
      expect(metadata.canonEvidenceUnitIds, isNotEmpty);
      expect(metadata.sourcePages, isNotEmpty);
    });

    test('returns null without archetype metadata', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      expect(
        ThaiLifePeriodContextResolver.resolve(
          period: pipeline.lifePeriods!.periods.first,
          archetypeMetadata: null,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('planet mismatch returns null', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = ThaiArchetypeContextResolver.resolve(
        remainderMetadata: ThaiRemainderMetadataResolver.resolve(
          profile: pipeline.profile,
          birthData: pipeline.birthData,
        ),
        canonIndex: repository.index,
      ).metadata;

      const wrongPlanet = PeriodState(
        index: 99,
        planet: LifePlanet.venus,
        startAge: 99,
        endAge: 119,
        strength: 21,
        isCurrent: false,
        isPast: true,
        progress: 1,
        remainingYears: 0,
        previousPlanet: null,
        nextPlanet: null,
      );

      expect(
        ThaiLifePeriodContextResolver.resolve(
          period: wrongPlanet,
          archetypeMetadata: archetype,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('does not map from period index alone', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = ThaiArchetypeContextResolver.resolve(
        remainderMetadata: ThaiRemainderMetadataResolver.resolve(
          profile: pipeline.profile,
          birthData: pipeline.birthData,
        ),
        canonIndex: repository.index,
      ).metadata;

      final second = pipeline.lifePeriods!.periods[1];
      expect(second.index, 1);
      expect(second.startAge, isNot(1));
      expect(
        ThaiLifePeriodContextResolver.resolve(
          period: second,
          archetypeMetadata: archetype,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('exact age range match when runtime range equals Canon label', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetype = ThaiArchetypeContextResolver.resolve(
        remainderMetadata: ThaiRemainderMetadataResolver.resolve(
          profile: pipeline.profile,
          birthData: pipeline.birthData,
        ),
        canonIndex: repository.index,
      ).metadata;

      const period = PeriodState(
        index: 5,
        planet: LifePlanet.saturn,
        startAge: 22,
        endAge: 55,
        strength: 10,
        isCurrent: false,
        isPast: false,
        progress: 0,
        remainingYears: 0,
        previousPlanet: LifePlanet.mercury,
        nextPlanet: LifePlanet.jupiter,
      );

      final metadata = ThaiLifePeriodContextResolver.resolve(
        period: period,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );

      expect(metadata, isNotNull);
      expect(metadata!.canonLifePeriodContextValue, 'อาย ๒๒ ถึง ๕๕');
      expect(metadata.matchMethod, PeriodContextMatchMethod.exactAgeRange);
    });
  });

  group('Blocker chain and trace', () {
    test('position audit stays NEEDS_PERIOD_CONTEXT_MAPPING when partial', () {
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
        LifePeriodPositionMetadataFeasibilityResult.needsPeriodContextMapping,
      );
      expect(audit.periodsWithContextMetadata, greaterThan(0));
      expect(
        audit.periodsWithContextMetadata,
        lessThan(pipeline.lifePeriods!.periods.length),
      );
    });

    test('enricher records period context trace fields', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(bundle.trace.lifePeriodsWithPeriodContextMetadata, isNotEmpty);
      expect(bundle.trace.lifePeriodsWithoutPeriodContextMetadata, isNotEmpty);
      expect(
        bundle.trace.periodContextMetadataBlocker,
        PeriodContextMetadataBlocker.needsPeriodContextMapping,
      );
      expect(bundle.trace.periodContextMatchMethods, isNotEmpty);
      expect(bundle.trace.periodContextMissingReasons, isNotEmpty);
    });

    test('9-fixture aggregate period context counts', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      final withContext = audit.fixtureResults.fold<int>(
        0,
        (sum, r) =>
            sum + r.bundle.trace.lifePeriodsWithPeriodContextMetadata.length,
      );
      final withoutContext = audit.fixtureResults.fold<int>(
        0,
        (sum, r) =>
            sum + r.bundle.trace.lifePeriodsWithoutPeriodContextMetadata.length,
      );

      expect(withContext, greaterThan(0));
      expect(withoutContext, greaterThan(withContext));
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

    test('consumer report text unchanged', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );

      final periodContextLabel = RegExp(r'แรกเกิด|อาย\s*[0-9๐-๙]|life_period');
      for (final period in view.lifeTimeline!.periods) {
        expect(periodContextLabel.hasMatch(period.summary), isFalse);
      }
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
}
