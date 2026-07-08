import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_mapper.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
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
  _FakeAudienceAccess({
    required this.researchAccess,
    this.userId,
  });

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

/// Invited beta implementation guard tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiBetaAnalysis analysis;
  late ThaiMirrorCanonEvidenceBundle bundle;

  const safeBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'coreSelf',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
  );

  const invitedUid = 'invited-beta-uid-001';
  const adminUid = 'admin-uid-001';

  setUpAll(() async {
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
    final repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    final pipeline = ThaiMirrorPipeline.generate(
      ThaiMirrorPipeline.sampleQaBirthData(),
    );
    bundle = await ThaiReportCanonEvidenceEnricher.enrich(
      pipeline,
      repository: repository,
    );
  });

  setUp(() {
    ThaiEvidenceBadgeFeatureFlag.resetToDefault();
    ThaiBetaInvitedTesterRegistry.reset();
    ThaiBetaInvitedTesterRegistry.invite(invitedUid);
  });

  Future<void> pumpReport(
    WidgetTester tester, {
    required ThaiEvidenceBadgeFeatureFlagState flag,
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

  group('Activation configuration', () {
    test('checked-in activation is invited_beta', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
    });

    test('applyConfiguredState activates invited_beta', () {
      ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
      expect(
        ThaiEvidenceBadgeFeatureFlag.state,
        ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      );
    });

    test('invalid flag behaves as off', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlag.parse('bogus'),
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isFalse,
      );
    });

    test('internal_only still renders for admin only', () {
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
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isFalse,
      );
    });
  });

  group('Invited beta audience', () {
    test('invited uid on allow-list resolves to invited beta tester', () {
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
        researchAccess: ThaiResearchAccess.notAdmin,
        userId: invitedUid,
      );
      expect(audience.isInvitedBetaTester, isTrue);
      expect(audience.isInternalTester, isFalse);
    });

    test('admin not on invite list is not invited beta tester', () {
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
        researchAccess: ThaiResearchAccess.admin,
        userId: adminUid,
      );
      expect(audience.isInternalTester, isTrue);
      expect(audience.isInvitedBetaTester, isFalse);
    });

    test('revoked uid is blocked', () {
      ThaiBetaInvitedTesterRegistry.revoke(invitedUid);
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.resolve(
        researchAccess: ThaiResearchAccess.notAdmin,
        userId: invitedUid,
      );
      expect(audience.isInvitedBetaTester, isFalse);
    });
  });

  group('ThaiBetaReportPage invited_beta', () {
    testWidgets('1 invited beta tester sees badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
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
        flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('3 normal signed-in user not on list does not see badge', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
        access: _FakeAudienceAccess(
          researchAccess: ThaiResearchAccess.notAdmin,
          userId: 'normal-user-uid',
        ),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('4 admin not on invite list does not see badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
        access: _FakeAudienceAccess(
          researchAccess: ThaiResearchAccess.admin,
          userId: adminUid,
        ),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('8 off hides badge for invited beta tester', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        access: _FakeAudienceAccess(
          researchAccess: ThaiResearchAccess.notAdmin,
          userId: invitedUid,
        ),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });
  });

  group('Surface isolation', () {
    testWidgets('5 ThaiMirrorResultPage has no badge', (tester) async {
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

    test('6 Home has no badge import', () {
      final source = File('lib/presentation/pages/home/home_page.dart')
          .readAsStringSync();
      expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
    });

    test('7 Daily Mirror has no badge import', () {
      final source = File(
        'lib/features/mirror_experience/ui/daily_mirror_section.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
    });
  });

  group('Copy and leakage safety', () {
    testWidgets('11-18 allowed copy only; no forbidden content', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        badges: ThaiPublicEvidenceBadgeBetaMapper.fromBundle(bundle),
      );
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
      expect(RegExp(r'unit\.|planet\.').hasMatch(chips), isFalse);
      expect(chips.contains('%'), isFalse);
      expect(chips.contains('ดวงขึ้น'), isFalse);
      expect(chips.contains('ดวงตก'), isFalse);
      for (final forbidden in ThaiPublicEvidenceBadgeCopy.forbiddenWording) {
        expect(chips.contains(forbidden), isFalse);
      }
    });
  });

  group('Public regression', () {
    test('19 public fingerprint unchanged for normal users', () async {
      final repository = await ThaiCanonEvidenceRepository.loadFromAsset();
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

    test('20 consumer Mirror copy unchanged', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );
      expect(
        view.lifeTimeline!.periods.first.summary
            .contains(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel),
        isFalse,
      );
    });

    test('21 remedies remain hidden/internal', () {
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
      }
    });
  });
}
