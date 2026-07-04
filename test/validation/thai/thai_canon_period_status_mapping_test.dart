import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Thai Canon Period Status Mapping — evidence layer only.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('ThaiCanonPeriodStatusRuntimeMapping', () {
    test('Canon index includes p17 and p40-41 periodStatus units', () async {
      final khuenRefs = repository.mapper.evidenceForPeriodStatusCanonId(
        'periodStatus.duengKhuen',
      );
      final tokRefs = repository.mapper.evidenceForPeriodStatusCanonId(
        'periodStatus.duengTok',
      );
      expect(khuenRefs.map((r) => r.sourcePage).toSet(), contains('17'));
      expect(khuenRefs.map((r) => r.sourcePage).toSet(), contains('41'));
      expect(tokRefs.map((r) => r.sourcePage).toSet(), contains('17'));
      expect(tokRefs.map((r) => r.sourcePage).toSet(), contains('40'));
    });

    test('periodStatus.duengKhuen maps deterministically to ดวงขึ้น', () {
      expect(
        ThaiCanonPeriodStatusRuntimeMapping.canonIdForRuntimeLabel('ดวงขึ้น'),
        'periodStatus.duengKhuen',
      );
      expect(
        ThaiCanonPeriodStatusRuntimeMapping.runtimeLabelForCanonId(
          'periodStatus.duengKhuen',
        ),
        'ดวงขึ้น',
      );
    });

    test('periodStatus.duengTok maps deterministically to ดวงตก', () {
      expect(
        ThaiCanonPeriodStatusRuntimeMapping.canonIdForRuntimeLabel('ดวงตก'),
        'periodStatus.duengTok',
      );
      expect(
        ThaiCanonPeriodStatusRuntimeMapping.runtimeLabelForCanonId(
          'periodStatus.duengTok',
        ),
        'ดวงตก',
      );
    });

    test('non-exact labels are rejected', () {
      expect(
        ThaiCanonPeriodStatusRuntimeMapping.canonIdForRuntimeLabel('ดวงดี'),
        isNull,
      );
      expect(
        ThaiCanonPeriodStatusDiscovery.discover(
          ThaiMirrorPipeline.generate(ThaiMirrorPipeline.sampleQaBirthData()),
          labelsByPeriodIndex: {0: 'ดวงดี'},
        ),
        isEmpty,
      );
    });
  });

  group('ThaiReportCanonEvidenceEnricher period status attachments', () {
    Future<ThaiMirrorCanonEvidenceBundle> enrichWithLabels(
      Map<int, String> labels,
    ) async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      return ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
        periodStatusLabelsByIndex: labels,
      );
    }

    test('life-period with ดวงขึ้น attaches periodStatus evidence', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      expect(
        pipeline.lifePeriods!.periods.any((p) => p.index == 0),
        isTrue,
      );
      final bundle = await enrichWithLabels({0: 'ดวงขึ้น'});
      final attachments = bundle.attachments.where(
        (a) =>
            a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural &&
            a.signalId.contains(':periodStatus:ดวงขึ้น'),
      );
      expect(attachments, isNotEmpty);
      expect(
        attachments.first.evidenceRefs.any(
          (r) =>
              r.subject == 'periodStatus.duengKhuen' ||
              r.object == 'periodStatus.duengKhuen',
        ),
        isTrue,
      );
      expect(
        attachments.first.evidenceRefs.any((r) => r.sourcePage == '17'),
        isTrue,
        reason: attachments.first.evidenceRefs
            .map((r) => '${r.unitId}:${r.sourcePage}')
            .join('; '),
      );
      expect(
        attachments.first.evidenceRefs.any((r) => r.sourcePage == '41'),
        isTrue,
      );
    });

    test('life-period with ดวงตก attaches periodStatus evidence', () async {
      final bundle = await enrichWithLabels({1: 'ดวงตก'});
      final attachments = bundle.attachments.where(
        (a) =>
            a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural &&
            a.signalId.contains(':periodStatus:ดวงตก'),
      );
      expect(attachments, isNotEmpty);
      expect(
        attachments.first.evidenceRefs.any(
          (r) =>
              r.subject == 'periodStatus.duengTok' ||
              r.object == 'periodStatus.duengTok',
        ),
        isTrue,
      );
      expect(
        attachments.first.evidenceRefs.any((r) => r.sourcePage == '17'),
        isTrue,
      );
      expect(
        attachments.first.evidenceRefs.any((r) => r.sourcePage == '40'),
        isTrue,
      );
    });

    test('no periodStatus evidence when runtime status is absent', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );

      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural,
        ),
        isEmpty,
      );
      expect(bundle.trace.skippedPeriodStatusNotes, isEmpty);
      expect(bundle.trace.lifePeriodsWithoutRuntimeStatus, isNotEmpty);
    });

    test('periodStatus evidence remains userFacingAllowed = false', () async {
      final bundle = await enrichWithLabels({0: 'ดวงขึ้น', 2: 'ดวงตก'});
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
        expect(attachment.internalOnly, isTrue);
      }
    });

    test('predictionEffect evidence stays internal metadata only', () async {
      final bundle = await enrichWithLabels({0: 'ดวงขึ้น'});
      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.predictionRule,
        ),
        isEmpty,
      );
      final statusAttachment = bundle.attachments.firstWhere(
        (a) => a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural,
      );
      expect(
        statusAttachment.evidenceRefs.any(
          (r) => r.object.startsWith('predictionEffect.'),
        ),
        isTrue,
      );
    });

    test('skippedPeriodStatusNotes is zero after mapping', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      expect(bundle.trace.skippedPeriodStatusNotes, isEmpty);
    });
  });

  group('Safety boundaries unchanged', () {
    test('mahabhuta_thaya remains OUT_OF_CANON_SCOPE', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );
      final thayaRecords = audit.fixtureResults.expand((r) => r.records).where(
            (r) => r.signalId.contains(ThaiContentKeys.mahabhutaThaya),
          );
      expect(thayaRecords, isNotEmpty);
      for (final record in thayaRecords) {
        expect(
          record.classification,
          ThaiCanonEvidenceAlignmentClassification.outOfCanonScope,
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

    test('Taksa roles remain unmapped in this phase', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      expect(
        bundle.trace.unmappedCanonEvidenceCandidates.any(
          (id) => id.startsWith('taksaRole.'),
        ),
        isTrue,
      );
      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.taksa,
        ),
        isEmpty,
      );
    });
  });

  group('Public surface isolation', () {
    test('user-facing fingerprint unchanged after period status enrichment', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final before =
          ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);
      await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
        periodStatusLabelsByIndex: {0: 'ดวงขึ้น', 1: 'ดวงตก'},
      );
      expect(
        ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline),
        before,
      );
    });

    test('public Thai beta page does not import period status mapping', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiCanonPeriodStatusRuntimeMapping'), isFalse);
    });
  });
}
