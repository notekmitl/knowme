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
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_invited_beta_activation_qa_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_invited_beta_activation_qa_runner.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_invited_beta_activation_qa_validator.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_invited_tester_registry.dart';
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

/// Formal QA for activated invited-beta evidence badge phase.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiPublicEvidenceBadgeInvitedBetaActivationQaAudit audit;
  late ThaiBetaAnalysis analysis;
  late ThaiMirrorCanonEvidenceBundle bundle;

  const invitedUid = 'invited-beta-qa-uid-001';
  const adminUid = 'admin-not-on-invite-list';

  const safeBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'coreSelf',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
  );

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    audit = await ThaiPublicEvidenceBadgeInvitedBetaActivationQaRunner.run(
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
    ThaiBetaInvitedTesterRegistry.invite(invitedUid);
  });

  group('ThaiPublicEvidenceBadgeInvitedBetaActivationQaRunner', () {
    test('audits all 9 deterministic fixtures', () {
      expect(audit.fixtureResults.length, 9);
    });

    test('runner is deterministic across two runs', () async {
      final first = await ThaiPublicEvidenceBadgeInvitedBetaActivationQaRunner.run(
        repository: repository,
      );
      final second = await ThaiPublicEvidenceBadgeInvitedBetaActivationQaRunner.run(
        repository: repository,
      );
      expect(
        ThaiPublicEvidenceBadgeInvitedBetaActivationQaReport.toMap(first),
        ThaiPublicEvidenceBadgeInvitedBetaActivationQaReport.toMap(second),
      );
    });

    test('writes aggregate QA summary artifact', () {
      final map = ThaiPublicEvidenceBadgeInvitedBetaActivationQaReport.toMap(audit);
      final outDir = Directory('tool/output');
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      File('tool/output/thai_public_evidence_badge_invited_beta_activation_qa_summary.json')
          .writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(map)}\n',
      );
      expect(map['phase'], 'Public Evidence Badge Invited Beta Activation QA');
      expect(map['activeFlagState'], 'invited_beta');
      expect(map['overallPassed'], isTrue);
    });

    test('overall activation QA audit passes', () {
      expect(audit.overallPassed, isTrue);
      expect(audit.activationStatePassed, isTrue);
      expect(audit.audienceIsolationPassed, isTrue);
      expect(audit.registryPassed, isTrue);
      expect(audit.rollbackPassed, isTrue);
      expect(audit.internalOnlyPreserved, isTrue);
      expect(audit.invalidFlagOff, isTrue);
      expect(audit.totalEligibilityViolations, 0);
      expect(audit.totalCopySafetyViolations, 0);
      expect(audit.totalDataLeakageViolations, 0);
      expect(audit.publicFingerprintUnchanged, isTrue);
      expect(audit.remediesHidden, isTrue);
    });
  });

  group('Invited beta visibility QA', () {
    Future<void> pumpReport(
      WidgetTester tester, {
      ThaiEvidenceBadgeFeatureFlagState flag =
          ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      ThaiBetaEvidenceBadgeAudience? audience,
      ThaiBetaEvidenceBadgeAudienceAccess? access,
      List<ThaiPublicEvidenceBadgeBetaViewModel>? badges,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: flag,
            audienceOverride: audience,
            audienceAccess: access,
            badgeViewModelsOverride: badges ?? const [safeBadge],
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('1 invited beta tester sees badge on ThaiBetaReportPage', (
      tester,
    ) async {
      await pumpReport(
        tester,
        access: _FakeAudienceAccess(
          researchAccess: ThaiResearchAccess.notAdmin,
          userId: invitedUid,
        ),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel), findsOneWidget);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.cautionCopy), findsOneWidget);
    });

    testWidgets('2 anonymous does not see badge', (tester) async {
      await pumpReport(
        tester,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('3 normal signed-in user not on list does not see badge', (
      tester,
    ) async {
      await pumpReport(
        tester,
        access: _FakeAudienceAccess(
          researchAccess: ThaiResearchAccess.notAdmin,
          userId: 'normal-user-not-on-list',
        ),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('4 admin not on invite list does not see badge', (tester) async {
      await pumpReport(
        tester,
        access: _FakeAudienceAccess(
          researchAccess: ThaiResearchAccess.admin,
          userId: adminUid,
        ),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    test('validator audience isolation passes', () {
      expect(
        ThaiPublicEvidenceBadgeInvitedBetaActivationQaValidator.auditAudienceIsolation(),
        isTrue,
      );
    });
  });

  group('Allow-list / registry QA', () {
    test('5 invite(uid) enables badge visibility', () {
      ThaiBetaInvitedTesterRegistry.reset();
      ThaiBetaInvitedTesterRegistry.invite(invitedUid);
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
        researchAccess: ThaiResearchAccess.notAdmin,
        userId: invitedUid,
      );
      expect(audience.isInvitedBetaTester, isTrue);
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: audience,
        ),
        isTrue,
      );
    });

    test('6 revoke(uid) disables badge visibility', () {
      ThaiBetaInvitedTesterRegistry.revoke(invitedUid);
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
        researchAccess: ThaiResearchAccess.notAdmin,
        userId: invitedUid,
      );
      expect(audience.isInvitedBetaTester, isFalse);
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: audience,
        ),
        isFalse,
      );
    });

    test('7 reset() disables badge visibility', () {
      ThaiBetaInvitedTesterRegistry.reset();
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
        researchAccess: ThaiResearchAccess.notAdmin,
        userId: invitedUid,
      );
      expect(audience.isInvitedBetaTester, isFalse);
    });

    test('registry uses uid only — no email matching', () {
      final source = File(
        'lib/features/thai_beta/application/thai_beta_invited_tester_registry.dart',
      ).readAsStringSync();
      expect(source.contains('email'), isFalse);
      expect(source.contains('isInvited'), isTrue);
    });

    test('anonymous null uid blocked', () {
      expect(ThaiBetaInvitedTesterRegistry.isInvited(null), isFalse);
    });

    test('validator registry behavior passes', () {
      expect(
        ThaiPublicEvidenceBadgeInvitedBetaActivationQaValidator.auditRegistryBehavior(),
        isTrue,
      );
    });
  });

  group('Flag and rollback QA', () {
    test('8 off hides badge for invited beta tester', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.off,
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isFalse,
      );
    });

    test('9 internal_only still renders for admin only', () {
      expect(
        ThaiPublicEvidenceBadgeInvitedBetaActivationQaValidator.auditInternalOnlyPreserved(),
        isTrue,
      );
    });

    test('10 invalid flag behaves as off', () {
      expect(
        ThaiPublicEvidenceBadgeInvitedBetaActivationQaValidator.auditInvalidFlagOff(),
        isTrue,
      );
    });

    test('activation state is invited_beta', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
      expect(
        ThaiPublicEvidenceBadgeInvitedBetaActivationQaValidator.auditActivationState(),
        isTrue,
      );
    });

    test('validator rollback behavior passes', () {
      expect(
        ThaiPublicEvidenceBadgeInvitedBetaActivationQaValidator.auditRollbackBehavior(),
        isTrue,
      );
    });

    testWidgets('rollback off hides badge for all audiences', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
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
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
            badgeViewModelsOverride: const [safeBadge],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });
  });

  group('Surface isolation QA', () {
    testWidgets('11 ThaiMirrorResultPage does not render badge', (tester) async {
      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.invitedBeta;
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
      'lib/features/mirror_experience/ui/daily_mirror_section.dart',
      'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      'lib/features/astrology/thai/mirror/presentation/thai_mirror_routes.dart',
      'lib/features/thai_beta/presentation/thai_beta_routes.dart',
    ];

    for (final path in blockedPaths) {
      test('${path.contains('home') ? '12' : path.contains('daily') ? '13' : ''} $path does not import beta badge panel', () {
        final source = File(path).readAsStringSync();
        expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
      });
    }
  });

  group('Badge content and leakage QA', () {
    testWidgets('14-20 allowed copy only; no forbidden content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
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

  group('Public output regression QA', () {
    test('21 public Thai fingerprint unchanged', () async {
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
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });

    test('22 consumer Mirror copy unchanged', () {
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

    test('23 remedies remain hidden/internal', () {
      expect(bundle.trace.skippedRemedyEvidenceCount, 87);
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
      }
    });
  });
}
