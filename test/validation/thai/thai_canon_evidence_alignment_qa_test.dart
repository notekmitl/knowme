import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Thai Canon Evidence Alignment QA — deterministic audit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiCanonEvidenceAlignmentAudit audit;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiCanonEvidenceAlignmentRunner.run(repository: repository);
  });

  group('ThaiCanonEvidenceAlignmentRunner', () {
    test('fixture set includes QA sample and weekday harness profiles', () {
      final ids = ThaiCanonEvidenceAlignmentFixtures.all.map((f) => f.id).toList();
      expect(ids, contains('qa_sample'));
      expect(ids, contains('harness_a'));
      expect(ids, contains('harness_h'));
      expect(ThaiCanonEvidenceAlignmentFixtures.all.length, 9);
    });

    test('runner is deterministic across two runs', () async {
      final first = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
        fixtures: [ThaiCanonEvidenceAlignmentFixtures.qaSample],
      );
      final second = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
        fixtures: [ThaiCanonEvidenceAlignmentFixtures.qaSample],
      );

      expect(first.classificationCounts, second.classificationCounts);
      expect(
        first.fixtureResults.first.attachmentCount,
        second.fixtureResults.first.attachmentCount,
      );
      expect(
        ThaiCanonEvidenceAlignmentReport.toJson(first),
        ThaiCanonEvidenceAlignmentReport.toJson(second),
      );
    });

    test('at least one fixture produces evidence attachments', () {
      expect(
        audit.fixtureResults.any((r) => r.attachmentCount > 0),
        isTrue,
      );
      expect(audit.fixtureResults.first.attachmentCount, greaterThan(0));
    });

    test('every attachment receives an alignment classification', () {
      for (final result in audit.fixtureResults) {
        expect(result.attachmentRecords.length, result.attachmentCount);
        for (final record in result.attachmentRecords) {
          expect(record.classification, isNotNull);
          expect(record.reason, isNotEmpty);
        }
      }
    });

    test('remedy evidence is skipped and never user-facing', () {
      for (final result in audit.fixtureResults) {
        expect(result.bundle.trace.skippedRemedyEvidenceCount, 87);
        expect(
          result.records.any(
            (r) =>
                r.classification ==
                ThaiCanonEvidenceAlignmentClassification.skippedRemedy,
          ),
          isTrue,
        );
        for (final attachment in result.bundle.attachments) {
          expect(attachment.userFacingAllowed, isFalse);
          expect(
            attachment.evidenceType,
            isNot(ThaiCanonEvidenceType.remedyInternal),
          );
        }
      }
      expect(audit.totalSkippedRemedyCount, 87 * audit.fixtureResults.length);
    });

    test('Taksa evidence is trace-only with mapped role keys', () {
      for (final result in audit.fixtureResults) {
        expect(result.bundle.trace.skippedTaksaEvidenceCount, greaterThan(0));
        expect(result.bundle.trace.taksaRolesMapped.length, 8);
        expect(
          result.bundle.trace.taksaSkippedReason,
          TaksaRuntimeSkippedReason.noRuntimeTaksaSignal,
        );
        expect(
          result.records.any(
            (r) =>
                r.classification ==
                ThaiCanonEvidenceAlignmentClassification.skippedTaksa,
          ),
          isTrue,
        );
        expect(
          result.bundle.trace.unmappedCanonEvidenceCandidates.any(
            (id) => id.startsWith('taksaRole.'),
          ),
          isFalse,
        );
      }
    });

    test('periodStatus mapping is wired; absent runtime status is trace-only', () {
      for (final result in audit.fixtureResults) {
        expect(result.bundle.trace.skippedPeriodStatusNotes, isEmpty);
        expect(
          result.bundle.trace.unmappedCanonEvidenceCandidates,
          isNot(contains('periodStatus.duengKhuen')),
        );
        expect(
          result.bundle.trace.unmappedCanonEvidenceCandidates,
          isNot(contains('periodStatus.duengTok')),
        );
        expect(
          result.records.any(
            (r) =>
                r.classification ==
                ThaiCanonEvidenceAlignmentClassification.skippedPeriodStatus,
          ),
          isFalse,
        );
        if (result.bundle.trace.lifePeriodsWithoutRuntimeStatus.isNotEmpty) {
          expect(
            result.bundle.trace.lifePeriodsWithoutRuntimeStatus,
            isNotEmpty,
          );
          expect(
            result.records.any(
              (r) => r.signalId.startsWith('trace:noStatusInRuntime:'),
            ),
            isTrue,
          );
        }
      }
      expect(audit.totalSkippedPeriodStatusNotes, 0);
      expect(audit.totalLifePeriodsWithoutRuntimeStatus, greaterThan(0));
    });

    test('one fixture has lower attachment coverage than QA sample', () {
      final qa = audit.fixtureResults.firstWhere(
        (r) => r.fixture.id == 'qa_sample',
      );
      final lowest = audit.fixtureResults.reduce(
        (a, b) => a.attachmentCount < b.attachmentCount ? a : b,
      );
      expect(lowest.attachmentCount, lessThanOrEqualTo(qa.attachmentCount));
      expect(lowest.fixture.id, 'harness_h');
    });

    test('markdown and json reports are non-empty', () {
      final md = ThaiCanonEvidenceAlignmentReport.toMarkdown(audit);
      final json = ThaiCanonEvidenceAlignmentReport.toJson(audit);
      expect(md, contains('Coverage metrics'));
      expect(json, contains('fixtureCount'));
    });
  });

  group('Public surface isolation', () {
    test('user-facing fingerprint unchanged after enrichment', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final before =
          ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);
      await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      final after =
          ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);
      expect(before, after);
    });

    test('public Thai beta report page does not import alignment QA', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiCanonEvidenceAlignment'), isFalse);
    });
  });
}
