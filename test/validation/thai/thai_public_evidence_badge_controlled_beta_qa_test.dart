import 'dart:convert';
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
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_runner.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_validator.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_beta_telemetry.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

/// Public Evidence Badge Controlled Beta QA — formal audit before flag enablement.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiPublicEvidenceBadgeControlledBetaQaAudit audit;
  late ThaiMirrorCanonEvidenceBundle bundle;
  late ThaiBetaAnalysis analysis;

  const safeBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'coreSelf',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
  );

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiPublicEvidenceBadgeControlledBetaQaRunner.run(
      repository: repository,
    );
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
    ThaiEvidenceBadgeBetaTelemetry.onEvent = null;
  });

  group('ThaiPublicEvidenceBadgeControlledBetaQaRunner', () {
    test('audits all 9 deterministic fixtures', () {
      expect(audit.fixtureResults.length, 9);
      final ids = audit.fixtureResults.map((r) => r.fixtureId).toList();
      expect(ids, contains('qa_sample'));
      for (final letter in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        expect(ids, contains('harness_$letter'));
      }
    });

    test('runner is deterministic across two runs', () async {
      final first = await ThaiPublicEvidenceBadgeControlledBetaQaRunner.run(
        repository: repository,
      );
      final second = await ThaiPublicEvidenceBadgeControlledBetaQaRunner.run(
        repository: repository,
      );
      expect(
        ThaiPublicEvidenceBadgeControlledBetaQaReport.toMap(first),
        ThaiPublicEvidenceBadgeControlledBetaQaReport.toMap(second),
      );
    });

    test('writes aggregate QA summary artifact', () {
      final map = ThaiPublicEvidenceBadgeControlledBetaQaReport.toMap(audit);
      final outDir = Directory('tool/output');
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      File('tool/output/thai_public_evidence_badge_controlled_beta_qa_summary.json')
          .writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(map)}\n',
      );
      expect(
        File('tool/output/thai_public_evidence_badge_controlled_beta_qa_summary.json')
            .existsSync(),
        isTrue,
      );
      expect(map['phase'], 'Public Evidence Badge Controlled Beta QA');
      expect(map['defaultFlagState'], 'off');
      expect(map['telemetryProductionEnabled'], isFalse);
    });

    test('overall controlled beta QA audit passes', () {
      expect(audit.overallPassed, isTrue);
      expect(audit.flagQaPassed, isTrue);
      expect(audit.audienceGatingPassed, isTrue);
      expect(audit.defaultFlagOff, isTrue);
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

  group('Feature flag QA', () {
    test('missing flag behaves as off', () {
      expect(
        ThaiEvidenceBadgeFeatureFlag.parse(null),
        ThaiEvidenceBadgeFeatureFlagState.off,
      );
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlag.parse(null),
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isFalse,
      );
    });

    test('invalid flag behaves as off', () {
      expect(
        ThaiEvidenceBadgeFeatureFlag.parse('not_a_flag'),
        ThaiEvidenceBadgeFeatureFlagState.off,
      );
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlag.parse('not_a_flag'),
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isFalse,
      );
    });

    test('default state remains off', () {
      ThaiEvidenceBadgeFeatureFlag.resetToDefault();
      expect(ThaiEvidenceBadgeFeatureFlag.state, ThaiEvidenceBadgeFeatureFlagState.off);
      expect(ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(), isFalse);
    });

    test('off renders no badges anywhere in gate matrix', () {
      for (final audience in const [
        ThaiBetaEvidenceBadgeAudience.anonymous(),
        ThaiBetaEvidenceBadgeAudience.internalTester(),
        ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
      ]) {
        expect(
          ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
            flag: ThaiEvidenceBadgeFeatureFlagState.off,
            audience: audience,
          ),
          isFalse,
        );
      }
    });

    test('flag can be turned off and gate closes', () {
      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly;
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isTrue,
      );
      ThaiEvidenceBadgeFeatureFlag.resetToDefault();
      expect(ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(), isFalse);
    });
  });

  group('Audience gating QA', () {
    test('internal_only renders only for internal tester audience', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isTrue,
      );
    });

    test('invited_beta renders only for invited beta audience', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isTrue,
      );
    });

    test('normal user sees no badge for internal_only', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });

    test('normal user sees no badge for invited_beta', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });

    test('invited_beta does not render for internal-only audience', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isFalse,
      );
    });
  });

  group('Surface isolation QA', () {
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

    testWidgets('badge renders on Thai Beta Research Result when allowed', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
        audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
    });

    testWidgets('ThaiMirrorResultPage does not render beta badge panel', (
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

    test('Daily Mirror widget tree does not import beta badge UI', () {
      final source = File(
        'lib/features/mirror_experience/ui/daily_mirror_section.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
      expect(source.contains('ThaiPublicEvidenceBadgeBeta'), isFalse);
    });

    final blockedPaths = <String>[
      'lib/presentation/pages/home/home_page.dart',
      'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
    ];

    for (final path in blockedPaths) {
      test('$path does not import beta badge UI', () {
        final source = File(path).readAsStringSync();
        expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
        expect(source.contains('ThaiPublicEvidenceBadgeBeta'), isFalse);
      });
    }

    test('Daily Mirror sources do not import beta badge UI', () {
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

  group('Badge eligibility QA', () {
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
      expect(audit.totalEligibleBetaBadges, greaterThan(0));
      final betaBadges = ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle);
      expect(betaBadges, isNotEmpty);
      for (final badge in betaBadges) {
        expect(badge.badgeLabel, ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel);
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

  group('Copy safety QA', () {
    testWidgets('required caution copy appears on beta panel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.internalTester(),
            badgeViewModelsOverride: const [safeBadge],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel), findsOneWidget);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.cautionCopy), findsOneWidget);
    });

    testWidgets('forbidden certainty wording absent from badge labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.internalTester(),
            badgeViewModelsOverride: ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final labelText = tester
          .widgetList<Chip>(
            find.descendant(
              of: find.byType(ThaiBetaEvidenceBadgePanel),
              matching: find.byType(Chip),
            ),
          )
          .map((chip) => chip.label is Text ? (chip.label as Text).data ?? '' : '')
          .join(' ');
      for (final forbidden in ThaiPublicEvidenceBadgeCopy.forbiddenWording) {
        expect(labelText.contains(forbidden), isFalse);
      }
    });
  });

  group('Data leakage QA', () {
    testWidgets('no page reference, source prose, unit id, or confidence %', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.internalTester(),
            badgeViewModelsOverride: ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final panelText = tester
          .widget<ThaiBetaEvidenceBadgePanel>(find.byType(ThaiBetaEvidenceBadgePanel))
          .toString();
      final chips = tester
          .widgetList<Chip>(
            find.descendant(
              of: find.byType(ThaiBetaEvidenceBadgePanel),
              matching: find.byType(Chip),
            ),
          )
          .map((chip) => chip.label is Text ? (chip.label as Text).data ?? '' : '')
          .join(' ');
      expect(RegExp(r'\bp\d+\b').hasMatch(chips), isFalse);
      expect(RegExp(r'unit\.').hasMatch(chips), isFalse);
      expect(RegExp(r'planet\.').hasMatch(chips), isFalse);
      expect(chips.contains('%'), isFalse);
      expect(panelText.contains('ดวงขึ้น'), isFalse);
      expect(panelText.contains('ดวงตก'), isFalse);
    });
  });

  group('Telemetry safety QA', () {
    test('telemetry hooks are local/stub only — no production analytics', () {
      expect(ThaiEvidenceBadgeBetaTelemetry.onEvent, isNull);
    });

    test('telemetry events use allowed names and safe props only', () {
      final captured = <Map<String, Object?>>[];
      ThaiEvidenceBadgeBetaTelemetry.onEvent = (name, {props}) {
        captured.add({'name': name, 'props': props});
      };

      ThaiEvidenceBadgeBetaTelemetry.badgeRendered(sectionId: 'coreSelf');
      ThaiEvidenceBadgeBetaTelemetry.badgeSeen(sectionId: 'coreSelf');
      ThaiEvidenceBadgeBetaTelemetry.feedbackStarted();

      expect(
        ThaiPublicEvidenceBadgeControlledBetaQaValidator.auditTelemetrySafety(
          captured,
        ),
        isTrue,
      );
      expect(captured.map((e) => e['name']).toSet(),
          ThaiPublicEvidenceBadgeControlledBetaQaValidator.allowedTelemetryEvents);
    });
  });

  group('Rollback QA', () {
    testWidgets('off hides badge after prior render', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.internalTester(),
            badgeViewModelsOverride: const [safeBadge],
          ),
        ),
      );
      await tester.pumpAndSettle();
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
  });

  group('Public output regression QA', () {
    test('public Thai fingerprint unchanged when flag is off', () async {
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

    test('remedies remain hidden/internal', () {
      expect(bundle.trace.skippedRemedyEvidenceCount, 87);
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
        if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
          fail('remedy should not attach to report');
        }
      }
    });

    testWidgets('ThaiBetaReportPage without flag unchanged (no badge panel)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.off,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
      expect(find.byType(ThaiMirrorResultPage), findsOneWidget);
    });
  });
}
