import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_mapper.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_internal_only_activation_qa_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_internal_only_activation_qa_runner.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_internal_only_activation_qa_validator.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/application/thai_research_admin_access.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

class _FakeAudienceAccess implements ThaiBetaEvidenceBadgeAudienceAccess {
  _FakeAudienceAccess({required this.researchAccess, this.userId});
  final ThaiResearchAccess researchAccess;
  final String? userId;
  @override
  Stream<ThaiBetaEvidenceBadgeAudienceSnapshot> watch() => Stream.value(
        ThaiBetaEvidenceBadgeAudienceSnapshot(
          researchAccess: researchAccess,
          userId: userId,
        ),
      );
}

/// Formal QA for activated internal-only evidence badge phase.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiPublicEvidenceBadgeInternalOnlyActivationQaAudit audit;
  late ThaiBetaAnalysis analysis;
  late ThaiMirrorCanonEvidenceBundle bundle;

  const safeBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'coreSelf',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
  );

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiPublicEvidenceBadgeInternalOnlyActivationQaRunner.run(
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
  });

  group('ThaiPublicEvidenceBadgeInternalOnlyActivationQaRunner', () {
    test('audits all 9 deterministic fixtures', () {
      expect(audit.fixtureResults.length, 9);
    });

    test('runner is deterministic across two runs', () async {
      final first = await ThaiPublicEvidenceBadgeInternalOnlyActivationQaRunner.run(
        repository: repository,
      );
      final second = await ThaiPublicEvidenceBadgeInternalOnlyActivationQaRunner.run(
        repository: repository,
      );
      expect(
        ThaiPublicEvidenceBadgeInternalOnlyActivationQaReport.toMap(first),
        ThaiPublicEvidenceBadgeInternalOnlyActivationQaReport.toMap(second),
      );
    });

    test('writes aggregate QA summary artifact', () {
      final map = ThaiPublicEvidenceBadgeInternalOnlyActivationQaReport.toMap(audit);
      final outDir = Directory('tool/output');
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      File('tool/output/thai_public_evidence_badge_internal_only_activation_qa_summary.json')
          .writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(map)}\n',
      );
      expect(map['phase'], 'Public Evidence Badge Internal Only Activation QA');
      expect(map['activeFlagState'], 'internal_only');
      expect(map['overallPassed'], isTrue);
    });

    test('overall activation QA audit passes', () {
      expect(audit.overallPassed, isTrue);
      expect(audit.activationStatePassed, isTrue);
      expect(audit.audienceIsolationPassed, isTrue);
      expect(audit.invitedBetaInactive, isTrue);
      expect(audit.rollbackPassed, isTrue);
      expect(audit.totalEligibilityViolations, 0);
      expect(audit.totalCopySafetyViolations, 0);
      expect(audit.totalDataLeakageViolations, 0);
      expect(audit.publicFingerprintUnchanged, isTrue);
      expect(audit.remediesHidden, isTrue);
    });
  });

  group('Activation state QA', () {
    test('frozen internal_only gate mechanics pass', () {
      expect(
        ThaiPublicEvidenceBadgeInternalOnlyActivationQaValidator.auditActivationState(),
        isTrue,
      );
    });

    test('invited audience blocked under internal_only flag', () {
      expect(
        ThaiPublicEvidenceBadgeInternalOnlyActivationQaValidator.auditInvitedBetaInactive(),
        isTrue,
      );
    });
  });

  group('Audience isolation QA', () {
    test('admin/internal tester may see badge when flag is internal_only', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isTrue,
      );
    });

    test('anonymous user blocked', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });

    test('normal signed-in user blocked', () {
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.fromResearchAccess(
        ThaiResearchAccess.notAdmin,
      );
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: audience,
        ),
        isFalse,
      );
    });

    test('invited-beta-only user blocked', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isFalse,
      );
    });

    test('validator audience isolation passes', () {
      ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
      expect(
        ThaiPublicEvidenceBadgeInternalOnlyActivationQaValidator.auditAudienceIsolation(),
        isTrue,
      );
    });
  });

  group('Surface isolation QA', () {
    Future<void> pumpReport(
      WidgetTester tester, {
      ThaiBetaEvidenceBadgeAudience? audience,
      ThaiBetaEvidenceBadgeAudienceAccess? access,
      ThaiEvidenceBadgeFeatureFlagState flag =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      List<ThaiPublicEvidenceBadgeBetaViewModel>? badges,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: flag,
            audienceOverride: audience,
            audienceAccess: access,
            badgeViewModelsOverride: badges,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('admin sees badge only on ThaiBetaReportPage', (tester) async {
      await pumpReport(
        tester,
        access: _FakeAudienceAccess(researchAccess: ThaiResearchAccess.admin),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
      expect(find.byType(ThaiMirrorResultPage), findsOneWidget);
    });

    testWidgets('normal user sees no badge on ThaiBetaReportPage', (tester) async {
      await pumpReport(
        tester,
        access: _FakeAudienceAccess(researchAccess: ThaiResearchAccess.notAdmin),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('anonymous user sees no badge on ThaiBetaReportPage', (tester) async {
      await pumpReport(
        tester,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('ThaiMirrorResultPage does not render badge', (tester) async {
      ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );
      await tester.pumpWidget(
        MaterialApp(home: ThaiMirrorResultPage(consumerState: view)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    final blockedPaths = <String>[
      'lib/presentation/pages/home/home_page.dart',
      'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      'lib/features/mirror_experience/ui/daily_mirror_section.dart',
      'lib/features/astrology/thai/mirror/presentation/thai_mirror_routes.dart',
      'lib/features/thai_beta/presentation/thai_beta_routes.dart',
    ];

    for (final path in blockedPaths) {
      test('$path does not import beta badge panel into public routes', () {
        final source = File(path).readAsStringSync();
        expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
      });
    }
  });

  group('Data leakage QA', () {
    testWidgets('no source page, prose, unit id, remedy, Taksa, Khumsap, rise-fall', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.internalTester(),
            badgeViewModelsOverride:
                ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final chips = tester
          .widgetList<Chip>(
            find.descendant(
              of: find.byType(ThaiBetaEvidenceBadgePanel),
              matching: find.byType(Chip),
            ),
          )
          .map((chip) => chip.label is Text ? (chip.label as Text).data ?? '' : '')
          .join(' ');
      final caution = find.text(ThaiPublicEvidenceBadgeCopy.cautionCopy);
      expect(caution, findsWidgets);
      expect(RegExp(r'\bp\d+\b').hasMatch(chips), isFalse);
      expect(RegExp(r'unit\.|planet\.').hasMatch(chips), isFalse);
      expect(chips.contains('%'), isFalse);
      expect(chips.contains('ดวงขึ้น'), isFalse);
      expect(chips.contains('ดวงตก'), isFalse);
      for (final forbidden in ThaiPublicEvidenceBadgeCopy.forbiddenWording) {
        expect(chips.contains(forbidden), isFalse);
      }
    });
  });

  group('Rollback QA', () {
    test('flag off hides badge for internal tester', () {
      expect(
        ThaiPublicEvidenceBadgeInternalOnlyActivationQaValidator.auditRollbackBehavior(),
        isTrue,
      );
    });

    testWidgets('rollback off hides badge panel on ThaiBetaReportPage', (
      tester,
    ) async {
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
    test('public Thai fingerprint unchanged', () async {
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

    test('consumer mirror copy unchanged for non-internal path', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );
      for (final period in view.lifeTimeline!.periods) {
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
      }
    });
  });
}
