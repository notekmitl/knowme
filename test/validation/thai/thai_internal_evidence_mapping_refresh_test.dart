import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_mapping_refresh.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_validator.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_internal_evidence_qa_runner.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_signal_scope.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Internal Evidence Mapping Refresh — post Taksa + Khumsap integration QA.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiInternalEvidenceQaAudit audit;
  late ThaiInternalEvidenceMappingCoverageReport coverage;
  late ThaiInternalEvidenceRefreshAggregate refresh;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiInternalEvidenceQaRunner.run(repository: repository);
    coverage =
        ThaiInternalEvidenceMappingCoverageReport.fromRepository(repository);
    refresh = ThaiInternalEvidenceRefreshAggregate.fromAudit(audit);
  });

  group('Mapping coverage refresh', () {
    test('Mahabhut positions mapped 7 / 7', () {
      expect(coverage.mahabhutPositionsMapped, 7);
      expect(coverage.mahabhutPositionsTotal, 7);
    });

    test('mahabhutPosition.khumsap is mapped', () {
      expect(coverage.khumsapMapped, isTrue);
      expect(coverage.khumsapInternalRuntimeKey, 'mahabhuta_khumsap');
    });

    test('mahabhuta_thaya remains OUT_OF_CANON_SCOPE', () {
      expect(coverage.mahabhutaThayaOutOfCanonScope, isTrue);
      expect(
        ThaiCanonEvidenceSignalScope.isOutOfCanonScope(
          ThaiContentKeys.mahabhutaThaya,
        ),
        isTrue,
      );
    });

    test('Taksa roles mapped 8 / 8', () {
      expect(coverage.taksaRolesMapped, 8);
      expect(coverage.taksaRolesTotal, 8);
    });

    test('Taksa rotation supports Monday + Tuesday only', () {
      expect(coverage.taksaSupportedWeekdays, [2, 3]);
      expect(coverage.taksaPartialReviewWeekdays, [1]);
      expect(coverage.taksaNotInSourceWeekdays, [4, 5, 6, 7]);
    });

    test('khumsap not in unmapped Canon candidates', () {
      expect(
        refresh.unmappedCanonCandidateIds,
        isNot(contains('mahabhutPosition.khumsap')),
      );
    });

    test('Canon atomic count is 834', () {
      expect(coverage.canonAtomicCount, 834);
    });
  });

  group('Taksa rotation refresh across fixtures', () {
    test('qa_sample Tuesday attaches 8 Taksa rotation evidence rows', () {
      final qa = audit.fixtureResults
          .firstWhere((r) => r.fixtureId == 'qa_sample');
      expect(qa.bundle.trace.taksaRotationAssignmentCount, 8);
      expect(qa.bundle.trace.taksaEvidenceAttachedCount, 8);
      expect(qa.bundle.trace.taksaSupportedWeekdays, ['2', '3']);
    });

    test('Sunday harness remains partial review required', () {
      final sunday = ThaiCanonEvidenceAlignmentFixtures.all
          .firstWhere((f) => f.id == 'harness_g');
      expect(sunday.birthData.thaiWeekdayNumber, 1);
      final result = audit.fixtureResults
          .firstWhere((r) => r.fixtureId == 'harness_g');
      expect(
        result.bundle.trace.taksaRotationBlocker,
        TaksaRotationBlocker.partialSourceReviewRequired,
      );
      expect(result.bundle.trace.taksaEvidenceAttachedCount, 0);
    });

    test('Monday harness attaches 8 Taksa rotation rows', () {
      final result = audit.fixtureResults
          .firstWhere((r) => r.fixtureId == 'harness_d');
      expect(result.bundle.trace.taksaRotationAssignmentCount, 8);
      expect(result.bundle.trace.taksaEvidenceAttachedCount, 8);
    });

    test('Wednesday harness returns NOT_IN_SOURCE', () {
      final result = audit.fixtureResults
          .firstWhere((r) => r.fixtureId == 'harness_e');
      expect(
        result.bundle.trace.taksaRotationBlocker,
        TaksaRotationBlocker.notInSource,
      );
    });

    test('unsupported weekdays are not inferred', () {
      for (final id in ['harness_a', 'harness_c', 'harness_e', 'harness_f', 'harness_h']) {
        final result =
            audit.fixtureResults.firstWhere((r) => r.fixtureId == id);
        expect(result.bundle.trace.taksaRotationAssignmentCount, 0);
      }
    });

    test('Wednesday daytime and night cases remain separate in metadata', () {
      final auditMeta = ThaiTaksaRotationFeasibilityAudit.audit(
        repository: repository,
      );
      expect(
        ThaiTaksaNotInSourceWeekdayCase.wednesdayDaytime,
        isNot(equals(ThaiTaksaNotInSourceWeekdayCase.wednesdayNightRahu)),
      );
      expect(auditMeta.wednesdayDaytimeStatus, TaksaRotationBlocker.notInSource);
      expect(auditMeta.wednesdayNightRahuStatus, TaksaRotationBlocker.notInSource);
    });
  });

  group('Khumsap refresh', () {
    test('Khumsap mapped on all fixtures', () {
      for (final result in audit.fixtureResults) {
        expect(result.bundle.trace.khumsapMapped, isTrue);
      }
    });

    test('Khumsap not attached via mahabhuta_thaya signal', () {
      for (final result in audit.fixtureResults) {
        for (final attachment in result.bundle.attachments) {
          expect(
            attachment.signalId.contains(ThaiContentKeys.mahabhutaThaya),
            isFalse,
          );
        }
      }
    });
  });

  group('QA validator refresh', () {
    test('badge mismatch count remains 0', () {
      expect(audit.totalBadgeMismatches, 0);
    });

    test('provenance gap count remains 0', () {
      expect(audit.totalProvenanceGaps, 0);
    });

    test('all evidence rows remain userFacingAllowed = false', () {
      for (final result in audit.fixtureResults) {
        for (final attachment in result.bundle.attachments) {
          expect(attachment.userFacingAllowed, isFalse);
        }
      }
    });

    test('remedies remain hidden/internal', () {
      expect(audit.remedySafety.passed, isTrue);
      expect(audit.remedySafety.remedyAttachmentsOnReport, 0);
      expect(audit.remedySafety.skippedRemedyCountAggregate, 87 * 9);
    });

    test('writes refreshed QA summary artifact', () {
      final map = ThaiInternalEvidenceQaReport.toMapFromRepository(
        audit: audit,
        repository: repository,
      );
      File('tool/output/thai_internal_evidence_qa_summary.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(map)}\n',
      );
      expect(map['mappingCoverage'], isNotNull);
      expect(map['evidenceRefresh'], isNotNull);
    });
  });

  group('Public isolation', () {
    test('public Thai report fingerprint unchanged', () async {
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

    test('public pages do not import review panel', () {
      for (final path in [
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
        'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source.contains('ThaiCanonEvidenceReviewPage'), isFalse);
        expect(source.contains('ThaiInternalEvidenceBadge'), isFalse);
      }
    });
  });
}
