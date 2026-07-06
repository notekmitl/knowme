import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Normalization audit', () {
    test('result is READY_TO_NORMALIZE_PERIOD_CONTEXT', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final labels = repository.index.units
          .where(
            (u) =>
                u.context?.type.name == 'lifePeriod' ||
                u.context?.type == AtomicContextType.lifePeriod,
          )
          .map((u) => u.context?.value)
          .whereType<String>()
          .toSet();

      final audit = ThaiLifePeriodContextNormalizationFeasibility.audit(
        timeline: pipeline.lifePeriods,
        canonLifePeriodLabels: labels,
      );

      expect(audit.hasStablePeriodIndex, isTrue);
      expect(audit.hasStructuredRuntimeAgeRange, isTrue);
      expect(audit.hasGoverningPlanet, isTrue);
      expect(
        audit.result,
        PeriodContextNormalizationFeasibilityResult
            .readyToNormalizePeriodContext,
      );
    });
  });

  group('ThaiLifePeriodContextNormalizer', () {
    test('Thai digits normalize to Arabic digits', () {
      final key = ThaiLifePeriodContextNormalizer.fromCanonLabel('อาย ๒๒');
      expect(key.pointAge, 22);
      expect(
        ThaiLifePeriodContextNormalizer.wireKey(key),
        'pointAge:22',
      );
    });

    test('Arabic digits normalize to canonical form', () {
      final key = ThaiLifePeriodContextNormalizer.fromCanonLabel('อายุ 22');
      expect(key.pointAge, 22);
    });

    test('อายุ ๒๒ ถึง ๓๒ and อายุ 22-32 share wire key', () {
      final thaiRange =
          ThaiLifePeriodContextNormalizer.fromCanonLabel('อายุ ๒๒ ถึง ๓๒');
      final hyphenRange =
          ThaiLifePeriodContextNormalizer.fromCanonLabel('อายุ 22-32');
      expect(
        ThaiLifePeriodContextNormalizer.wireKey(thaiRange),
        ThaiLifePeriodContextNormalizer.wireKey(hyphenRange),
      );
      expect(
        ThaiLifePeriodContextNormalizer.wireKey(thaiRange),
        'ageRange:22-32',
      );
    });

    test('bracket markers are preserved structurally', () {
      final key = ThaiLifePeriodContextNormalizer.fromCanonLabel(
        'อาย ๓๓ ถึง ๕๕ [ดวงขึ้น]',
      );
      expect(key.statusMarker, ThaiLifePeriodContextNormalizer.statusDuengKhuen);
      expect(key.ageRangeStart, 33);
      expect(key.ageRangeEnd, 55);
      expect(
        ThaiLifePeriodContextNormalizer.wireKey(key),
        'ageRange:33-55|status:duengKhuen',
      );
    });

    test('ambiguous labels return null wire key', () {
      final key = ThaiLifePeriodContextNormalizer.fromCanonLabel('ดวงนักวิชาการ');
      expect(key.isAmbiguous, isTrue);
      expect(ThaiLifePeriodContextNormalizer.wireKey(key), isNull);
    });
  });

  group('ThaiLifePeriodContextResolver normalization', () {
    test('raw exact match still works', () {
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

      final resolution = ThaiLifePeriodContextResolver.resolveDetailed(
        period: pipeline.lifePeriods!.periods.first,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );

      expect(resolution.metadata, isNotNull);
      expect(resolution.isRawMatch, isTrue);
      expect(resolution.metadata!.matchMethod,
          PeriodContextMatchMethod.exactPeriodLabel);
    });

    test('normalized exact age range match works', () {
      const period = PeriodState(
        index: 99,
        planet: LifePlanet.saturn,
        startAge: 22,
        endAge: 55,
        strength: 34,
        isCurrent: false,
        isPast: false,
        progress: 0.5,
        remainingYears: 17,
        previousPlanet: null,
        nextPlanet: null,
      );
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

      final resolution = ThaiLifePeriodContextResolver.resolveDetailed(
        period: period,
        archetypeMetadata: archetype,
        canonIndex: repository.index,
      );

      expect(resolution.metadata, isNotNull);
      expect(
        resolution.metadata!.canonLifePeriodContextValue,
        'อาย ๒๒ ถึง ๕๕',
      );
    });

    test('planet mismatch returns null', () {
      const period = PeriodState(
        index: 99,
        planet: LifePlanet.venus,
        startAge: 22,
        endAge: 55,
        strength: 34,
        isCurrent: false,
        isPast: false,
        progress: 0.5,
        remainingYears: 17,
        previousPlanet: null,
        nextPlanet: null,
      );
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

      expect(
        ThaiLifePeriodContextResolver.resolve(
          period: period,
          archetypeMetadata: archetype,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });

    test('no match from sequence alone', () {
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

      expect(
        ThaiLifePeriodContextResolver.resolve(
          period: pipeline.lifePeriods!.periods[3],
          archetypeMetadata: archetype,
          canonIndex: repository.index,
        ),
        isNull,
      );
    });
  });

  group('Trace and downstream', () {
    test('9-fixture aggregate counts documented', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      var withContext = 0;
      var withoutContext = 0;
      var withPosition = 0;
      var withRuntime = 0;
      var rawMatches = 0;
      var normalizedMatches = 0;

      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        withContext += trace.lifePeriodsWithPeriodContextMetadata.length;
        withoutContext += trace.lifePeriodsWithoutPeriodContextMetadata.length;
        withPosition += trace.lifePeriodsWithPositionMetadata.length;
        withRuntime += trace.lifePeriodsWithRuntimeStatus.length;
        rawMatches += trace.periodContextRawMatches.length;
        normalizedMatches += trace.periodContextNormalizedMatches.length;

        expect(
          trace.periodContextNormalizationFeasibilityResult,
          PeriodContextNormalizationFeasibilityResult
              .readyToNormalizePeriodContext.wire,
        );
        expect(withRuntime, lessThanOrEqualTo(withPosition));
        expect(withPosition, lessThanOrEqualTo(withContext));
      }

      expect(withContext, greaterThanOrEqualTo(8));
      expect(withoutContext, 78);
      expect(withPosition, greaterThanOrEqualTo(7));
      expect(withRuntime, greaterThanOrEqualTo(7));
      expect(rawMatches + normalizedMatches, lessThanOrEqualTo(withContext));
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
