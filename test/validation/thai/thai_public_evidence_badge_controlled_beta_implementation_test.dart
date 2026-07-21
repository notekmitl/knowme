import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_internal_evidence_badge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_mapper.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview_mapper.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_invited_tester_registry.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiMirrorCanonEvidenceBundle bundle;
  late ThaiBetaAnalysis analysis;

  const safeBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'coreSelf',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
  );

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    final pipeline = ThaiMirrorPipeline.generate(
      ThaiMirrorPipeline.sampleQaBirthData(),
    );
    bundle = await ThaiReportCanonEvidenceEnricher.enrich(
      pipeline,
      repository: repository,
    );
    analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Test',
        lastName: 'User',
        birthDate: DateTime(1972, 4, 4),
        birthHour: 10,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
    );
  });

  setUp(() {
    ThaiEvidenceBadgeFeatureFlag.resetToDefault();
    ThaiBetaInvitedTesterRegistry.reset();
  });

  group('ThaiEvidenceBadgeFeatureFlag', () {
    test('default is off', () {
      expect(ThaiEvidenceBadgeFeatureFlag.state, ThaiEvidenceBadgeFeatureFlagState.off);
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(),
        isFalse,
      );
    });

    test('invalid value behaves as off', () {
      expect(
        ThaiEvidenceBadgeFeatureFlag.parse('invalid'),
        ThaiEvidenceBadgeFeatureFlagState.off,
      );
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlag.parse('invalid'),
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isFalse,
      );
    });

    test('internal_only renders only for internal audience', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isTrue,
      );
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });

    test('invited_beta renders only for invited audience', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isTrue,
      );
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });
  });

  group('ThaiBetaReportPage controlled beta UI', () {
    Future<void> pumpReport(
      WidgetTester tester, {
      ThaiEvidenceBadgeFeatureFlagState? flag,
      ThaiBetaEvidenceBadgeAudience? audience,
      List<ThaiPublicEvidenceBadgeBetaViewModel>? badges,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: flag,
            audienceOverride: audience,
            badgeViewModelsOverride: badges,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('off renders no badge panel', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel), findsNothing);
    });

    testWidgets('internal_only with internal audience renders badge panel', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel), findsOneWidget);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.cautionCopy), findsOneWidget);
    });

    testWidgets('invited_beta with invited audience renders badge panel', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
    });

    testWidgets('rollback off hides badges after prior render', (tester) async {
      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly;
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.off,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.internalTester(),
            badgeViewModelsOverride: const [safeBadge],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('no page refs, unit ids, or forbidden wording in panel', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        badges: ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle),
      );
      final labelText = tester
          .widgetList<Chip>(
            find.descendant(
              of: find.byType(ThaiBetaEvidenceBadgePanel),
              matching: find.byType(Chip),
            ),
          )
          .map((chip) => chip.label is Text ? (chip.label as Text).data ?? '' : '')
          .join(' ');
      expect(RegExp(r'\bp\d+\b').hasMatch(labelText), isFalse);
      expect(RegExp(r'unit\.').hasMatch(labelText), isFalse);
      expect(RegExp(r'planet\.').hasMatch(labelText), isFalse);
      for (final forbidden in ThaiPublicEvidenceBadgeCopy.forbiddenWording) {
        expect(labelText.contains(forbidden), isFalse);
      }
      expect(find.text(ThaiPublicEvidenceBadgeCopy.cautionCopy), findsWidgets);
    });
  });

  group('Eligibility enforcement', () {
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
            reason: attachment.signalId,
          );
        }
      }
    }

    test('only CANON_SUPPORTED mahabhut/planet maps to beta badges', () {
      final betaBadges = ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle);
      expect(betaBadges, isNotEmpty);
      for (final badge in betaBadges) {
        expect(badge.badgeLabel, ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel);
        expect(badge.cautionCopy, ThaiPublicEvidenceBadgeCopy.cautionCopy);
      }
    });

    test('RUNTIME_METADATA_SUPPORTED does not render badge', () {
      expectNeverEligible(
        ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported,
      );
    });

    test('CANON_DERIVED_INTERNAL does not render badge', () {
      expectNeverEligible(ThaiInternalEvidenceBadgeCategory.canonDerivedInternal);
    });

    test('PARTIAL_CANON_SUPPORT does not render badge', () {
      expectNeverEligible(
        ThaiInternalEvidenceBadgeCategory.partialCanonSupport,
      );
    });

    test('OUT_OF_CANON_SCOPE does not render badge', () {
      expectNeverEligible(ThaiInternalEvidenceBadgeCategory.outOfCanonScope);
    });

    test('BLOCKED_AMBIGUOUS does not render badge', () {
      expectNeverEligible(ThaiInternalEvidenceBadgeCategory.blockedAmbiguous);
    });

    test('BLOCKED_SOURCE_CONFLICT does not render badge', () {
      expectNeverEligible(
        ThaiInternalEvidenceBadgeCategory.blockedSourceConflict,
      );
    });

    test('INTERNAL_ONLY does not render badge', () {
      expectNeverEligible(ThaiInternalEvidenceBadgeCategory.internalOnly);
    });

    test('REMEDY_HIDDEN does not render badge', () {
      final remedy = ThaiCanonEvidenceAttachment(
        sectionId: 'coreSelf',
        signalId: 'section:coreSelf:remedy:test',
        evidenceType: ThaiCanonEvidenceType.remedyInternal,
        evidenceRefs: const [],
      );
      expect(
        ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
          remedy,
          bundle: bundle,
        ),
        isFalse,
      );
    });

    test('NO_CANON_EVIDENCE does not render badge', () {
      expectNeverEligible(ThaiInternalEvidenceBadgeCategory.noCanonEvidence);
    });

    test('Taksa evidence does not render badge', () {
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

    test('Khumsap evidence does not render badge', () {
      for (final attachment in bundle.attachments) {
        if (attachment.signalId.contains('khumsap') ||
            attachment.signalId.contains('mahabhuta_khumsap')) {
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

    test('Rise/fall evidence does not render badge', () {
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

    test('Lookup table evidence does not render badge', () {
      final lookup = ThaiCanonEvidenceAttachment(
        sectionId: 'coreSelf',
        signalId: 'section:coreSelf:planet:planet.sun',
        evidenceType: ThaiCanonEvidenceType.planetSignification,
        evidenceRefs: [
          ThaiCanonEvidenceRef(
            unitId: 'lookup.test',
            relation: 'maps',
            subject: 'lookupTable.birthDateChart',
            object: 'chart.row',
            sourceBookId: 'mahabhut',
            sourcePage: 'p20',
            domain: 'lookupTables',
            safety: ThaiCanonEvidenceSafety.traceabilityInternal,
          ),
        ],
      );
      expect(
        ThaiPublicEvidenceBadgePreviewMapper.isEligibleCanonSupported(
          lookup,
          bundle: bundle,
        ),
        isFalse,
      );
    });
  });

  group('Public surface isolation', () {
    test('ThaiMirrorResultPage does not import beta badge UI', () {
      final source = File(
        'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
      expect(source.contains('ThaiPublicEvidenceBadgeBeta'), isFalse);
    });

    testWidgets('ThaiMirrorResultPage alone does not render beta badge panel', (
      tester,
    ) async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiMirrorResultPage(consumerState: view),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    final blockedPaths = <String>[
      'lib/features/home/presentation/pages/home_page.dart',
      'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
    ];

    for (final path in blockedPaths) {
      test('$path does not import beta badge UI', () {
        if (!File(path).existsSync()) return;
        final source = File(path).readAsStringSync();
        expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
      });
    }

    test('Daily Mirror does not import beta badge UI', () {
      final hits = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.contains('daily_mirror') && f.path.endsWith('.dart'))
          .map((f) => f.readAsStringSync())
          .where((s) => s.contains('ThaiBetaEvidenceBadgePanel'))
          .toList();
      expect(hits, isEmpty);
    });
  });

  group('Public output regression', () {
    test('fingerprint unchanged when flag is off', () async {
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
      expect(ThaiEvidenceBadgeFeatureFlag.state, ThaiEvidenceBadgeFeatureFlagState.off);
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
        expect(
          period.summary.contains(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel),
          isFalse,
        );
      }
    });

    test('remedies remain hidden', () {
      expect(bundle.trace.skippedRemedyEvidenceCount, 87);
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
        if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
          fail('remedy should not attach to report');
        }
      }
    });
  });
}
