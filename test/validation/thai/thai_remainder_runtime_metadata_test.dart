import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Remainder Runtime Metadata — feasibility audit + blocked path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Feasibility audit', () {
    test('production pipeline is NEEDS_REMAINDER_CALCULATION_MODEL', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiRemainderRuntimeMetadataFeasibility.audit(
        profile: pipeline.profile,
      );

      expect(
        audit.result,
        RemainderRuntimeMetadataFeasibilityResult
            .needsRemainderCalculationModel,
      );
      expect(audit.computesRemainderDirectly, isFalse);
      expect(audit.hasRotationIndexRemainderField, isFalse);
      expect(audit.row4DocumentedAsRemainder, isFalse);
      expect(audit.rejectsRow4AsRemainderProxy, isTrue);
      expect(audit.hasMahabhutaChartNumbers, isTrue);
      expect(
        audit.metadataBlocker,
        RemainderRuntimeMetadataBlocker.needsRemainderCalculationModel,
      );
    });

    test('archetype blocker propagates NEEDS_REMAINDER_CALCULATION_MODEL', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final archetypeAudit = ThaiArchetypeContextMetadataFeasibility.audit(
        profile: pipeline.profile,
      );

      expect(
        archetypeAudit.result,
        ArchetypeContextMetadataFeasibilityResult.needsRemainderMetadata,
      );
      expect(
        archetypeAudit.metadataBlocker,
        RemainderRuntimeMetadataBlocker.needsRemainderCalculationModel,
      );
    });

    test('remainder trace wired on enricher path', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.remainderFeasibilityResult,
        RemainderRuntimeMetadataFeasibilityResult
            .needsRemainderCalculationModel.wire,
      );
      expect(
        bundle.trace.remainderMetadataBlocker,
        RemainderRuntimeMetadataBlocker.needsRemainderCalculationModel,
      );
      expect(bundle.trace.remainderSourceField, isNull);
      expect(bundle.trace.remainderCanonId, isNull);
      expect(bundle.trace.profilesWithRemainderMetadata, isEmpty);
      expect(bundle.trace.profilesWithoutRemainderMetadata, isNotEmpty);
    });
  });

  group('ThaiRemainderMetadataResolver', () {
    test('returns null on production profile', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
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
      final audit = ThaiRemainderRuntimeMetadataFeasibility.audit(
        profile: pipeline.profile,
      );

      expect(audit.hasMahabhutaChartNumbers, isTrue);
      expect(audit.rejectsRow4AsRemainderProxy, isTrue);
      expect(
        ThaiRemainderMetadataResolver.resolve(profile: pipeline.profile),
        isNull,
      );
    });

    test('allowed rotationIndex values are 0-6 only', () {
      expect(
        ThaiRemainderMetadataResolver.allowedValues,
        {0, 1, 2, 3, 4, 5, 6},
      );
      expect(
        ThaiRemainderMetadataResolver.rotationIndexCanonIdForValue(3),
        'rotationIndex.remainder3',
      );
    });
  });

  group('Downstream blocker chain', () {
    test('position and status blockers remain downstream', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final statusAudit = LifePeriodStatusMetadataResolver.audit(
        pipeline.lifePeriods,
        profile: pipeline.profile,
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        statusAudit.blocker,
        RemainderRuntimeMetadataBlocker.needsRemainderCalculationModel,
      );
      expect(
        bundle.trace.lifePeriodPositionFeasibilityResult,
        LifePeriodPositionMetadataFeasibilityResult
            .needsArchetypeContextMetadata.wire,
      );
      expect(
        bundle.trace.lifePeriodRiseFallFeasibilityResult,
        'NEEDS_ENGINE_POSITION_METADATA',
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
      final withoutRemainder = audit.fixtureResults.fold<int>(
        0,
        (sum, r) => sum + r.bundle.trace.profilesWithoutRemainderMetadata.length,
      );

      expect(withRemainder, 0);
      expect(withoutRemainder, audit.fixtureResults.length);
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

      final timeline = view.lifeTimeline!;
      final remainderLabel = RegExp(r'เศษ\s*[0-6]|rotationIndex\.remainder|เศษดวง');
      for (final period in timeline.periods) {
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
