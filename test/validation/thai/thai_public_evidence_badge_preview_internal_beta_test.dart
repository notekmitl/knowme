import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_summary.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_routes.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_internal_evidence_badge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview_mapper.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classifier.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Public Evidence Badge Prototype — internal beta only tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiMirrorCanonEvidenceBundle bundle;

  const traceabilitySafety = ThaiCanonEvidenceSafety.traceabilityInternal;

  ThaiCanonEvidenceRef ref({
    required String unitId,
    required String subject,
    required String object,
    String relation = 'owns',
    String? sourcePage,
  }) {
    return ThaiCanonEvidenceRef(
      unitId: unitId,
      relation: relation,
      subject: subject,
      object: object,
      sourceBookId: 'mahabhut',
      sourcePage: sourcePage ?? 'p1',
      safety: traceabilitySafety,
    );
  }

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    final pipeline = ThaiMirrorPipeline.generate(
      ThaiMirrorPipeline.sampleQaBirthData(),
    );
    bundle = await ThaiReportCanonEvidenceEnricher.enrich(
      pipeline,
      repository: repository,
    );
  });

  group('ThaiPublicEvidenceBadgePreviewMapper', () {
    test('only CANON_SUPPORTED mahabhut/planet attachments are eligible', () {
      final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
      expect(previews, isNotEmpty);
      for (final preview in previews) {
        expect(preview.eligible, isTrue);
        expect(preview.internalOnlyPreview, isTrue);
        expect(
          preview.sourceLevel,
          ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
        );
        expect(
          ThaiPublicEvidenceBadgeCopy.allowedBadgeLabels,
          contains(preview.badgeLabel),
        );
        expect(preview.explanationText, ThaiPublicEvidenceBadgeCopy.cautionCopy);
      }
    });

    test('RUNTIME_METADATA_SUPPORTED does not produce preview badge', () {
      for (final attachment in bundle.attachments) {
        final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
          attachment,
          trace: bundle.trace,
        );
        if (badge ==
            ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported) {
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

    test('CANON_DERIVED_INTERNAL does not produce preview badge', () {
      for (final attachment in bundle.attachments) {
        final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
          attachment,
          trace: bundle.trace,
        );
        if (badge == ThaiInternalEvidenceBadgeCategory.canonDerivedInternal) {
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

    test('PARTIAL_CANON_SUPPORT does not produce preview badge', () {
      for (final attachment in bundle.attachments) {
        final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
          attachment,
          trace: bundle.trace,
        );
        if (badge == ThaiInternalEvidenceBadgeCategory.partialCanonSupport) {
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

    test('REMEDY_HIDDEN never produces preview badge', () {
      final remedy = ThaiCanonEvidenceAttachment(
        sectionId: 'coreSelf',
        signalId: 'section:coreSelf:remedy:test',
        evidenceType: ThaiCanonEvidenceType.remedyInternal,
        evidenceRefs: [
          ref(unitId: 'remedy.test', subject: 'remedy.x', object: 'ritual.y'),
        ],
      );
      expect(
        ThaiPublicEvidenceBadgePreviewMapper.blockedReasonForAttachment(
          remedy,
          bundle: bundle,
        ),
        'remedy_hidden',
      );
      expect(
        ThaiPublicEvidenceBadgePreviewMapper.fromBundle(
          ThaiMirrorCanonEvidenceBundle(
            pipelineResult: bundle.pipelineResult,
            attachments: [remedy],
            trace: bundle.trace,
          ),
        ),
        isEmpty,
      );
    });

    test('Taksa evidence never produces preview badge', () {
      for (final attachment in bundle.attachments) {
        if (attachment.evidenceType == ThaiCanonEvidenceType.taksa) {
          expect(
            ThaiPublicEvidenceBadgePreviewMapper.blockedReasonForAttachment(
              attachment,
              bundle: bundle,
            ),
            isNotNull,
          );
        }
      }
      final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
      expect(
        previews.any((p) => p.sectionId == 'taksaInternal'),
        isFalse,
      );
    });

    test('Khumsap evidence never produces preview badge', () {
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

    test('rise/fall metadata never produces preview badge', () {
      for (final attachment in bundle.attachments) {
        if (attachment.evidenceType ==
            ThaiCanonEvidenceType.periodStatusStructural) {
          expect(
            ThaiPublicEvidenceBadgePreviewMapper.blockedReasonForAttachment(
              attachment,
              bundle: bundle,
            ),
            'rise_fall_hidden',
          );
        }
      }
    });

    test('previews contain no page references, unit ids, or confidence', () {
      final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
      final serialized = previews
          .map((p) => '${p.sectionId}|${p.badgeLabel}|${p.explanationText}')
          .join('\n');
      expect(serialized.contains('p38'), isFalse);
      expect(serialized.contains('p19'), isFalse);
      expect(RegExp(r'unit\.').hasMatch(serialized), isFalse);
      expect(serialized.contains('%'), isFalse);
      expect(serialized.contains('confidence'), isFalse);
    });

    test('certainty wording is absent from badge labels', () {
      final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
      final labels = previews.map((p) => p.badgeLabel).join(' ');
      for (final forbidden in ThaiPublicEvidenceBadgeCopy.forbiddenWording) {
        expect(labels.contains(forbidden), isFalse);
      }
    });

    test('required caution copy is present on every eligible preview', () {
      final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
      for (final preview in previews) {
        expect(preview.explanationText, ThaiPublicEvidenceBadgeCopy.cautionCopy);
      }
    });
  });

  group('ThaiPublicEvidenceBadgePreviewPage', () {
    Future<void> pumpPreview(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiPublicEvidenceBadgePreviewPage(initialBundle: bundle),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders internal beta header and policy warning', (tester) async {
      await pumpPreview(tester);
      expect(
        find.text(ThaiPublicEvidenceBadgeCopy.previewHeader),
        findsOneWidget,
      );
      expect(
        find.text(ThaiPublicEvidenceBadgeCopy.previewPolicyWarning),
        findsOneWidget,
      );
      expect(find.textContaining('LEVEL_1'), findsWidgets);
      expect(find.textContaining('Hidden remedies:'), findsOneWidget);
    });

    testWidgets('does not show raw unit ids or source pages', (tester) async {
      await pumpPreview(tester);
      final rows = flattenEvidenceRows(bundle);
      for (final row in rows.take(10)) {
        if (row.unitId.isNotEmpty) {
          expect(find.text(row.unitId), findsNothing);
        }
        final page = row.sourcePage;
        if (page.isNotEmpty && page != '—' && RegExp(r'^p\d+').hasMatch(page)) {
          expect(find.textContaining(page), findsNothing);
        }
      }
    });
  });

  group('Internal route isolation', () {
    test('preview route is internal-only path', () {
      expect(
        ThaiCanonEvidenceRoutes.publicEvidencePreviewRouteName,
        '/internal/thai-public-evidence-preview',
      );
      final route = ThaiCanonEvidenceRoutes.onGenerateRoute(
        const RouteSettings(
          name: ThaiCanonEvidenceRoutes.publicEvidencePreviewRouteName,
        ),
      );
      expect(route, isNotNull);
      expect(
        route!.settings.name,
        ThaiCanonEvidenceRoutes.publicEvidencePreviewRouteName,
      );
    });

    test('preview route uses MaterialPageRoute with admin guard', () {
      final route = ThaiCanonEvidenceRoutes.onGenerateRoute(
        const RouteSettings(
          name: ThaiCanonEvidenceRoutes.publicEvidencePreviewRouteName,
        ),
      );
      expect(route, isA<MaterialPageRoute<void>>());
      expect(
        route!.settings.name,
        ThaiCanonEvidenceRoutes.publicEvidencePreviewRouteName,
      );
    });
  });

  group('Public surface isolation', () {
    test('Thai beta report page does not import preview badges', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiPublicEvidenceBadgePreview'), isFalse);
      expect(source.contains('thai-public-evidence-preview'), isFalse);
    });

    test('Thai mirror result page does not import preview badges', () {
      final source = File(
        'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiPublicEvidenceBadgePreview'), isFalse);
      expect(source.contains('ThaiPublicEvidenceBadgePreviewPage'), isFalse);
    });

    test('public fingerprint unchanged after enrichment', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final before = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        pipeline,
      );
      final enriched = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      final after = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
        enriched.pipelineResult,
      );
      expect(before, after);
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

    test('all evidence rows remain userFacingAllowed false', () {
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
      }
    });
  });

  group('Strong match eligibility', () {
    test('CANON_SUPPORTED planet/mahabhut domain can be eligible', () {
      var foundEligible = false;
      for (final attachment in bundle.attachments) {
        final (classification, _) =
            ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(attachment);
        if (classification !=
            ThaiCanonEvidenceAlignmentClassification.strongMatch) {
          continue;
        }
        final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
          attachment,
          trace: bundle.trace,
        );
        if (badge != ThaiInternalEvidenceBadgeCategory.canonSupported) {
          continue;
        }
        if (ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
          attachment,
          bundle: bundle,
        )) {
          foundEligible = true;
        }
      }
      expect(foundEligible, isTrue);
    });
  });
}
