import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Thai Life Period Status Metadata Layer — audit + blocked production path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('LifePeriodStatusMetadataResolver audit', () {
    test('production pipeline is blocked — status not on engine models', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      expect(pipeline.isSuccess, isTrue);

      final audit = LifePeriodStatusMetadataResolver.audit(pipeline.lifePeriods);
      expect(
        audit.finding,
        LifePeriodStatusMetadataAuditFinding.absentOnRuntime,
      );
      expect(
        audit.blocker,
        LifePeriodStatusMetadataBlocker.blockedByRuntimeStatusAbsence,
      );
      expect(audit.byPeriodIndex, isEmpty);
      expect(audit.periodCount, greaterThan(0));
    });

    test('allowed values are limited to the two Canon ids', () {
      expect(
        LifePeriodStatusMetadataValues.allowedCanonIds,
        {
          'periodStatus.duengKhuen',
          'periodStatus.duengTok',
        },
      );
    });

    test('discovery audit matches resolver on production pipeline', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final discoveryAudit = ThaiCanonPeriodStatusDiscovery.audit(pipeline);
      final resolverAudit =
          LifePeriodStatusMetadataResolver.audit(pipeline.lifePeriods);

      expect(discoveryAudit.finding, resolverAudit.finding);
      expect(discoveryAudit.blocker, resolverAudit.blocker);
      expect(discoveryAudit.byPeriodIndex, resolverAudit.byPeriodIndex);
    });
  });

  group('Canon evidence integration (production path)', () {
    test('production discovery does not attach periodStatus evidence', () async {
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
      expect(
        bundle.trace.lifePeriodStatusMetadataBlocker,
        LifePeriodStatusMetadataBlocker.blockedByRuntimeStatusAbsence,
      );
      expect(bundle.trace.skippedPeriodStatusNotes, isEmpty);
      expect(bundle.trace.lifePeriodsWithoutRuntimeStatus, isNotEmpty);
    });

    test('QA override still attaches when labels injected', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
        periodStatusLabelsByIndex: {0: 'ดวงขึ้น'},
      );

      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural,
        ),
        isNotEmpty,
      );
      expect(bundle.trace.lifePeriodStatusMetadataBlocker, isNull);
    });

    test('lifePeriodsWithoutRuntimeStatus unchanged while metadata blocked', () async {
      final auditBefore = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );

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
        auditBefore.totalLifePeriodsWithoutRuntimeStatus,
        86,
      );
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

    test('consumer report timeline text unchanged', () {
      final birth = ThaiMirrorPipeline.sampleQaBirthData();
      final pipeline = ThaiMirrorPipeline.generate(birth);
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );

      final timeline = view.lifeTimeline!;
      expect(timeline.sectionTitle, isNotEmpty);
      expect(timeline.periods, isNotEmpty);
      for (final period in timeline.periods) {
        expect(period.summary, isNotEmpty);
        expect(period.summary.contains('ดวงขึ้น'), isFalse);
        expect(period.summary.contains('ดวงตก'), isFalse);
      }
    });

    test('metadata layer not imported by public Thai beta page', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('LifePeriodStatusMetadataResolver'), isFalse);
      expect(source.contains('ThaiCanonPeriodStatusDiscovery'), isFalse);
    });
  });
}
