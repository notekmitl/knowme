import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
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

class _FakeResearchAdminAccess implements ThaiResearchAdminAccess {
  _FakeResearchAdminAccess(this.value);
  final ThaiResearchAccess value;
  @override
  Stream<ThaiResearchAccess> watch() => Stream.value(value);
}

/// Internal-only activation guard tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiBetaAnalysis analysis;

  const safeBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'coreSelf',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
  );

  setUpAll(() {
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

  group('Activation configuration', () {
    test('checked-in activation is internal_only not invited_beta', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'internal_only');
      expect(ThaiEvidenceBadgeActivation.configuredState, isNot('invited_beta'));
    });

    test('applyConfiguredState activates internal_only', () {
      ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
      expect(
        ThaiEvidenceBadgeFeatureFlag.state,
        ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      );
      expect(
        ThaiEvidenceBadgeFeatureFlag.configuredState,
        ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      );
    });

    test('resetToDefault remains off fallback for tests', () {
      ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
      ThaiEvidenceBadgeFeatureFlag.resetToDefault();
      expect(ThaiEvidenceBadgeFeatureFlag.state, ThaiEvidenceBadgeFeatureFlagState.off);
    });

    test('invalid flag still behaves as off', () {
      expect(
        ThaiEvidenceBadgeFeatureFlag.parse('bogus'),
        ThaiEvidenceBadgeFeatureFlagState.off,
      );
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlag.parse('bogus'),
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isFalse,
      );
    });

    test('off still disables badges completely', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.off,
          audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        ),
        isFalse,
      );
    });

    test('invited_beta gate remains inactive in internal-only phase', () {
      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly;
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isFalse,
      );
      expect(ThaiEvidenceBadgeFeatureFlag.state, isNot(ThaiEvidenceBadgeFeatureFlagState.invitedBeta));
    });
  });

  group('Audience resolver', () {
    test('admin maps to internal tester', () {
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.fromResearchAccess(
        ThaiResearchAccess.admin,
      );
      expect(audience.isInternalTester, isTrue);
      expect(audience.isInvitedBetaTester, isFalse);
    });

    test('signed out maps to anonymous', () {
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.fromResearchAccess(
        ThaiResearchAccess.signedOut,
      );
      expect(audience.isInternalTester, isFalse);
    });

    test('non-admin maps to anonymous', () {
      final audience = ThaiBetaEvidenceBadgeAudienceResolver.fromResearchAccess(
        ThaiResearchAccess.notAdmin,
      );
      expect(audience.isInternalTester, isFalse);
    });
  });

  group('ThaiBetaReportPage internal_only activation', () {
    Future<void> pumpReport(
      WidgetTester tester, {
      ThaiBetaEvidenceBadgeAudience? audience,
      ThaiResearchAdminAccess? access,
      List<ThaiPublicEvidenceBadgeBetaViewModel>? badges,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
            audienceOverride: audience,
            researchAdminAccess: access,
            badgeViewModelsOverride: badges,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('internal_only renders badge for internal tester', (tester) async {
      await pumpReport(
        tester,
        audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel), findsOneWidget);
      expect(find.text(ThaiPublicEvidenceBadgeCopy.cautionCopy), findsOneWidget);
    });

    testWidgets('internal_only does not render badge for normal user', (tester) async {
      await pumpReport(
        tester,
        access: _FakeResearchAdminAccess(ThaiResearchAccess.notAdmin),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('internal_only does not render badge for anonymous user', (tester) async {
      await pumpReport(
        tester,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('admin access via stream renders badge panel', (tester) async {
      await pumpReport(
        tester,
        access: _FakeResearchAdminAccess(ThaiResearchAccess.admin),
        badges: const [safeBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
    });

    testWidgets('no forbidden content in badge labels', (tester) async {
      await pumpReport(
        tester,
        audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
        badges: const [safeBadge],
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
      for (final forbidden in ThaiPublicEvidenceBadgeCopy.forbiddenWording) {
        expect(labelText.contains(forbidden), isFalse);
      }
    });
  });

  group('Surface isolation under internal_only', () {
    testWidgets('ThaiMirrorResultPage does not render beta badge panel', (
      tester,
    ) async {
      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.internalOnly;
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

    test('Home does not import beta badge UI', () {
      final source = File('lib/presentation/pages/home/home_page.dart')
          .readAsStringSync();
      expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
    });

    test('Daily Mirror does not import beta badge UI', () {
      final source = File(
        'lib/features/mirror_experience/ui/daily_mirror_section.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiBetaEvidenceBadgePanel'), isFalse);
    });
  });

  group('Public isolation regression', () {
    test('fingerprint unchanged for non-internal audience', () async {
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
          flag: ThaiEvidenceBadgeFeatureFlagState.internalOnly,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });

    test('remedies remain hidden/internal', () async {
      final repository = await ThaiCanonEvidenceRepository.loadFromAsset();
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      for (final attachment in bundle.attachments) {
        expect(attachment.userFacingAllowed, isFalse);
      }
    });
  });
}
