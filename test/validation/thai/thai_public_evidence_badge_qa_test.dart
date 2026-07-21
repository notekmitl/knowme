import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_routes.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_internal_evidence_badge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview_mapper.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_qa_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_qa_runner.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_qa_validator.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Public Evidence Badge QA — formal audit across 9 deterministic fixtures.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiPublicEvidenceBadgeQaAudit audit;

  const traceabilitySafety = ThaiCanonEvidenceSafety.traceabilityInternal;

  ThaiCanonEvidenceRef lookupRef() {
    return ThaiCanonEvidenceRef(
      unitId: 'lookup.test',
      relation: 'maps',
      subject: 'lookupTable.birthDateChart',
      object: 'chart.row',
      sourceBookId: 'mahabhut',
      sourcePage: 'p20',
      domain: 'lookupTables',
      safety: traceabilitySafety,
    );
  }

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiPublicEvidenceBadgeQaRunner.run(repository: repository);
  });

  group('ThaiPublicEvidenceBadgeQaRunner', () {
    test('audits all 9 deterministic fixtures', () {
      expect(audit.fixtureResults.length, 9);
      final ids = audit.fixtureResults.map((r) => r.fixtureId).toList();
      expect(ids, contains('qa_sample'));
      for (final letter in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        expect(ids, contains('harness_$letter'));
      }
    });

    test('runner is deterministic across two runs', () async {
      final first = await ThaiPublicEvidenceBadgeQaRunner.run(
        repository: repository,
      );
      final second = await ThaiPublicEvidenceBadgeQaRunner.run(
        repository: repository,
      );
      expect(
        ThaiPublicEvidenceBadgeQaReport.toMap(first),
        ThaiPublicEvidenceBadgeQaReport.toMap(second),
      );
    });

    test('writes aggregate QA summary artifact', () {
      final map = ThaiPublicEvidenceBadgeQaReport.toMap(audit);
      final outDir = Directory('tool/output');
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      File('tool/output/thai_public_evidence_badge_qa_summary.json')
          .writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(map)}\n',
      );
      expect(
        File('tool/output/thai_public_evidence_badge_qa_summary.json')
            .existsSync(),
        isTrue,
      );
      expect(map['phase'], 'Public Evidence Badge QA');
      expect(map['policyLevel'], 'LEVEL_1_PUBLIC_SUMMARY_BADGE');
    });

    test('overall QA audit passes', () {
      expect(audit.overallPassed, isTrue);
      expect(audit.totalEligibilityViolations, 0);
      expect(audit.totalCopySafetyViolations, 0);
      expect(audit.totalDataLeakageViolations, 0);
      expect(audit.publicFingerprintUnchanged, isTrue);
      expect(audit.remediesHidden, isTrue);
      for (final result in audit.fixtureResults) {
        expect(result.passed, isTrue, reason: result.fixtureId);
      }
    });
  });

  group('Eligibility QA', () {
    late ThaiMirrorCanonEvidenceBundle bundle;

    setUpAll(() async {
      final fixture = ThaiCanonEvidenceAlignmentFixtures.qaSample;
      final pipeline = ThaiMirrorPipeline.generate(fixture.birthData);
      bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
    });

    test('only eligible categories produce Level 1 preview badges', () {
      expect(audit.totalEligiblePreviews, greaterThan(0));
      for (final result in audit.fixtureResults) {
        expect(result.eligibilityViolations, isEmpty);
      }
    });

    void expectNeverEligible(ThaiInternalEvidenceBadgeCategory category) {
      for (final attachment in bundle.attachments) {
        final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
          attachment,
          trace: bundle.trace,
        );
        if (badge == category) {
          expect(
            ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
              attachment,
              bundle: bundle,
            ),
            isFalse,
            reason: '${attachment.signalId} ($category)',
          );
        }
      }
    }

    test('RUNTIME_METADATA_SUPPORTED does not produce preview badge', () {
      expectNeverEligible(
        ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported,
      );
    });

    test('CANON_DERIVED_INTERNAL does not produce preview badge', () {
      expectNeverEligible(
        ThaiInternalEvidenceBadgeCategory.canonDerivedInternal,
      );
    });

    test('PARTIAL_CANON_SUPPORT does not produce preview badge', () {
      expectNeverEligible(
        ThaiInternalEvidenceBadgeCategory.partialCanonSupport,
      );
    });

    test('OUT_OF_CANON_SCOPE does not produce preview badge', () {
      expectNeverEligible(ThaiInternalEvidenceBadgeCategory.outOfCanonScope);
    });

    test('BLOCKED_AMBIGUOUS does not produce preview badge', () {
      expectNeverEligible(ThaiInternalEvidenceBadgeCategory.blockedAmbiguous);
    });

    test('BLOCKED_SOURCE_CONFLICT does not produce preview badge', () {
      expectNeverEligible(
        ThaiInternalEvidenceBadgeCategory.blockedSourceConflict,
      );
    });

    test('REMEDY_HIDDEN does not produce preview badge', () {
      final remedy = ThaiCanonEvidenceAttachment(
        sectionId: 'coreSelf',
        signalId: 'section:coreSelf:remedy:test',
        evidenceType: ThaiCanonEvidenceType.remedyInternal,
        evidenceRefs: [lookupRef()],
      );
      expect(
        ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
          remedy,
          bundle: bundle,
        ),
        isFalse,
      );
    });

    test('Taksa evidence does not produce preview badge', () {
      for (final attachment in bundle.attachments) {
        if (attachment.evidenceType == ThaiCanonEvidenceType.taksa) {
          expect(
            ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
              attachment,
              bundle: bundle,
            ),
            isFalse,
          );
        }
      }
    });

    test('Khumsap evidence does not produce preview badge', () {
      for (final attachment in bundle.attachments) {
        if (attachment.signalId.contains('mahabhuta_khumsap') ||
            attachment.signalId.contains('khumsap')) {
          expect(
            ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
              attachment,
              bundle: bundle,
            ),
            isFalse,
          );
        }
      }
    });

    test('Rise/Fall evidence does not produce preview badge', () {
      for (final attachment in bundle.attachments) {
        if (attachment.evidenceType ==
            ThaiCanonEvidenceType.periodStatusStructural) {
          expect(
            ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
              attachment,
              bundle: bundle,
            ),
            isFalse,
          );
        }
      }
    });

    test('Lookup table evidence does not produce preview badge', () {
      final lookupAttachment = ThaiCanonEvidenceAttachment(
        sectionId: 'coreSelf',
        signalId: 'section:coreSelf:planet:planet.sun',
        evidenceType: ThaiCanonEvidenceType.planetSignification,
        evidenceRefs: [lookupRef()],
      );
      expect(
        ThaiPublicEvidenceBadgePreviewMapper.blockedReasonForAttachment(
          lookupAttachment,
          bundle: bundle,
        ),
        'lookup_table_hidden',
      );
      expect(
        ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
          lookupAttachment,
          bundle: bundle,
        ),
        isFalse,
      );
      expect(bundle.trace.skippedLookupTableEvidenceCount, greaterThan(0));
    });
  });

  group('Copy safety QA', () {
    test('required caution copy on every preview badge', () {
      for (final result in audit.fixtureResults) {
        expect(result.copySafetyViolations, isEmpty);
      }
    });

    test('forbidden certainty wording is absent from badge labels', () {
      for (final result in audit.fixtureResults) {
        expect(result.copySafetyViolations, isEmpty);
      }
      expect(
        ThaiPublicEvidenceBadgeCopy.cautionCopy.contains('การันตี'),
        isTrue,
        reason: 'negated guarantee in approved caution copy',
      );
    });
  });

  group('Data leakage QA', () {
    test('no page refs, prose, unit ids, or confidence in preview output', () {
      expect(audit.totalDataLeakageViolations, 0);
      for (final result in audit.fixtureResults) {
        expect(result.dataLeakageViolations, isEmpty);
      }
    });
  });

  group('Internal route isolation', () {
    test('preview route is internal and admin guarded', () {
      expect(
        ThaiCanonEvidenceRoutes.publicEvidencePreviewRouteName,
        startsWith('/internal/'),
      );
      final route = ThaiCanonEvidenceRoutes.onGenerateRoute(
        const RouteSettings(
          name: ThaiCanonEvidenceRoutes.publicEvidencePreviewRouteName,
        ),
      );
      expect(route, isA<MaterialPageRoute<void>>());
    });

    final publicPages = <String>[
      'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      'lib/features/home/presentation/pages/home_page.dart',
    ];

    for (final path in publicPages) {
      test('$path does not import preview badge UI', () {
        if (!File(path).existsSync()) return;
        final source = File(path).readAsStringSync();
        expect(source.contains('ThaiPublicEvidenceBadgePreview'), isFalse);
        expect(source.contains('thai-public-evidence-preview'), isFalse);
      });
    }

    test('Daily Mirror does not import preview badge UI', () {
      final hits = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.contains('daily_mirror') && f.path.endsWith('.dart'))
          .map((f) => f.readAsStringSync())
          .where(
            (s) =>
                s.contains('ThaiPublicEvidenceBadgePreview') ||
                s.contains('thai-public-evidence-preview'),
          )
          .toList();
      expect(hits, isEmpty);
    });
  });

  group('Public output regression', () {
    test('public fingerprint unchanged across fixtures', () {
      expect(audit.publicFingerprintUnchanged, isTrue);
    });

    test('consumer mirror copy unchanged', () {
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
        expect(period.summary.contains('มีแหล่งอ้างอิงใน Canon'), isFalse);
      }
    });

    test('remedies remain hidden/internal', () {
      expect(audit.remediesHidden, isTrue);
      for (final result in audit.fixtureResults) {
        expect(result.hiddenSummary.hiddenRemedies, 87);
      }
    });
  });

  group('Reviewer usability', () {
    late ThaiMirrorCanonEvidenceBundle bundle;

    setUpAll(() async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
    });

    testWidgets('preview page shows beta header, warning, and badges', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiPublicEvidenceBadgePreviewPage(initialBundle: bundle),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(ThaiPublicEvidenceBadgeCopy.previewHeader),
        findsOneWidget,
      );
      expect(
        find.text(ThaiPublicEvidenceBadgeCopy.previewPolicyWarning),
        findsOneWidget,
      );
      expect(find.textContaining('Not a public release'), findsOneWidget);
      expect(find.textContaining('Hidden remedies:'), findsOneWidget);
      expect(find.textContaining('LEVEL_1'), findsWidgets);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.cautionCopy), findsWidgets);
      expect(find.textContaining('Released to users'), findsNothing);
    });
  });
}
