import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Canon-derived period status evidence annotation tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('ThaiCanonPeriodStatusFromEvidence', () {
    ThaiCanonEvidenceRef refWithContext(String value) {
      return ThaiCanonEvidenceRef(
        unitId: 'test.unit',
        relation: 'located_in',
        subject: 'planet.jupiter',
        object: 'mahabhutPosition.marana',
        sourceBookId: 'mahabhut',
        sourcePage: '61',
        contextType: 'life_period',
        contextValue: value,
        safety: ThaiCanonEvidenceSafety.traceabilityInternal,
      );
    }

    test('[ดวงขึ้น] marker maps to periodStatus.duengKhuen', () {
      expect(
        ThaiCanonPeriodStatusFromEvidence.canonIdForContextValue(
          'อาย ๓ ขวบ [ดวงขึ้น]',
        ),
        LifePeriodStatusMetadataValues.duengKhuen,
      );
      expect(
        ThaiCanonPeriodStatusFromEvidence.canonIdFromLifePeriodRefs([
          refWithContext('อาย ๓ ขวบ [ดวงขึ้น]'),
        ]),
        LifePeriodStatusMetadataValues.duengKhuen,
      );
    });

    test('[ดวงตก] marker maps to periodStatus.duengTok', () {
      expect(
        ThaiCanonPeriodStatusFromEvidence.canonIdForContextValue(
          'อาย ๓ ขวบ [ดวงตก]',
        ),
        LifePeriodStatusMetadataValues.duengTok,
      );
      expect(
        ThaiCanonPeriodStatusFromEvidence.canonIdFromLifePeriodRefs([
          refWithContext('อาย ๓ ขวบ [ดวงตก]'),
        ]),
        LifePeriodStatusMetadataValues.duengTok,
      );
    });

    test('no marker produces no periodStatus id', () {
      expect(
        ThaiCanonPeriodStatusFromEvidence.canonIdFromLifePeriodRefs([
          refWithContext('อาย ๑๐ ขวบ'),
        ]),
        isNull,
      );
    });

    test('mixed markers are ambiguous', () {
      expect(
        ThaiCanonPeriodStatusFromEvidence.canonIdFromLifePeriodRefs([
          refWithContext('อาย ๓ ขวบ [ดวงขึ้น]'),
          refWithContext('อาย ๕ ขวบ [ดวงตก]'),
        ]),
        isNull,
      );
    });

    test('does not infer from mahabhut object or non-life_period context', () {
      final positionOnly = ThaiCanonEvidenceRef(
        unitId: 'test.unit',
        relation: 'located_in',
        subject: 'planet.jupiter',
        object: 'mahabhutPosition.marana',
        sourceBookId: 'mahabhut',
        contextType: 'archetypeChart',
        contextValue: 'ดวงนักวิชาการ',
        safety: ThaiCanonEvidenceSafety.traceabilityInternal,
      );
      expect(
        ThaiCanonPeriodStatusFromEvidence.canonIdFromLifePeriodRefs([
          positionOnly,
        ]),
        isNull,
      );
    });
  });

  group('ThaiReportCanonEvidenceEnricher canon-derived annotation', () {
    test('attaches internal periodStatus when marker is unambiguous', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      final derived = bundle.attachments.where(
        (a) => a.signalId.contains(':periodStatus:canonDerived:'),
      );
      expect(derived, isNotEmpty);
      for (final attachment in derived) {
        expect(attachment.userFacingAllowed, isFalse);
        expect(attachment.internalOnly, isTrue);
        expect(attachment.evidenceType, ThaiCanonEvidenceType.periodStatusStructural);
        expect(
          attachment.signalId.contains('periodStatus.duengKhuen') ||
              attachment.signalId.contains('periodStatus.duengTok'),
          isTrue,
        );
      }
      expect(bundle.trace.lifePeriodsWithCanonDerivedStatus, isNotEmpty);
    });

    test('runtime blocker remains visible', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.lifePeriodStatusMetadataBlocker,
        LifePeriodPositionMetadataBlocker.partialPositionMetadata,
      );
      expect(bundle.trace.lifePeriodsWithoutRuntimeStatus, isNotEmpty);
    });

    test('lifePeriodsWithoutRuntimeStatus tracked separately from canon-derived',
        () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.lifePeriodsWithoutRuntimeStatus.length,
        pipeline.lifePeriods!.periods.length,
      );
      expect(
        bundle.trace.lifePeriodsWithCanonDerivedStatus.length,
        lessThanOrEqualTo(
          bundle.trace.lifePeriodsWithoutRuntimeStatus.length,
        ),
      );
    });

    test('QA runtime override takes precedence over canon-derived', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
        periodStatusLabelsByIndex: {0: 'ดวงขึ้น'},
      );

      expect(
        bundle.attachments.any(
          (a) =>
              a.signalId.startsWith('life_period:0:') &&
              a.signalId.contains(':periodStatus:canonDerived:'),
        ),
        isFalse,
      );
      expect(
        bundle.attachments.any(
          (a) =>
              a.signalId.startsWith('life_period:0:') &&
              a.signalId.contains(':periodStatus:ดวงขึ้น'),
        ),
        isTrue,
      );
      expect(bundle.trace.lifePeriodStatusMetadataBlocker, isNull);
    });

    test('canon-derived attachments classify as INTERNAL_ONLY', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
        fixtures: [ThaiCanonEvidenceAlignmentFixtures.qaSample],
      );
      final derivedRecords = audit.fixtureResults.first.records.where(
        (r) =>
            r.attachmentIndex != null &&
            r.signalId.contains(':periodStatus:canonDerived:'),
      );
      expect(derivedRecords, isNotEmpty);
      for (final record in derivedRecords) {
        expect(
          record.classification,
          ThaiCanonEvidenceAlignmentClassification.internalOnly,
        );
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
      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.remedyInternal,
        ),
        isEmpty,
      );
    });

    test('user-facing fingerprint unchanged', () async {
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
  });
}
