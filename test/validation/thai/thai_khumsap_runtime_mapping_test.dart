import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_signal_scope.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classifier.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Khumsap Runtime Mapping — internal metadata only.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('ThaiKhumsapRuntimeMetadataFeasibilityAudit', () {
    test('feasibility is READY_TO_ADD_INTERNAL_KHUMSAP_KEY', () {
      final audit = ThaiKhumsapRuntimeMetadataFeasibilityAudit.audit();
      expect(
        audit.result,
        KhumsapRuntimeMappingFeasibilityResult.readyToAddInternalKhumsapKey,
      );
      expect(audit.runtimeExposesKhumsapKey, isFalse);
      expect(audit.thaiContentKeysHasExactKhumsapKey, isFalse);
      expect(audit.mahabhutaThayaMeansKhumsapByEvidence, isFalse);
      expect(audit.mahabhutaThayaRemainsOutOfCanonScope, isTrue);
    });
  });

  group('ThaiCanonKhumsapRuntimeMapping', () {
    test('mahabhutPosition.khumsap maps to internal mahabhuta_khumsap key', () {
      expect(
        ThaiCanonKhumsapRuntimeMapping.runtimeKeyForCanonId(
          'mahabhutPosition.khumsap',
        ),
        ThaiMahabhutKhumsapRuntimeKey.khumsap,
      );
      expect(
        ThaiCanonKhumsapRuntimeMapping.canonIdForRuntimeKey(
          ThaiMahabhutKhumsapRuntimeKey.khumsap,
        ),
        'mahabhutPosition.khumsap',
      );
    });

    test('mahabhuta_thaya does NOT map to khumsap', () {
      expect(
        ThaiCanonKhumsapRuntimeMapping.canonIdForRuntimeKey(
          ThaiContentKeys.mahabhutaThaya,
        ),
        isNull,
      );
      expect(
        ThaiCanonOntologyRuntimeMapping.canonMahabhutForContentKey(
          ThaiContentKeys.mahabhutaThaya,
        ),
        isNull,
      );
    });

    test('mapping is exact not fuzzy', () {
      expect(
        ThaiCanonKhumsapRuntimeMapping.canonIdForRuntimeKey('mahabhuta_khum'),
        isNull,
      );
      expect(
        ThaiCanonKhumsapRuntimeMapping.canonIdForRuntimeKey('ขุมทรัพย์'),
        isNull,
      );
    });
  });

  group('ThaiCanonEvidenceSignalScope', () {
    test('mahabhuta_thaya remains OUT_OF_CANON_SCOPE', () {
      expect(
        ThaiCanonEvidenceSignalScope.isOutOfCanonScope(
          ThaiContentKeys.mahabhutaThaya,
        ),
        isTrue,
      );
      expect(
        ThaiCanonEvidenceSignalScope.isInCanonScopeMahabhutKey(
          ThaiContentKeys.mahabhutaThaya,
        ),
        isFalse,
      );
    });

    test('internal mahabhuta_khumsap is in Canon scope', () {
      expect(
        ThaiCanonEvidenceSignalScope.isOutOfCanonScope(
          ThaiMahabhutKhumsapRuntimeKey.khumsap,
        ),
        isFalse,
      );
      expect(
        ThaiCanonEvidenceSignalScope.isInCanonScopeMahabhutKey(
          ThaiMahabhutKhumsapRuntimeKey.khumsap,
        ),
        isTrue,
      );
    });
  });

  group('ThaiCanonEvidenceMapper', () {
    test('evidence query by mahabhutPosition.khumsap works', () {
      final refs = repository.mapper.evidenceForMahabhutPosition(
        'mahabhutPosition.khumsap',
      );
      expect(refs, isNotEmpty);
      for (final ref in refs) {
        expect(
          ref.subject == 'mahabhutPosition.khumsap' ||
              ref.object == 'mahabhutPosition.khumsap',
          isTrue,
        );
      }
    });

    test('evidence query by internal khumsap runtime key works', () {
      final refs = repository.mapper.evidenceForRuntimeContentKey(
        ThaiMahabhutKhumsapRuntimeKey.khumsap,
      );
      expect(refs, isNotEmpty);
    });
  });

  group('ThaiCanonOntologyRuntimeMapping khumsap', () {
    test('all 7 mahabhut positions are mapped', () {
      final maps = repository.mahabhutPositionMappings;
      expect(maps.length, 7);
      expect(maps.every((m) => m.isMapped), isTrue);
    });

    test('khumsap is not an unmapped Canon entity', () {
      expect(
        repository.unmappedCanonEntityIds,
        isNot(contains('mahabhutPosition.khumsap')),
      );
      expect(
        repository.unmappedCanonEntityIds,
        isNot(contains('mahabhutPosition.thongchai')),
      );
    });
  });

  group('ThaiReportCanonEvidenceEnricher Khumsap trace', () {
    Future<ThaiMirrorCanonEvidenceBundle> enrich() async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      return ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
    }

    test('khumsap mapped internally with candidate count', () async {
      final bundle = await enrich();
      expect(bundle.trace.khumsapMapped, isTrue);
      expect(bundle.trace.khumsapCanonUnitsAvailable, greaterThan(0));
      expect(bundle.trace.khumsapEvidenceCandidateCount, greaterThan(0));
      expect(bundle.trace.mahabhutaThayaOutOfCanonScope, isTrue);
      expect(
        bundle.trace.unmappedCanonEvidenceCandidates,
        isNot(contains('mahabhutPosition.khumsap')),
      );
    });

    test('khumsap evidence remains userFacingAllowed false', () async {
      final bundle = await enrich();
      for (final attachment in bundle.attachments) {
        final isKhumsap = attachment.evidenceRefs.any(
          (r) =>
              r.subject == 'mahabhutPosition.khumsap' ||
              r.object == 'mahabhutPosition.khumsap',
        );
        if (isKhumsap) {
          expect(attachment.userFacingAllowed, isFalse);
        }
      }
    });

    test('remedies remain hidden', () async {
      final bundle = await enrich();
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
    test('user-facing fingerprint unchanged after Khumsap mapping enrichment',
        () async {
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

    test('public Thai beta page does not import Khumsap mapping', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiCanonKhumsapRuntimeMapping'), isFalse);
      expect(source.contains('mahabhuta_khumsap'), isFalse);
    });

    test('consumer mirror copy does not mention Khumsap labels', () {
      final paths = [
        'lib/features/astrology/thai/mirror/presentation/copy/thai_mirror_consumer_copy.dart',
        'lib/features/astrology/thai/mirror/presentation/copy/thai_mirror_report_copy.dart',
      ];
      for (final path in paths) {
        final source = File(path).readAsStringSync();
        expect(source.contains('ขุมทรัพย์'), isFalse);
        expect(source.contains('mahabhuta_khumsap'), isFalse);
      }
    });
  });
}
