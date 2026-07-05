import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Thai Report Canon Evidence Upgrade — enrichment without user-facing changes.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('ThaiReportCanonEvidenceEnricher', () {
    test('runs after ThaiMirrorPipeline without mutating pipeline result', () async {
      final birth = ThaiMirrorPipeline.sampleQaBirthData();
      final pipeline = ThaiMirrorPipeline.generate(birth);
      expect(pipeline.isSuccess, isTrue);

      final fingerprintBefore =
          ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);
      final pipelineRef = pipeline.mirrorResult;

      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(identical(bundle.pipelineResult, pipeline), isTrue);
      expect(identical(bundle.pipelineResult.mirrorResult, pipelineRef), isTrue);
      expect(
        ThaiReportCanonEvidenceEnricher.userFacingFingerprint(bundle.pipelineResult),
        fingerprintBefore,
      );
    });

    test('user-facing fingerprint unchanged after enrichment with evidence added', () async {
      final birth = ThaiMirrorPipeline.sampleQaBirthData();
      final pipeline = ThaiMirrorPipeline.generate(birth);
      final before = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);

      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      final after = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        bundle.pipelineResult,
      );

      expect(before, after);
      expect(bundle.attachmentCount, greaterThan(0));
      expect(bundle.totalEvidenceRefs, greaterThan(0));
    });

    test('Mahabhut position evidence attaches where deterministic', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      final mahabhutAttachments = bundle.attachments.where(
        (a) => a.evidenceType == ThaiCanonEvidenceType.mahabhutPosition,
      );
      expect(mahabhutAttachments, isNotEmpty);

      final thongchai = bundle.attachments.where(
        (a) => a.signalId.contains(ThaiContentKeys.mahabhutaThongchai),
      );
      expect(thongchai, isNotEmpty);
      expect(
        thongchai.first.evidenceRefs.any(
          (r) => r.object == 'mahabhutPosition.thongchai',
        ),
        isTrue,
      );
    });

    test('planet/domain evidence attaches for lagna lord signals', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      final planetAttachments = bundle.attachments.where(
        (a) => a.evidenceType == ThaiCanonEvidenceType.planetSignification,
      );
      expect(planetAttachments, isNotEmpty);
      expect(
        planetAttachments.first.evidenceRefs.every((r) => r.relation == 'owns'),
        isTrue,
      );
    });

    test('life-period structural evidence attaches where deterministic', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      final lifeAttachments = bundle.attachments.where(
        (a) => a.evidenceType == ThaiCanonEvidenceType.lifePeriodStructural,
      );
      expect(lifeAttachments, isNotEmpty);
      expect(
        lifeAttachments.first.evidenceRefs.every(
          (r) => r.contextType == 'life_period' && r.sourcePage != null,
        ),
        isTrue,
      );
    });

    test('prediction rule evidence stays trace-only internal metadata', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.predictionRule,
        ),
        isEmpty,
      );
      expect(bundle.trace.traceOnlyEvidenceCandidates, isNotEmpty);
      expect(
        bundle.trace.traceOnlyEvidenceCandidates.first,
        startsWith('prediction:phase_e_rules'),
      );
    });

    test('lookup table evidence is not attached to report sections', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(bundle.trace.skippedLookupTableEvidenceCount, 56);
      for (final attachment in bundle.attachments) {
        for (final ref in attachment.evidenceRefs) {
          expect(ref.domain, isNot('lookupTables'));
        }
      }
    });

    test('mahabhuta_thaya is out of Canon scope not a mapping failure', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.trace.outOfCanonScopeSignals,
        contains('profile:mahabhuta_position:mahabhuta_thaya'),
      );
      expect(
        bundle.trace.inCanonScopeUnmappedSignals,
        isNot(contains('profile:mahabhuta_position:mahabhuta_thaya')),
      );
    });

    test('remedy evidence is never user-facing', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.remedyInternal,
        ),
        isEmpty,
      );
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
        expect(attachment.internalOnly, isTrue);
        for (final ref in attachment.evidenceRefs) {
          expect(ref.safety.isNotSafeForUserOutput, isFalse);
        }
      }
      expect(bundle.trace.skippedRemedyEvidenceCount, 87);
    });

    test('unmapped Taksa Ketu cases are reported; periodStatus mapping wired', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(bundle.trace.skippedTaksaEvidenceCount, greaterThan(0));
      expect(bundle.trace.skippedPeriodStatusNotes, isEmpty);
      expect(
        bundle.trace.lifePeriodsWithoutRuntimeStatus,
        isNotEmpty,
      );
      expect(
        bundle.trace.unmappedCanonEvidenceCandidates,
        contains('planet.ketu'),
      );
      expect(
        bundle.trace.unmappedCanonEvidenceCandidates.any(
          (id) => id.startsWith('taksaRole.'),
        ),
        isTrue,
      );
      expect(
        bundle.trace.unmappedCanonEvidenceCandidates.any(
          (id) => id.startsWith('periodStatus.'),
        ),
        isFalse,
      );
    });

    test('attachments preserve source page provenance', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      for (final attachment in bundle.attachments) {
        for (final ref in attachment.evidenceRefs) {
          expect(ref.sourcePage, isNotNull);
          expect(ref.sourcePage, isNotEmpty);
          expect(ref.sourceBookId, 'mahabhut');
        }
      }
    });

    test('pipeline object identity preserved (no mutation)', () async {
      final birth = ThaiBirthData(
        localDateTime: DateTime(1988, 3, 12, 14, 0),
        timeZoneOffset: const Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
        hasBirthTime: true,
      );
      final pipeline = ThaiMirrorPipeline.generate(birth);
      final mirrorBefore = pipeline.mirrorResult;
      final viewBefore = pipeline.viewState;
      final profileBefore = pipeline.profile;

      await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(identical(pipeline.mirrorResult, mirrorBefore), isTrue);
      expect(identical(pipeline.viewState, viewBefore), isTrue);
      expect(identical(pipeline.profile, profileBefore), isTrue);
    });
  });
}
