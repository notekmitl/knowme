import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Remainder Calculation Model — formula feasibility audit + blocked path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Formula feasibility audit', () {
    test('audit result is NEEDS_SOURCE_FORENSICS', () {
      final audit = ThaiRemainderCalculationModelFeasibility.audit();

      expect(
        audit.result,
        RemainderCalculationModelFeasibilityResult.needsSourceForensics,
      );
      expect(audit.hasExplicitFormulaInEngine, isFalse);
      expect(audit.hasExplicitFormulaInCanon, isFalse);
      expect(audit.hasPartialBirthDateLookupTable, isTrue);
      expect(audit.referenceTableCellCount, 28);
      expect(audit.ocrBlockedBirthDateRowCount, 62);
      expect(audit.p19HasRemainderToChartMappingOnly, isTrue);
      expect(audit.p19HasSeasonalAdjustmentRules, isTrue);
      expect(audit.rejectsRow4ReducedAsRemainder, isTrue);
      expect(audit.rejectsMahabhutaChartNumbersAsRemainder, isTrue);
      expect(
        audit.metadataBlocker,
        RemainderCalculationModelBlocker.needsSourceForensics,
      );
    });

    test('runtime metadata audit chains NEEDS_SOURCE_FORENSICS', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiRemainderRuntimeMetadataFeasibility.audit(
        profile: pipeline.profile,
      );

      expect(
        audit.result,
        RemainderRuntimeMetadataFeasibilityResult.needsSourceForensics,
      );
      expect(
        audit.calculationModelFeasibility.result,
        RemainderCalculationModelFeasibilityResult.needsSourceForensics,
      );
      expect(
        audit.metadataBlocker,
        RemainderRuntimeMetadataBlocker.needsSourceForensics,
      );
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
        RemainderCalculationModelFeasibilityResult.needsSourceForensics.wire,
      );
      expect(
        bundle.trace.remainderFeasibilityResult,
        RemainderRuntimeMetadataFeasibilityResult.needsSourceForensics.wire,
      );
      expect(
        bundle.trace.remainderMetadataBlocker,
        RemainderRuntimeMetadataBlocker.needsSourceForensics,
      );
      expect(bundle.trace.remainderSourceField, isNull);
      expect(bundle.trace.remainderCanonId, isNull);
      expect(bundle.trace.profilesWithRemainderMetadata, isEmpty);
      expect(bundle.trace.profilesWithoutRemainderMetadata, isNotEmpty);
    });
  });

  group('ThaiMahabhutRemainderCalculator', () {
    test('returns null — calculation not implemented', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      expect(
        ThaiMahabhutRemainderCalculator.calculate(profile: pipeline.profile),
        isNull,
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
      expect(
        ThaiMahabhutRemainderCalculator.calculate(profile: pipeline.profile),
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

    test('returns null when profile is missing', () {
      expect(ThaiMahabhutRemainderCalculator.calculate(), isNull);
    });
  });

  group('Downstream blocker chain', () {
    test('archetype blocker propagates NEEDS_SOURCE_FORENSICS', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetypeAudit = ThaiArchetypeContextMetadataFeasibility.audit(
        profile: pipeline.profile,
      );

      expect(
        archetypeAudit.metadataBlocker,
        RemainderRuntimeMetadataBlocker.needsSourceForensics,
      );
    });

    test('position and status blockers remain downstream', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final statusAudit = LifePeriodStatusMetadataResolver.audit(
        pipeline.lifePeriods,
        profile: pipeline.profile,
      );

      expect(
        statusAudit.blocker,
        RemainderRuntimeMetadataBlocker.needsSourceForensics,
      );
      expect(
        statusAudit.positionFeasibility.metadataBlocker,
        RemainderRuntimeMetadataBlocker.needsSourceForensics,
      );
    });

    test('9-fixture aggregate: all profiles without remainder metadata',
        () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      final withRemainder = audit.fixtureResults.fold<int>(
        0,
        (sum, r) => sum + r.bundle.trace.profilesWithRemainderMetadata.length,
      );

      expect(withRemainder, 0);
      expect(
        audit.fixtureResults.every(
          (r) =>
              r.bundle.trace.remainderCalculationFeasibilityResult ==
              RemainderCalculationModelFeasibilityResult.needsSourceForensics
                  .wire,
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
