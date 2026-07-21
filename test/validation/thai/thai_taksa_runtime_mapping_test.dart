import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classifier.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_data.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Taksa Runtime Mapping — internal metadata only.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('ThaiTaksaRoleRuntimeKey', () {
    test('all 8 taksaRole Canon ids map to internal runtime keys', () {
      for (final entity in CanonOntologyData.taksaRoles) {
        expect(
          ThaiCanonTaksaRoleRuntimeMapping.runtimeKeyForCanonId(entity.id),
          entity.id,
        );
        expect(ThaiTaksaRoleRuntimeKey.isAllowed(entity.id), isTrue);
      }
      expect(ThaiTaksaRoleRuntimeKey.allowedIds.length, 8);
    });

    test('Thai role labels map exactly to canonical ids', () {
      for (final entity in CanonOntologyData.taksaRoles) {
        for (final alias in entity.aliases) {
          expect(
            ThaiCanonTaksaRoleRuntimeMapping.canonIdForExactThaiLabel(alias),
            entity.id,
          );
        }
      }
    });

    test('no fuzzy role mapping is allowed', () {
      expect(
        ThaiCanonTaksaRoleRuntimeMapping.canonIdForExactThaiLabel('บริวาร์'),
        isNull,
      );
      expect(
        ThaiCanonTaksaRoleRuntimeMapping.canonIdForExactThaiLabel('กาลกิณี'),
        isNull,
      );
      expect(
        ThaiCanonTaksaRoleRuntimeMapping.canonIdForExactThaiLabel('ทักษา'),
        isNull,
      );
    });
  });

  group('ThaiCanonOntologyRuntimeMapping taksa', () {
    test('all Taksa roles are mapped in ontology runtime table', () {
      final maps = ThaiCanonOntologyRuntimeMapping.taksaRoleMappings();
      expect(maps.length, 8);
      expect(maps.every((m) => m.isMapped), isTrue);
      expect(
        maps.every((m) => m.kind == ThaiCanonRuntimeKeyKind.taksaRole),
        isTrue,
      );
    });

    test('taksaRole entities are no longer unmapped Canon entities', () {
      final unmapped = repository.unmappedCanonEntityIds;
      for (final entity in CanonOntologyData.taksaRoles) {
        expect(unmapped, isNot(contains(entity.id)));
      }
    });
  });

  group('ThaiReportCanonEvidenceEnricher Taksa trace', () {
    Future<ThaiMirrorCanonEvidenceBundle> enrich() async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      return ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
    }

    test('Tuesday QA fixture attaches rotation evidence; remainder trace-only', () async {
      final bundle = await enrich();
      final trace = bundle.trace;

      expect(trace.taksaRolesMapped.length, 8);
      expect(trace.taksaRotationAssignmentCount, 8);
      expect(trace.taksaEvidenceAttachedCount, 8);
      expect(trace.taksaRotationBlocker, isNull);
      expect(
        trace.taksaRotationFeasibilityResult,
        'READY_TO_IMPLEMENT_PARTIAL_ROTATION',
      );
      expect(
        bundle.attachments.where(
          (a) => a.evidenceType == ThaiCanonEvidenceType.taksa,
        ).length,
        8,
      );
      expect(trace.taksaEvidenceTraceOnlyCount, greaterThan(0));
    });

    test('taksaRole ids are not unmapped Canon candidates', () async {
      final bundle = await enrich();
      expect(
        bundle.trace.unmappedCanonEvidenceCandidates.any(
          (id) => id.startsWith('taksaRole.'),
        ),
        isFalse,
      );
    });

    test('Taksa evidence is not attached to unrelated report sections', () async {
      final bundle = await enrich();
      final mirrorSectionIds =
          bundle.pipelineResult.mirrorResult!.sections.map((s) => s.id.name);
      for (final attachment in bundle.attachments) {
        if (attachment.evidenceType == ThaiCanonEvidenceType.taksa) {
          expect(mirrorSectionIds, isNot(contains(attachment.sectionId)));
        }
      }
    });

    test('Taksa evidence userFacingAllowed stays false', () async {
      final bundle = await enrich();
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
      }
      final records = ThaiCanonEvidenceAlignmentClassifier.classifyFixture(
        fixtureId: 'taksa_qa',
        bundle: bundle,
      );
      final taksaRecord = records.where(
        (r) =>
            r.classification ==
            ThaiCanonEvidenceAlignmentClassification.skippedTaksa,
      );
      expect(taksaRecord, isNotEmpty);
      expect(
        taksaRecord.first.reason,
        contains(TaksaRuntimeSkippedReason.noRuntimeTaksaSignal),
      );
    });

    test('remedies remain hidden/internal', () async {
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

  group('Feasibility audit', () {
    test('audit classifies READY_TO_ADD_INTERNAL_TAKSA_ROLE_KEYS', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final audit = ThaiTaksaRoleRuntimeMetadataFeasibilityAudit.audit(
        pipeline: pipeline,
      );
      expect(
        audit.result,
        TaksaRuntimeMappingFeasibilityResult.readyToAddInternalTaksaRoleKeys,
      );
      expect(audit.runtimeExposesTaksaRoleKey, isFalse);
      expect(audit.runtimeExposesBirthWeekday, isTrue);
      expect(audit.runtimeExposesPlanetRoleAssignment, isFalse);
      expect(audit.reportCopyMentionsTaksaRoles, isFalse);
      expect(audit.canonHasRoleIdentityData, isTrue);
    });
  });

  group('Public surface isolation', () {
    test('user-facing fingerprint unchanged after Taksa mapping enrichment', () async {
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

    test('public Thai beta page does not import Taksa mapping', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiCanonTaksaRoleRuntimeMapping'), isFalse);
      expect(source.contains('ThaiTaksaRoleRuntimeKey'), isFalse);
    });

    test('consumer mirror copy does not mention Taksa role labels', () {
      final copyDir = Directory(
        'lib/features/astrology/thai/mirror/presentation/copy',
      );
      for (final file in copyDir.listSync().whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final text = file.readAsStringSync();
        for (final label in ThaiTaksaRoleRuntimeKey.primaryThaiLabels.values) {
          expect(text.contains(label), isFalse, reason: file.path);
        }
      }
    });
  });
}
