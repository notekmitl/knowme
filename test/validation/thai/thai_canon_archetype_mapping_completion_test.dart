import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Canon Archetype Mapping Completion — remainder→archetype internal metadata.
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

  group('Canon mapping audit', () {
    test('frozen Canon + patch is READY_TO_EXPOSE_ARCHETYPE_CONTEXT', () {
      final audit = ThaiArchetypeContextMappingRegistry.audit(
        index: repository.index,
      );

      expect(
        audit.result,
        ArchetypeContextMappingFeasibilityResult
            .readyToExposeArchetypeContext,
      );
      expect(audit.missingRemainderIds, isEmpty);
      expect(audit.missingArchetypeChartIds, isEmpty);
      expect(
        audit.mappingUnitIdsByRemainder.keys,
        ThaiArchetypeContextP19Rules.allRemainderIds,
      );
    });

    test('post-freeze patch unit is provenance-backed and unique', () {
      final unit = repository.index.units.firstWhere(
        (u) => u.id == ThaiArchetypeContextPostFreezePatch001.remainder6ChartUnitId,
      );

      expect(unit.subject, 'rotationIndex.remainder6');
      expect(unit.object, 'archetypeChart.nakwichakan');
      expect(unit.evidence.page, '19');
      expect(unit.evidence.locator, 'เศษ/ดวง');
      expect(
        repository.index.units
            .where((u) => u.id == unit.id)
            .length,
        1,
      );
    });

    test('all seven remainder values map with provenance', () {
      for (final entry
          in ThaiArchetypeContextP19Rules.remainderToArchetypeChart.entries) {
        final unitId =
            ThaiArchetypeContextMappingRegistry.audit(index: repository.index)
                .mappingUnitIdsByRemainder[entry.key];
        expect(unitId, isNotNull);
        final unit = repository.index.units.firstWhere((u) => u.id == unitId);
        expect(unit.object, entry.value);
        expect(unit.evidence.page, isNotEmpty);
      }
    });
  });

  group('ThaiArchetypeContextResolver', () {
    test('QA sample maps remainder3 to nakbarihan via Canon unit', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final remainder = ThaiRemainderMetadataResolver.resolve(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
      );
      final resolution = ThaiArchetypeContextResolver.resolve(
        remainderMetadata: remainder,
        canonIndex: repository.index,
      );

      expect(resolution.blocker, isNull);
      expect(
        resolution.metadata!.archetypeChartCanonId,
        'archetypeChart.nakbarihan',
      );
      expect(resolution.metadata!.remainderValue, 3);
      expect(resolution.metadata!.source, 'canon_structural');
      expect(
        resolution.metadata!.mappingEvidenceUnitId,
        'mahabhut.p19.remainder_3_chart',
      );
    });

    test('remainder6 maps to nakwichakan via source forensics patch only', () {
      final remainder = ThaiRemainderMetadataResolver.resolve(
        birthData: birthDataOn(1995, 9, 26),
      );
      final resolution = ThaiArchetypeContextResolver.resolve(
        remainderMetadata: remainder,
        canonIndex: repository.index,
      );

      expect(remainder!.value, 6);
      expect(
        resolution.metadata!.archetypeChartCanonId,
        'archetypeChart.nakwichakan',
      );
      expect(resolution.metadata!.source, 'source_forensics_patch');
      expect(
        resolution.metadata!.mappingEvidenceUnitId,
        ThaiArchetypeContextPostFreezePatch001.remainder6ChartUnitId,
      );
    });

    test('returns blocker when remainder metadata is missing', () {
      final resolution = ThaiArchetypeContextResolver.resolve(
        canonIndex: repository.index,
      );

      expect(resolution.metadata, isNull);
      expect(
        resolution.blocker,
        ArchetypeContextMetadataBlocker.needsRemainderMetadata,
      );
    });

    test('does not infer from mahabhuta_thaya on profile', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiArchetypeContextMetadataFeasibility.audit(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      expect(audit.usesMahabhutaThayaAsProxy, isTrue);
      expect(
        ThaiArchetypeContextResolver.resolve(
          remainderMetadata: ThaiRemainderMetadataResolver.resolve(
            profile: pipeline.profile,
            birthData: pipeline.birthData,
          ),
          canonIndex: repository.index,
        ).metadata,
        isNotNull,
      );
    });
  });

  group('Blocker chain', () {
    test('production pipeline clears archetype blocker', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiArchetypeContextMetadataFeasibility.audit(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      );

      expect(
        audit.result,
        ArchetypeContextMetadataFeasibilityResult.readyToExposeMetadata,
      );
      expect(audit.metadataBlocker, isNull);
      expect(audit.hasArchetypeChartCanonIdOnRuntime, isTrue);
    });

    test('position blocker moves to NEEDS_PERIOD_CONTEXT_MAPPING', () {
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
      expect(audit.hasArchetypeChartIdentity, isTrue);
      expect(
        audit.metadataBlocker,
        LifePeriodPositionMetadataBlocker.needsPeriodContextMapping,
      );
    });

    test('enricher trace counts archetype metadata on 9 fixtures', () async {
      final alignment = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

      final withArchetype = alignment.fixtureResults.fold<int>(
        0,
        (sum, r) => sum + r.bundle.trace.profilesWithArchetypeContextMetadata.length,
      );
      final withoutArchetype = alignment.fixtureResults.fold<int>(
        0,
        (sum, r) =>
            sum + r.bundle.trace.profilesWithoutArchetypeContextMetadata.length,
      );

      expect(withArchetype, 9);
      expect(withoutArchetype, 0);
    });

    test('enricher exposes archetype mapping source on QA sample', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(bundle.trace.archetypeContextMetadataBlocker, isNull);
      expect(bundle.trace.archetypeMappingSource, 'canon_structural');
      expect(
        bundle.trace.archetypeChartCanonId,
        'archetypeChart.nakbarihan',
      );
      expect(
        bundle.trace.lifePeriodPositionFeasibilityResult,
        LifePeriodPositionMetadataFeasibilityResult
            .needsPeriodContextMapping.wire,
      );
      expect(
        bundle.trace.lifePeriodPositionMetadataBlocker,
        LifePeriodPositionMetadataBlocker.needsPeriodContextMapping,
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

      final archetypeLabel = RegExp(
        r'ดวงกำพร้า|ดวงนักวิชาการ|rotationIndex\.|archetypeChart\.',
      );
      for (final period in view.lifeTimeline!.periods) {
        expect(archetypeLabel.hasMatch(period.summary), isFalse);
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
