import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Remainder Calculation Model — source-backed formula + metadata path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  ThaiBirthData birthDataOn(int year, int month, int day) {
    return ThaiBirthData(
      localDateTime: DateTime(year, month, day, 12, 0),
      timeZoneOffset: const Duration(hours: 7),
      latitude: 13.75,
      longitude: 100.50,
      hasBirthTime: true,
    );
  }

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Formula feasibility audit', () {
    test('audit result is READY_TO_IMPLEMENT_REMAINDER_CALCULATION', () {
      final audit = ThaiRemainderCalculationModelFeasibility.audit();

      expect(
        audit.result,
        RemainderCalculationModelFeasibilityResult
            .readyToImplementRemainderCalculation,
      );
      expect(audit.hasExplicitFormulaInEngine, isTrue);
      expect(audit.hasExplicitFormulaInCanon, isTrue);
      expect(audit.hasPartialBirthDateLookupTable, isTrue);
      expect(audit.referenceTableCellCount, 28);
      expect(audit.ocrBlockedBirthDateRowCount, 62);
      expect(audit.p19HasRemainderToChartMappingOnly, isTrue);
      expect(audit.p19HasSeasonalAdjustmentRules, isTrue);
      expect(audit.rejectsRow4ReducedAsRemainder, isTrue);
      expect(audit.rejectsMahabhutaChartNumbersAsRemainder, isTrue);
      expect(audit.metadataBlocker, isNull);
    });

    test('runtime metadata audit exposes computed remainder on pipeline', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiRemainderRuntimeMetadataFeasibility.audit(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
      );

      expect(
        audit.result,
        RemainderRuntimeMetadataFeasibilityResult
            .readyToExposeRemainderMetadata,
      );
      expect(
        audit.calculationModelFeasibility.result,
        RemainderCalculationModelFeasibilityResult
            .readyToImplementRemainderCalculation,
      );
      expect(audit.metadataBlocker, isNull);
    });

    test('calculation trace wired on enricher path', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.remainderCalculationFeasibilityResult,
        RemainderCalculationModelFeasibilityResult
            .readyToImplementRemainderCalculation.wire,
      );
      expect(
        bundle.trace.remainderFeasibilityResult,
        RemainderRuntimeMetadataFeasibilityResult
            .readyToExposeRemainderMetadata.wire,
      );
      expect(bundle.trace.remainderMetadataBlocker, isNull);
      expect(
        bundle.trace.remainderSourceField,
        ThaiMahabhutRemainderCalculator.sourceField,
      );
      expect(
        bundle.trace.remainderCanonId,
        'rotationIndex.remainder3',
      );
      expect(bundle.trace.profilesWithRemainderMetadata, isNotEmpty);
      expect(bundle.trace.profilesWithoutRemainderMetadata, isEmpty);
    });
  });

  group('ThaiMahabhutRemainderCalculator', () {
    test('QA sample 1972-04-04 uses BE-1181 and Jan-Apr adjustment', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final result = ThaiMahabhutRemainderCalculator.calculate(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
      );

      expect(result.blocker, isNull);
      expect(result.metadata!.value, 3);
      expect(result.metadata!.sourcePage, '19');
      expect(result.metadata!.source, 'source_backed_calculation');
      expect(result.metadata!.confidence, 'deterministic');
      expect(
        result.metadata!.rotationIndexCanonId,
        'rotationIndex.remainder3',
      );
    });

    test('remainder output range is exactly 0-6', () {
      for (var year = 1940; year <= 2010; year++) {
        final result = ThaiMahabhutRemainderCalculator.calculate(
          birthData: birthDataOn(year, 7, 1),
        );
        expect(result.blocker, isNull);
        expect(
          ThaiRemainderMetadataResolver.allowedValues,
          contains(result.metadata!.value),
        );
      }
    });

    test('Jan 1 through Apr 15 subtracts 1 and wraps 0 to 6', () {
      final apr15 = ThaiMahabhutRemainderCalculator.calculate(
        birthData: birthDataOn(1989, 4, 15),
      );
      expect(apr15.metadata!.value, 6);

      final jul1SameYear = ThaiMahabhutRemainderCalculator.calculate(
        birthData: birthDataOn(1815, 7, 1),
      );
      final apr1SameCycle = ThaiMahabhutRemainderCalculator.calculate(
        birthData: birthDataOn(1815, 4, 1),
      );
      expect(jul1SameYear.metadata!.value, 1);
      expect(apr1SameCycle.metadata!.value, 0);
    });

    test('Apr 16 returns blocked teacher-only exception', () {
      final result = ThaiMahabhutRemainderCalculator.calculate(
        birthData: birthDataOn(1980, 4, 16),
      );

      expect(result.metadata, isNull);
      expect(
        result.blocker,
        RemainderRuntimeMetadataBlocker.teacherOnlyExceptionApr16,
      );
    });

    test('Apr 17 through Dec 31 uses raw remainder without adjustment', () {
      final apr17 = ThaiMahabhutRemainderCalculator.calculate(
        birthData: birthDataOn(1972, 4, 17),
      );
      final jul1 = ThaiMahabhutRemainderCalculator.calculate(
        birthData: birthDataOn(1972, 7, 1),
      );

      expect(apr17.metadata!.value, 4);
      expect(jul1.metadata!.value, 4);
    });

    test('1995-09-26 harness date yields remainder 6', () {
      final result = ThaiMahabhutRemainderCalculator.calculate(
        birthData: birthDataOn(1995, 9, 26),
      );

      expect(result.metadata!.value, 6);
      expect(
        result.metadata!.rotationIndexCanonId,
        'rotationIndex.remainder6',
      );
    });

    test('returns blocked when birth date input is missing', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final result = ThaiMahabhutRemainderCalculator.calculate(
        profile: pipeline.profile,
      );

      expect(result.metadata, isNull);
      expect(
        result.blocker,
        RemainderRuntimeMetadataBlocker.missingBirthDateInput,
      );
      expect(
        ThaiRemainderMetadataResolver.resolve(profile: pipeline.profile),
        isNull,
      );
    });

    test('does not infer from mahabhutaChartNumbers row-4', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiRemainderCalculationModelFeasibility.audit();

      expect(audit.rejectsMahabhutaChartNumbersAsRemainder, isTrue);
      expect(pipeline.profile!.mahabhutaChartNumbers, isNotNull);
      expect(
        ThaiRemainderMetadataResolver.resolve(profile: pipeline.profile),
        isNull,
      );
    });

    test('does not infer from row4Reduced', () {
      final audit = ThaiRemainderCalculationModelFeasibility.audit();
      expect(audit.rejectsRow4ReducedAsRemainder, isTrue);
      expect(audit.row4DocumentedAsRemainder, isFalse);
    });

    test('allowed rotationIndex values are 0-6 only', () {
      expect(
        ThaiRemainderMetadataResolver.allowedValues,
        {0, 1, 2, 3, 4, 5, 6},
      );
    });
  });

  group('Downstream blocker chain', () {
    test('archetype blocker clears when Canon mapping is complete', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetypeAudit = ThaiArchetypeContextMetadataFeasibility.audit(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      expect(
        archetypeAudit.result,
        ArchetypeContextMetadataFeasibilityResult.readyToExposeMetadata,
      );
      expect(archetypeAudit.metadataBlocker, isNull);
      expect(archetypeAudit.hasRotationRemainderOnRuntime, isTrue);
    });

    test('position and status blockers move to NEEDS_PERIOD_CONTEXT_MAPPING',
        () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final statusAudit = LifePeriodStatusMetadataResolver.audit(
        pipeline.lifePeriods,
        profile: pipeline.profile,
        birthData: pipeline.birthData,
      );

      expect(
        statusAudit.blocker,
        LifePeriodPositionMetadataBlocker.needsPeriodContextMapping,
      );
      expect(
        statusAudit.positionFeasibility.metadataBlocker,
        LifePeriodPositionMetadataBlocker.needsPeriodContextMapping,
      );
      expect(
        statusAudit.feasibility.result,
        LifePeriodRiseFallFeasibilityResult.needsEnginePositionMetadata,
      );
    });

    test('9-fixture aggregate: all profiles with remainder metadata', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      final withRemainder = audit.fixtureResults.fold<int>(
        0,
        (sum, r) => sum + r.bundle.trace.profilesWithRemainderMetadata.length,
      );
      final withoutRemainder = audit.fixtureResults.fold<int>(
        0,
        (sum, r) => sum + r.bundle.trace.profilesWithoutRemainderMetadata.length,
      );

      expect(withRemainder, 9);
      expect(withoutRemainder, 0);
      expect(
        audit.fixtureResults.every(
          (r) =>
              r.bundle.trace.remainderCalculationFeasibilityResult ==
              RemainderCalculationModelFeasibilityResult
                  .readyToImplementRemainderCalculation.wire,
        ),
        isTrue,
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

    test('consumer report text unchanged', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );

      final remainderLabel = RegExp(
        r'เศษ\s*[0-6]|rotationIndex\.remainder|เศษดวง',
      );
      for (final period in view.lifeTimeline!.periods) {
        expect(remainderLabel.hasMatch(period.summary), isFalse);
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
