import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_summary.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_internal_evidence_badge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classifier.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_runner.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_validator.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Internal Evidence QA Pass — formal audit across 9 deterministic fixtures.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiInternalEvidenceQaAudit audit;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiInternalEvidenceQaRunner.run(repository: repository);
  });

  group('ThaiInternalEvidenceQaRunner', () {
    test('audits all 9 deterministic fixtures', () {
      expect(audit.fixtureResults.length, 9);
      final ids = audit.fixtureResults.map((r) => r.fixtureId).toList();
      expect(ids, contains('qa_sample'));
      for (final letter in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        expect(ids, contains('harness_$letter'));
      }
    });

    test('runner is deterministic across two runs', () async {
      final first = await ThaiInternalEvidenceQaRunner.run(
        repository: repository,
      );
      final second = await ThaiInternalEvidenceQaRunner.run(
        repository: repository,
      );
      expect(
        ThaiInternalEvidenceQaReport.toMap(first),
        ThaiInternalEvidenceQaReport.toMap(second),
      );
    });

    test('writes aggregate QA summary artifact', () {
      final json = ThaiInternalEvidenceQaReport.toJson(audit);
      final map = ThaiInternalEvidenceQaReport.toMapFromRepository(
        audit: audit,
        repository: repository,
      );
      final outDir = Directory('tool/output');
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      File('tool/output/thai_internal_evidence_qa_summary.json')
          .writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(map)}\n');
      expect(File('tool/output/thai_internal_evidence_qa_summary.json').existsSync(),
          isTrue);
      expect(map['phase'], 'Internal Evidence Mapping Refresh');
      expect(json, isNotEmpty);
    });
  });

  group('Badge correctness audit', () {
    test('no badge mismatches across fixtures', () {
      expect(audit.totalBadgeMismatches, 0);
      for (final result in audit.fixtureResults) {
        expect(result.badgeMismatches, isEmpty);
      }
    });

    test('weak evidence is never CANON_SUPPORTED', () {
      expect(audit.totalWeakPromoted, 0);
      for (final result in audit.fixtureResults) {
        expect(result.weakPromotedToStrong, isEmpty);
        for (final attachment in result.bundle.attachments) {
          final (classification, _) =
              ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(
            attachment,
          );
          final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
            attachment,
            trace: result.bundle.trace,
          );
          if (classification !=
                  ThaiCanonEvidenceAlignmentClassification.strongMatch ||
              attachment.evidenceType ==
                  ThaiCanonEvidenceType.periodStatusStructural ||
              attachment.signalId.contains(':periodStatus:canonDerived:')) {
            if (classification ==
                    ThaiCanonEvidenceAlignmentClassification.relatedButWeak ||
                classification ==
                    ThaiCanonEvidenceAlignmentClassification.unmappedSignal ||
                classification ==
                    ThaiCanonEvidenceAlignmentClassification.internalOnly) {
              expect(badge, isNot(ThaiInternalEvidenceBadgeCategory.canonSupported));
            }
          }
        }
      }
    });

    test('badge assigner supports all ten categories', () {
      const traceabilitySafety = ThaiCanonEvidenceSafety.traceabilityInternal;
      ThaiCanonEvidenceRef ref({
        required String unitId,
        required String subject,
        required String object,
        String relation = 'owns',
      }) {
        return ThaiCanonEvidenceRef(
          unitId: unitId,
          relation: relation,
          subject: subject,
          object: object,
          sourceBookId: 'mahabhut',
          sourcePage: 'p1',
          safety: traceabilitySafety,
        );
      }

      final produced = <ThaiInternalEvidenceBadgeCategory>{};

      final qaBundle = audit.fixtureResults
          .firstWhere((r) => r.fixtureId == 'qa_sample')
          .bundle;

      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forAttachment(
          qaBundle.attachments.firstWhere((a) {
            final (classification, _) =
                ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(a);
            return classification ==
                    ThaiCanonEvidenceAlignmentClassification.strongMatch &&
                a.evidenceType != ThaiCanonEvidenceType.periodStatusStructural;
          }),
          trace: qaBundle.trace,
        ),
      );

      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forAttachment(
          ThaiCanonEvidenceAttachment(
            signalId: 'prediction:trace:weak',
            evidenceType: ThaiCanonEvidenceType.predictionRule,
            evidenceRefs: [
              ref(
                unitId: 'unit.prediction',
                subject: 'periodStatus.duengKhuen',
                object: 'periodStatus.duengKhuen',
              ),
            ],
          ),
        ),
      );

      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forAttachment(
          ThaiCanonEvidenceAttachment(
            signalId: 'lifePeriod:0:periodStatus:canonDerived:periodStatus.duengKhuen',
            evidenceType: ThaiCanonEvidenceType.periodStatusStructural,
            evidenceRefs: [
              ref(
                unitId: 'unit.derived',
                subject: 'periodStatus.duengKhuen',
                object: 'periodStatus.duengKhuen',
              ),
            ],
          ),
        ),
      );

      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forAttachment(
          qaBundle.attachments.firstWhere(
            (a) =>
                a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural &&
                !a.signalId.contains(':periodStatus:canonDerived:'),
          ),
          trace: qaBundle.trace,
        ),
      );

      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
          qaBundle.trace.outOfCanonScopeSignals.first,
          trace: qaBundle.trace,
        ),
      );
      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forRuntimeBlocker('8:AMBIGUOUS_POSITION'),
      );
      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
          'trace:SOURCE_CONFLICT:${qaBundle.trace.conflictedArchetypePlanetPairs.first}',
          trace: qaBundle.trace,
        ),
      );
      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forAttachment(
          ThaiCanonEvidenceAttachment(
            signalId: 'trace:remedy:unit.remedy.1',
            evidenceType: ThaiCanonEvidenceType.remedyInternal,
            evidenceRefs: [
              ref(
                unitId: 'unit.remedy.1',
                subject: 'remedy.subject',
                object: 'remedy.object',
              ),
            ],
          ),
        ),
      );
      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
          'trace:internal:skipped_taksa',
          trace: qaBundle.trace,
        ),
      );

      produced.add(
        ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
          'trace:unmapped:planet.ketu',
          trace: ThaiCanonEvidenceTrace(
            inCanonScopeUnmappedSignals: const ['trace:unmapped:planet.ketu'],
          ),
        ),
      );

      expect(produced, ThaiInternalEvidenceBadgeCategory.values.toSet());
    });

    test('aggregate audit produces core badge categories on fixtures', () {
      expect(audit.allCategoriesProduced, containsAll([
        'CANON_SUPPORTED',
        'RUNTIME_METADATA_SUPPORTED',
        'CANON_DERIVED_INTERNAL',
        'OUT_OF_CANON_SCOPE',
        'BLOCKED_AMBIGUOUS',
        'BLOCKED_SOURCE_CONFLICT',
        'REMEDY_HIDDEN',
      ]));
    });

    test('runtime periodStatus strong matches are RUNTIME_METADATA_SUPPORTED',
        () {
      var found = false;
      for (final result in audit.fixtureResults) {
        for (final attachment in result.bundle.attachments) {
          if (attachment.evidenceType !=
                  ThaiCanonEvidenceType.periodStatusStructural ||
              attachment.signalId.contains(':periodStatus:canonDerived:')) {
            continue;
          }
          final (classification, _) =
              ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(
            attachment,
          );
          if (classification ==
              ThaiCanonEvidenceAlignmentClassification.strongMatch) {
            found = true;
            expect(
              ThaiInternalEvidenceBadgeAssigner.forAttachment(
                attachment,
                trace: result.bundle.trace,
              ),
              ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported,
            );
          }
        }
      }
      expect(found, isTrue);
    });

    test('canon-derived period status is CANON_DERIVED_INTERNAL', () {
      final derived = audit.fixtureResults
          .expand((r) => r.bundle.attachments)
          .where((a) => a.signalId.contains(':periodStatus:canonDerived:'));
      expect(derived, isNotEmpty);
      for (final attachment in derived) {
        expect(
          ThaiInternalEvidenceBadgeAssigner.forAttachment(
            attachment,
            trace: audit.fixtureResults.first.bundle.trace,
          ),
          ThaiInternalEvidenceBadgeCategory.canonDerivedInternal,
        );
      }
    });

    test('ambiguous blockers map to BLOCKED_AMBIGUOUS', () {
      expect(audit.runtimeMetadata.blockedAmbiguous, 18);
      for (final result in audit.fixtureResults) {
        for (final entry
            in result.bundle.trace.runtimeStatusWithoutPositionBreakdown) {
          if (!entry.contains('AMBIGUOUS_POSITION')) continue;
          expect(
            ThaiInternalEvidenceBadgeAssigner.forRuntimeBlocker(entry),
            ThaiInternalEvidenceBadgeCategory.blockedAmbiguous,
          );
        }
      }
    });

    test('source conflict blockers map to BLOCKED_SOURCE_CONFLICT', () {
      expect(audit.runtimeMetadata.blockedSourceConflict, 3);
      expect(audit.runtimeMetadata.conflictedArchetypePlanetPairs, 1);
      for (final result in audit.fixtureResults) {
        for (final pair in result.bundle.trace.conflictedArchetypePlanetPairs) {
          expect(
            ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
              'trace:SOURCE_CONFLICT:$pair',
              trace: result.bundle.trace,
            ),
            ThaiInternalEvidenceBadgeCategory.blockedSourceConflict,
          );
        }
      }
    });
  });

  group('Evidence provenance audit', () {
    test('no provenance gaps on evidence rows', () {
      expect(audit.totalProvenanceGaps, 0);
    });

    test('every evidence row preserves page provenance', () {
      for (final result in audit.fixtureResults) {
        final rows = flattenEvidenceRows(result.bundle);
        expect(rows, isNotEmpty);
        for (final row in rows) {
          expect(row.unitId, isNotEmpty);
          expect(row.subject, isNotEmpty);
          expect(row.relation, isNotEmpty);
          expect(row.object, isNotEmpty);
          expect(row.sourcePage, isNotEmpty);
        }
      }
    });

    test('all evidence rows remain userFacingAllowed = false', () {
      for (final result in audit.fixtureResults) {
        for (final row in flattenEvidenceRows(result.bundle)) {
          expect(row.userFacingAllowed, isFalse);
        }
        for (final attachment in result.bundle.attachments) {
          expect(attachment.userFacingAllowed, isFalse);
        }
      }
    });
  });

  group('Runtime metadata audit', () {
    test('aggregate runtime status counts match baseline', () {
      expect(audit.runtimeMetadata.lifePeriodsWithRuntimeStatus, 65);
      expect(audit.runtimeMetadata.lifePeriodsWithoutRuntimeStatus, 21);
      expect(audit.runtimeMetadata.blockedAmbiguous, 18);
      expect(audit.runtimeMetadata.blockedNoP17Rule, 0);
      expect(
        audit.runtimeMetadata.blockedAmbiguous +
            audit.runtimeMetadata.blockedSourceConflict +
            audit.runtimeMetadata.blockedMissingPosition,
        21,
      );
    });

    test('per-fixture blocker breakdown is explicit', () {
      for (final result in audit.fixtureResults) {
        final trace = result.bundle.trace;
        expect(
          trace.runtimeStatusBlockedByAmbiguousPosition.length +
              trace.runtimeStatusBlockedBySourceConflict.length +
              trace.runtimeStatusBlockedByMissingPosition.length +
              trace.runtimeStatusBlockedByNoP17Rule.length,
          trace.lifePeriodsWithoutPositionMetadata.length,
        );
      }
    });
  });

  group('Remedy safety audit', () {
    test('remedies are REMEDY_HIDDEN only and never on report attachments', () {
      expect(audit.remedySafety.passed, isTrue);
      expect(audit.remedySafety.remedyAttachmentsOnReport, 0);
      expect(audit.remedySafety.remedyUserFacingRows, 0);
      expect(audit.remedySafety.skippedRemedyCountAggregate, 87 * 9);
      for (final count in audit.remedySafety.perFixtureSkippedCounts) {
        expect(count, 87);
      }
    });
  });

  group('Public isolation audit', () {
    test('Thai beta report page does not import internal QA components', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiInternalEvidenceBadge'), isFalse);
      expect(source.contains('ThaiCanonEvidenceReviewPage'), isFalse);
      expect(source.contains('thai_internal_evidence'), isFalse);
    });

    test('Thai mirror result page does not import internal QA components', () {
      final source = File(
        'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiInternalEvidenceBadge'), isFalse);
      expect(source.contains('ThaiCanonEvidenceReviewPage'), isFalse);
      expect(source.contains('ThaiReportCanonEvidenceEnricher'), isFalse);
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

    test('consumer report timeline text unchanged', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );
      for (final period in view.lifeTimeline!.periods) {
        expect(period.summary.contains('ดวงขึ้น'), isFalse);
        expect(period.summary.contains('ดวงตก'), isFalse);
      }
    });
  });

  group('Reviewer usability', () {
    testWidgets('internal review panel renders badge summary', (tester) async {
      final bundle = audit.fixtureResults
          .firstWhere((r) => r.fixtureId == 'qa_sample')
          .bundle;

      await tester.pumpWidget(
        MaterialApp(
          home: ThaiCanonEvidenceReviewPage(initialBundle: bundle),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thai Canon Evidence Review'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.textContaining('Remedy skipped:'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Evidence badges (internal QA only)'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Evidence badges (internal QA only)'), findsOneWidget);
      expect(find.textContaining('Canon Supported:'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.textContaining('Evidence table'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Badge'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('QA blockers (internal)'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('QA blockers (internal)'), findsOneWidget);
    });
  });
}
