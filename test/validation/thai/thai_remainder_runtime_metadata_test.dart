import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Remainder Runtime Metadata — source-backed calculation path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Feasibility audit', () {
    test('production pipeline is READY_TO_EXPOSE_REMAINDER_METADATA', () {
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
      expect(audit.computesRemainderDirectly, isTrue);
      expect(audit.hasRotationIndexRemainderField, isFalse);
      expect(audit.row4DocumentedAsRemainder, isFalse);
      expect(audit.rejectsRow4AsRemainderProxy, isTrue);
      expect(audit.hasMahabhutaChartNumbers, isTrue);
      expect(audit.metadataBlocker, isNull);
    });

    test('archetype blocker clears when mapping is complete', () {
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

  group('ThaiRemainderMetadataResolver', () {
    test('returns metadata on production pipeline with birthData', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final metadata = ThaiRemainderMetadataResolver.resolve(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
      );

      expect(metadata, isNotNull);
      expect(metadata!.value, 3);
      expect(metadata.sourcePage, '19');
      expect(metadata.source, 'source_backed_calculation');
    });

    test('returns null without birthData — no inference', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      expect(
        ThaiRemainderMetadataResolver.resolve(profile: pipeline.profile),
        isNull,
      );
    });

    test('Apr 16 returns null with teacher-only blocker on audit', () {
      final birthData = ThaiBirthData(
        localDateTime: DateTime(1980, 4, 16, 12, 0),
        timeZoneOffset: const Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
        hasBirthTime: true,
      );
      final audit = ThaiRemainderRuntimeMetadataFeasibility.audit(
        birthData: birthData,
      );

      expect(
        ThaiRemainderMetadataResolver.resolve(birthData: birthData),
        isNull,
      );
      expect(
        audit.calculationBlocker,
        RemainderRuntimeMetadataBlocker.teacherOnlyExceptionApr16,
      );
    });

    test('does not infer from mahabhutaChartNumbers row-4', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiRemainderRuntimeMetadataFeasibility.audit(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
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
        birthData: pipeline.birthData,
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        statusAudit.blocker,
        LifePeriodPositionMetadataBlocker.needsPeriodContextMapping,
      );
      expect(
        bundle.trace.lifePeriodPositionFeasibilityResult,
        LifePeriodPositionMetadataFeasibilityResult
            .needsPeriodContextMapping.wire,
      );
      expect(
        bundle.trace.lifePeriodRiseFallFeasibilityResult,
        'NEEDS_ENGINE_POSITION_METADATA',
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
