import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classifier.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Taksa Rotation Model — Tuesday-only source-backed rotation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('ThaiTaksaRotationFeasibilityAudit', () {
    test('feasibility audit is READY_TO_IMPLEMENT_TUESDAY_ONLY', () {
      final audit = ThaiTaksaRotationFeasibilityAudit.audit(
        repository: repository,
      );
      expect(
        audit.result,
        TaksaRotationFeasibilityResult.readyToImplementTuesdayOnly,
      );
      expect(audit.supportedWeekdayNumbers, [3]);
      expect(audit.ocrBlockedWeekdayNumbers, [1, 2]);
      expect(audit.unsupportedWeekdayNumbers, [4, 5, 6, 7]);
      expect(audit.rotationAssignmentsByWeekday[3], 8);
      expect(audit.sourcePagesReviewed, contains('38'));
    });
  });

  group('ThaiTaksaRotationResolver', () {
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
        expect(a.confidence, 'deterministic');
      }
      expect(
        result.metadata.assignments.map((a) => a.planetCanonId).toSet(),
        {
          'planet.mars',
          'planet.mercury',
          'planet.saturn',
          'planet.jupiter',
          'planet.rahu',
          'planet.venus',
          'planet.sun',
          'planet.moon',
        },
      );
    });

    test('unsupported Wednesday returns null with TAKSA_ROTATION_UNSUPPORTED_WEEKDAY', () {
      final birth = ThaiBirthData(
        localDateTime: DateTime(1972, 4, 5, 12, 0),
        timeZoneOffset: Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
      );
      expect(birth.thaiWeekdayNumber, 4);
      final result = ThaiTaksaRotationResolver.resolve(
        birthData: birth,
        repository: repository,
      );
      expect(result.metadata.assignments, isEmpty);
      expect(
        result.metadata.blocker,
        TaksaRotationBlocker.unsupportedWeekday,
      );
    });

    test('Sunday returns TAKSA_ROTATION_SOURCE_BLOCKED not inferred roles', () {
      final birth = ThaiBirthData(
        localDateTime: DateTime(1972, 4, 2, 12, 0),
        timeZoneOffset: Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
      );
      expect(birth.thaiWeekdayNumber, 1);
      final result = ThaiTaksaRotationResolver.resolve(
        birthData: birth,
        repository: repository,
      );
      expect(result.metadata.assignments, isEmpty);
      expect(result.metadata.blocker, TaksaRotationBlocker.sourceBlocked);
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
      for (final attachment in bundle.attachments) {
        if (attachment.evidenceType == ThaiCanonEvidenceType.taksa) {
          expect(attachment.userFacingAllowed, isFalse);
          expect(attachment.signalId, startsWith('taksaRotation:'));
          expect(attachment.evidenceRefs.single.sourcePage, '38');
        }
      }
    });

    test('Wednesday fixture keeps Taksa evidence trace-only', () async {
      final birth = ThaiBirthData(
        localDateTime: DateTime(1972, 4, 5, 12, 0),
        timeZoneOffset: Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
      );
      final bundle = await enrich(birth);
      expect(bundle.trace.taksaRotationAssignmentCount, 0);
      expect(bundle.trace.taksaEvidenceAttachedCount, 0);
      expect(
        bundle.trace.taksaSkippedReason,
        TaksaRuntimeSkippedReason.rotationUnsupportedWeekday,
      );
      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.taksa,
        ),
        isEmpty,
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
