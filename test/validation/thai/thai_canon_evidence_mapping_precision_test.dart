import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Thai Canon Evidence Mapping Precision Pass validation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiCanonEvidenceAlignmentAudit audit;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiCanonEvidenceAlignmentRunner.run(repository: repository);
  });

  group('OUT_OF_CANON_SCOPE classification', () {
    test('Myanmar seven signals are out of Canon scope', () {
      final records = audit.fixtureResults
          .expand((r) => r.records)
          .where(
            (r) =>
                r.signalId.contains('myanmar_seven') &&
                r.classification ==
                    ThaiCanonEvidenceAlignmentClassification.outOfCanonScope,
          );
      expect(records, isNotEmpty);
      expect(
        audit.fixtureResults.any(
          (r) => r.records.any(
            (rec) =>
                rec.classification ==
                    ThaiCanonEvidenceAlignmentClassification.unmappedSignal &&
                rec.signalId.contains('myanmar_seven'),
          ),
        ),
        isFalse,
      );
    });

    test('Lagna sign signals are out of Canon scope', () {
      final lagnaOut = audit.fixtureResults.expand((r) => r.records).where(
            (r) =>
                r.signalId.contains('lagna_cancer') &&
                !r.signalId.contains('lagna_lord') &&
                r.classification ==
                    ThaiCanonEvidenceAlignmentClassification.outOfCanonScope,
          );
      expect(lagnaOut, isNotEmpty);
    });
  });

  group('mahabhuta_thaya decision', () {
    test('not mapped — classified out of Canon scope with reason', () {
      final thayaRecords = audit.fixtureResults
          .expand((r) => r.records)
          .where((r) => r.signalId.contains(ThaiContentKeys.mahabhutaThaya));

      expect(thayaRecords, isNotEmpty);
      for (final record in thayaRecords) {
        expect(
          record.classification,
          ThaiCanonEvidenceAlignmentClassification.outOfCanonScope,
        );
        expect(record.reason, contains('khumsap'));
        expect(record.reason, contains('equivalence not inferred'));
      }

      final qa = audit.fixtureResults.firstWhere(
        (r) => r.fixture.id == 'qa_sample',
      );
      expect(
        qa.bundle.attachments.any(
          (a) => a.signalId.contains(ThaiContentKeys.mahabhutaThaya),
        ),
        isFalse,
      );
    });
  });

  group('Weak evidence precision', () {
    test('planet signification attachments require owns relation', () {
      for (final result in audit.fixtureResults) {
        for (final attachment in result.bundle.attachments) {
          if (attachment.evidenceType !=
              ThaiCanonEvidenceType.planetSignification) {
            continue;
          }
          expect(
            attachment.evidenceRefs.every((r) => r.relation == 'owns'),
            isTrue,
            reason: attachment.signalId,
          );
          expect(
            attachment.evidenceRefs.any((r) => r.object.startsWith('attribute.')),
            isFalse,
          );
        }
      }
    });

    test('prediction rules are trace-only not section attachments', () {
      for (final result in audit.fixtureResults) {
        expect(
          result.bundle.attachments.where(
            (a) => a.evidenceType == ThaiCanonEvidenceType.predictionRule,
          ),
          isEmpty,
        );
        expect(result.bundle.trace.traceOnlyEvidenceCandidates, isNotEmpty);
      }
    });

    test('no attachment is promoted to STRONG_MATCH when only weak trace exists',
        () {
      for (final result in audit.fixtureResults) {
        for (final record in result.records) {
          if (record.classification ==
              ThaiCanonEvidenceAlignmentClassification.strongMatch) {
            expect(record.attachmentIndex, isNotNull);
          }
        }
      }
    });
  });

  group('Safety boundaries', () {
    test('remedies remain skipped and never user-facing', () {
      for (final result in audit.fixtureResults) {
        expect(result.bundle.trace.skippedRemedyEvidenceCount, 87);
        for (final attachment in result.bundle.attachments) {
          expect(attachment.userFacingAllowed, isFalse);
        }
      }
    });

    test('lookup tables are not attached to broad report copy', () {
      for (final result in audit.fixtureResults) {
        expect(result.bundle.trace.skippedLookupTableEvidenceCount, 56);
        for (final attachment in result.bundle.attachments) {
          for (final ref in attachment.evidenceRefs) {
            expect(ref.domain, isNot('lookupTables'));
          }
        }
      }
    });
  });

  group('Determinism and public isolation', () {
    test('alignment audit remains deterministic', () async {
      final first = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
        fixtures: [ThaiCanonEvidenceAlignmentFixtures.qaSample],
      );
      final second = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
        fixtures: [ThaiCanonEvidenceAlignmentFixtures.qaSample],
      );
      expect(first.classificationCounts, second.classificationCounts);
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

    test('precision QA not imported by public Thai beta page', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiCanonEvidenceSignalScope'), isFalse);
    });
  });
}
