import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_preview.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_current_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_routes.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_report_export_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  final analysis = ThaiBetaAnalysisRunner.run(
    ThaiBetaInput(
      firstName: 'Public',
      lastName: 'Beta',
      birthDate: DateTime(1972, 4, 4),
      birthHour: 10,
      birthMinute: 30,
      province: 'กรุงเทพมหานคร',
      provinceKey: 'bangkok',
    ),
  );

  const eligibleBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'profile',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
    sourceLevel: ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
    eligible: true,
  );
  const ineligibleBadge = ThaiPublicEvidenceBadgeBetaViewModel(
    sectionId: 'internal',
    badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
    cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
    sourceLevel: ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
    eligible: false,
  );

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  tearDown(() {
    ThaiBetaCurrentAnalysis.clear();
    ThaiEvidenceBadgeFeatureFlag.resetToDefault();
  });

  Future<void> pumpReport(
    WidgetTester tester, {
    required ThaiEvidenceBadgeFeatureFlagState flag,
    ThaiBetaEvidenceBadgeAudience? audience,
    List<ThaiPublicEvidenceBadgeBetaViewModel>? badges = const [eligibleBadge],
    ThaiBetaEvidenceBadgeAudienceAccess? access,
    bool screenshotMode = false,
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: analysis,
          featureFlagOverride: flag,
          audienceOverride: audience,
          audienceAccess: access,
          repository: repository,
          badgeViewModelsOverride: badges,
          screenshotModeOverride: screenshotMode,
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }
  }

  group('Public Thai Beta evidence policy', () {
    test('public_beta parses as an explicit rollout state', () {
      expect(
        ThaiEvidenceBadgeFeatureFlag.parse('public_beta'),
        ThaiEvidenceBadgeFeatureFlagState.publicBeta,
      );
      expect(
        ThaiEvidenceBadgeFeatureFlag.parse('unknown'),
        ThaiEvidenceBadgeFeatureFlagState.off,
      );
    });

    testWidgets('anonymous + LEVEL 1 evidence shows badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
      expect(find.text('ที่มาของคำวิเคราะห์'), findsOneWidget);
      expect(find.text('profile'), findsNothing);
    });

    testWidgets('repeated public badge copy renders once', (tester) async {
      const secondEligibleBadge = ThaiPublicEvidenceBadgeBetaViewModel(
        sectionId: 'timeline',
        badgeLabel: ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel,
        cautionCopy: ThaiPublicEvidenceBadgeCopy.cautionCopy,
        sourceLevel: ThaiPublicEvidenceDisclosureLevel.level1PublicSummaryBadge,
        eligible: true,
      );
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        badges: const [eligibleBadge, secondEligibleBadge],
      );

      await tester.tap(find.byKey(const Key('thai_beta_evidence_details')));
      await tester.pumpAndSettle();

      expect(
        find.text(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel),
        findsOneWidget,
      );
      expect(
        find.text(ThaiPublicEvidenceBadgeCopy.cautionCopy),
        findsOneWidget,
      );
    });

    testWidgets('real report enrichment produces only LEVEL 1 badges', (
      tester,
    ) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        badges: null,
        settle: false,
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
      expect(find.text('ที่มาของคำวิเคราะห์'), findsOneWidget);
    });

    testWidgets('anonymous + empty evidence hides badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        badges: const [],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('anonymous + ineligible evidence hides badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        badges: const [ineligibleBadge],
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('signed-in audience has the same result as anonymous', (
      tester,
    ) async {
      for (final audience in [
        const ThaiBetaEvidenceBadgeAudience.anonymous(),
        const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        const ThaiBetaEvidenceBadgeAudience.internalTester(),
      ]) {
        await pumpReport(
          tester,
          flag: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
          audience: audience,
        );
        expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
      }
    });

    testWidgets('public policy does not subscribe to account audience', (
      tester,
    ) async {
      final access = _CountingAudienceAccess();
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
        access: access,
      );
      expect(access.watchCount, 0);
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
    });

    testWidgets('rollout off hides eligible badge', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.off,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    });

    testWidgets('capture uses the same public evidence policy', (tester) async {
      await pumpReport(
        tester,
        flag: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
        audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        screenshotMode: true,
      );
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsOneWidget);
      expect(find.text('ที่มาของคำวิเคราะห์'), findsOneWidget);
    });

    testWidgets('report opens capture with the current analysis', (
      tester,
    ) async {
      ThaiBetaCurrentAnalysis.set(analysis);
      ThaiEvidenceBadgeFeatureFlag.state =
          ThaiEvidenceBadgeFeatureFlagState.publicBeta;
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.publicBeta,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            badgeViewModelsOverride: const [eligibleBadge],
          ),
          onGenerateRoute: ThaiBetaRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      final exportLink = find.byKey(const Key('thai_beta_open_capture_export'));
      await tester.ensureVisible(exportLink);
      await tester.tap(exportLink);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(ThaiBetaReportExportButton), findsOneWidget);
      expect(find.text('ที่มาของคำวิเคราะห์'), findsOneWidget);
    });

    test('PDF document includes only the same eligible public badges', () {
      final withEligible = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
        badges: const [eligibleBadge, ineligibleBadge],
      );
      final withoutEligible = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
        badges: const [ineligibleBadge],
      );

      expect(
        withEligible.fullPlainText,
        contains(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel),
      );
      expect(
        withoutEligible.fullPlainText,
        isNot(contains(ThaiPublicEvidenceBadgeCopy.primaryBadgeLabel)),
      );
      expect(withEligible.fullPlainText, isNot(contains('internal')));
    });
  });
}

class _CountingAudienceAccess implements ThaiBetaEvidenceBadgeAudienceAccess {
  int watchCount = 0;

  @override
  Stream<ThaiBetaEvidenceBadgeAudienceSnapshot> watch() {
    watchCount += 1;
    return const Stream.empty();
  }
}
