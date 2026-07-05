import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Archetype Context Metadata — feasibility audit + blocked path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('Feasibility audit', () {
    test('production pipeline is NEEDS_CANON_ARCHETYPE_MAPPING', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiArchetypeContextMetadataFeasibility.audit(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
      );

      expect(
        audit.result,
        ArchetypeContextMetadataFeasibilityResult.needsCanonArchetypeMapping,
      );
      expect(audit.hasRotationRemainderOnRuntime, isTrue);
      expect(audit.hasArchetypeChartCanonIdOnRuntime, isFalse);
      expect(audit.canonRemainderToArchetypeMappingComplete, isFalse);
      expect(
        audit.metadataBlocker,
        ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      );
    });

    test('does not treat mahabhutaChartNumbers as remainder identity', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      expect(pipeline.profile!.mahabhutaChartNumbers, isNotNull);
      expect(
        ThaiArchetypeContextMetadataFeasibility.audit(
          profile: pipeline.profile,
          birthData: pipeline.birthData,
        ).result,
        ArchetypeContextMetadataFeasibilityResult.needsCanonArchetypeMapping,
      );
    });

    test('position and status blockers propagate NEEDS_CANON_ARCHETYPE_MAPPING',
        () async {
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
        ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      );
      expect(
        statusAudit.positionFeasibility.metadataBlocker,
        ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      );
      expect(
        bundle.trace.lifePeriodArchetypeMetadataBlocker,
        ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      );
      expect(
        bundle.trace.lifePeriodPositionMetadataBlocker,
        ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      );
    });
  });

  group('ThaiArchetypeContextMetadataResolver', () {
    test('maps frozen p19 remainder rows when remainder id is supplied', () {
      expect(
        ThaiArchetypeContextMetadataResolver.archetypeChartCanonIdForRemainder(
          'rotationIndex.remainder1',
        ),
        'archetypeChart.kamphra',
      );
      expect(
        ThaiArchetypeContextMetadataResolver.archetypeChartCanonIdForRemainder(
          'rotationIndex.remainder0',
        ),
        'archetypeChart.mahasethi',
      );
    });

    test('returns null for remainder6 — Canon mapping gap', () {
      expect(
        ThaiArchetypeContextMetadataResolver.archetypeChartCanonIdForRemainder(
          'rotationIndex.remainder6',
        ),
        isNull,
      );
    });

    test('returns null when remainder input is missing', () {
      expect(
        ThaiArchetypeContextMetadataResolver.archetypeChartCanonIdForRemainder(
          null,
        ),
        isNull,
      );
    });

    test('Canon mapping completeness audit documents p19 gaps', () {
      expect(
        ThaiArchetypeContextP19Rules.unmappedRemainderIds,
        contains('rotationIndex.remainder6'),
      );
      expect(
        ThaiArchetypeContextP19Rules.unmappedArchetypeChartIds,
        contains('archetypeChart.nakwichakan'),
      );
    });
  });

  group('Canon evidence integration (blocked metadata path)', () {
    test('9-fixture aggregate counts unchanged', () async {
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
        52,
      );
      expect(audit.totalLifePeriodsWithoutRuntimeStatus, 86);
      expect(
        sumTrace((t) => t.lifePeriodsWithRuntimeStatus),
        0,
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
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );

      for (final period in view.lifeTimeline!.periods) {
        expect(period.summary.contains('ดวงกำพร้า'), isFalse);
        expect(period.summary.contains('ดวงนักวิชาการ'), isFalse);
      }
    });
  });
}
