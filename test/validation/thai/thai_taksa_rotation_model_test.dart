import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Taksa Rotation Model — Monday + Tuesday source-backed rotation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  ThaiBirthData birthForWeekday(int year, int month, int day) => ThaiBirthData(
        localDateTime: DateTime(year, month, day, 12, 0),
        timeZoneOffset: const Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
      );

  group('ThaiTaksaRotationFeasibilityAudit', () {
    test('feasibility audit is READY_TO_IMPLEMENT_PARTIAL_ROTATION', () {
      final audit = ThaiTaksaRotationFeasibilityAudit.audit(
        repository: repository,
      );
      expect(
        audit.result,
        TaksaRotationFeasibilityResult.readyToImplementPartialRotation,
      );
      expect(audit.supportedWeekdayNumbers, [2, 3]);
      expect(audit.partialSourceReviewWeekdayNumbers, [1]);
      expect(audit.notInSourceWeekdayNumbers, [4, 5, 6, 7]);
      expect(audit.rotationAssignmentsByWeekday[2], 8);
      expect(audit.rotationAssignmentsByWeekday[3], 8);
      expect(audit.wednesdayDaytimeStatus, TaksaRotationBlocker.notInSource);
      expect(audit.wednesdayNightRahuStatus, TaksaRotationBlocker.notInSource);
    });
  });

  group('ThaiTaksaRotationResolver', () {
    test('Monday rotation returns 8 source-backed assignments', () {
      final birth = birthForWeekday(1972, 4, 3);
      expect(birth.thaiWeekdayNumber, 2);
      final result = ThaiTaksaRotationResolver.resolve(
        birthData: birth,
        repository: repository,
      );
      expect(result.metadata.hasAssignments, isTrue);
      expect(result.metadata.assignments.length, 8);
      expect(result.metadata.blocker, isNull);
      for (final a in result.metadata.assignments) {
        expect(a.sourceUnitId, startsWith('taksa.p38.monday.'));
        expect(a.sourcePage, '38');
        expect(a.source, 'source_forensics_patch');
      }
      expect(
        result.metadata.assignments
            .singleWhere((a) => a.planetCanonId == 'planet.sun')
            .taksaRoleCanonId,
        'taksaRole.kalakini',
      );
    });

    test('Tuesday rotation returns 8 source-backed assignments', () {
      final birth = ThaiMirrorPipeline.sampleQaBirthData();
      expect(birth.thaiWeekdayNumber, 3);
      final result = ThaiTaksaRotationResolver.resolve(
        birthData: birth,
        repository: repository,
      );
      expect(result.metadata.hasAssignments, isTrue);
      expect(result.metadata.assignments.length, 8);
      expect(result.metadata.blocker, isNull);
      for (final a in result.metadata.assignments) {
        expect(a.sourceUnitId, startsWith('mahabhut.p38.'));
        expect(a.sourcePage, '38');
        expect(a.source, 'canon_structural');
      }
    });

    test('Sunday returns TAKSA_ROTATION_PARTIAL_SOURCE_REVIEW_REQUIRED', () {
      final birth = birthForWeekday(1972, 4, 2);
      expect(birth.thaiWeekdayNumber, 1);
      final result = ThaiTaksaRotationResolver.resolve(
        birthData: birth,
        repository: repository,
      );
      expect(result.metadata.assignments, isEmpty);
      expect(
        result.metadata.blocker,
        TaksaRotationBlocker.partialSourceReviewRequired,
      );
    });

    test('Wednesday daytime returns TAKSA_ROTATION_NOT_IN_SOURCE', () {
      final birth = birthForWeekday(1972, 4, 5);
      expect(birth.thaiWeekdayNumber, 4);
      final result = ThaiTaksaRotationResolver.resolve(
        birthData: birth,
        repository: repository,
      );
      expect(result.metadata.assignments, isEmpty);
      expect(result.metadata.blocker, TaksaRotationBlocker.notInSource);
    });

    test('Thursday–Saturday return TAKSA_ROTATION_NOT_IN_SOURCE', () {
      final dates = [
        (1972, 4, 6), // Thu
        (1972, 4, 7), // Fri
        (1972, 4, 8), // Sat
      ];
      for (final (y, m, d) in dates) {
        final result = ThaiTaksaRotationResolver.resolve(
          birthData: birthForWeekday(y, m, d),
          repository: repository,
        );
        expect(result.metadata.assignments, isEmpty);
        expect(result.metadata.blocker, TaksaRotationBlocker.notInSource);
      }
    });

    test('Wednesday daytime and night cases are documented separately', () {
      final audit = ThaiTaksaRotationFeasibilityAudit.audit(
        repository: repository,
      );
      expect(
        ThaiTaksaNotInSourceWeekdayCase.wednesdayDaytime,
        isNot(equals(ThaiTaksaNotInSourceWeekdayCase.wednesdayNightRahu)),
      );
      expect(audit.wednesdayDaytimeStatus, TaksaRotationBlocker.notInSource);
      expect(audit.wednesdayNightRahuStatus, TaksaRotationBlocker.notInSource);
    });

    test('no role assignment inferred from planet alone', () {
      final result = ThaiTaksaRotationResolver.resolve(
        birthData: null,
        repository: repository,
      );
      expect(result.metadata.assignments, isEmpty);
      expect(result.metadata.blocker, TaksaRotationBlocker.missingBirthWeekday);
    });
  });

  group('ThaiReportCanonEvidenceEnricher Taksa rotation', () {
    Future<ThaiMirrorCanonEvidenceBundle> enrich(ThaiBirthData birth) async {
      final pipeline = ThaiMirrorPipeline.generate(birth);
      return ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
    }

    test('Monday fixture attaches rotation evidence internally', () async {
      final bundle = await enrich(birthForWeekday(1972, 4, 3));
      expect(bundle.trace.taksaRotationAssignmentCount, 8);
      expect(bundle.trace.taksaEvidenceAttachedCount, 8);
      expect(bundle.trace.taksaRotationBlocker, isNull);
      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.taksa,
        ).length,
        8,
      );
      for (final attachment in bundle.attachments) {
        if (attachment.evidenceType == ThaiCanonEvidenceType.taksa) {
          expect(attachment.userFacingAllowed, isFalse);
          expect(attachment.signalId, startsWith('taksaRotation:'));
        }
      }
    });

    test('Tuesday QA fixture attaches rotation evidence internally', () async {
      final bundle = await enrich(ThaiMirrorPipeline.sampleQaBirthData());
      expect(bundle.trace.taksaRotationAssignmentCount, 8);
      expect(bundle.trace.taksaEvidenceAttachedCount, 8);
      expect(bundle.trace.taksaRotationBlocker, isNull);
      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.taksa,
        ).length,
        8,
      );
    });

    test('unsupported weekdays keep Taksa evidence trace-only', () async {
      final sunday = await enrich(birthForWeekday(1972, 4, 2));
      expect(sunday.trace.taksaEvidenceAttachedCount, 0);
      expect(
        sunday.trace.taksaRotationBlocker,
        TaksaRotationBlocker.partialSourceReviewRequired,
      );

      final wednesday = await enrich(birthForWeekday(1972, 4, 5));
      expect(wednesday.trace.taksaEvidenceAttachedCount, 0);
      expect(
        wednesday.trace.taksaRotationBlocker,
        TaksaRotationBlocker.notInSource,
      );
      expect(
        wednesday.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.taksa,
        ),
        isEmpty,
      );
    });

    test('review trace lists supported weekdays Monday and Tuesday', () async {
      final bundle = await enrich(ThaiMirrorPipeline.sampleQaBirthData());
      expect(bundle.trace.taksaSupportedWeekdays, ['2', '3']);
      expect(bundle.trace.taksaPartialSourceReviewWeekdays, ['1']);
      expect(bundle.trace.taksaNotInSourceWeekdays, ['4', '5', '6', '7']);
      expect(
        bundle.trace.taksaWednesdayDaytimeStatus,
        TaksaRotationBlocker.notInSource,
      );
      expect(
        bundle.trace.taksaWednesdayNightRahuStatus,
        TaksaRotationBlocker.notInSource,
      );
    });

    test('remedies remain hidden', () async {
      final bundle = await enrich(ThaiMirrorPipeline.sampleQaBirthData());
      expect(bundle.trace.skippedRemedyEvidenceCount, 87);
      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.remedyInternal,
        ),
        isEmpty,
      );
    });
  });

  group('Public surface isolation', () {
    test('user-facing fingerprint unchanged after Taksa rotation enrichment', () async {
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

    test('public Thai beta page does not import Taksa rotation resolver', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiTaksaRotationResolver'), isFalse);
    });
  });
}
