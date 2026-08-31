import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// Restoration regression — when a valid V1.3.5 `detailedReport` model exists,
/// the accepted pre-V1.3.5 human-readable Life Map remains the primary render
/// path. `_DetailedEvidenceReport` / raw evidence cards must not appear.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpReport(
    WidgetTester tester, {
    Size size = const Size(390, 4200),
    ThaiBetaEvidenceBadgeAudience audience =
        const ThaiBetaEvidenceBadgeAudience.anonymous(),
    ThaiEvidenceBadgeFeatureFlagState flag =
        ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
    String? userId,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: ThaiBetaNarrativeFixtures.fixtureA(),
          audienceOverride: audience,
          featureFlagOverride: flag,
          userIdOverride: userId,
        ),
      ),
    );
    // Invited audience may start an indeterminate badge load animation.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  void expectAcceptedHumanReadableReport() {
    expect(
      find.byKey(const Key('thai_birth_profile_core_reading')),
      findsOneWidget,
    );
    // This fixture has no source-authorized past prediction. OR2 intentionally
    // omits the heading instead of promoting placement facts into prose.
    expect(find.text('คำทำนายอดีต'), findsNothing);
    expect(find.textContaining('คำทำนายปัจจุบัน — อายุ'), findsNothing);
    expect(find.text('คำทำนาย 12 เดือนข้างหน้า'), findsOneWidget);
    expect(find.textContaining('ช่วงชีวิตถัดไป — อายุ'), findsOneWidget);
  }

  void expectDetailedEvidenceReportAbsent() {
    expect(find.text('พื้นดวงตลอดชีวิต'), findsNothing);
    expect(find.text('รายงานเชิงหลักฐาน'), findsNothing);
    expect(find.text('ข้อมูลดวงที่พบ'), findsNothing);
    expect(find.text('คำแนะนำ ข้อควรระวัง และหมายเหตุสุขภาพ'), findsNothing);
    expect(find.textContaining('sidereal'), findsNothing);
    expect(find.textContaining('Lahiri'), findsNothing);
    expect(find.textContaining('whole-sign'), findsNothing);
    expect(find.textContaining('career='), findsNothing);
    expect(find.textContaining('money='), findsNothing);
    expect(find.textContaining('love='), findsNothing);
    expect(find.textContaining('health='), findsNothing);
    expect(find.textContaining('pressure='), findsNothing);
    expect(find.textContaining('friend'), findsNothing);
    expect(find.textContaining('enemy'), findsNothing);
    expect(find.textContaining('neutral'), findsNothing);
    expect(find.textContaining('ev.lagna'), findsNothing);
    expect(find.textContaining('ev.period.'), findsNothing);
    expect(find.textContaining('ev.score.'), findsNothing);
    expect(find.textContaining('evidenceIds'), findsNothing);
  }

  testWidgets(
    'accepted Life Map remains primary when detailedReport model exists',
    (tester) async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      expect(
        analysis.consumerViewState?.lifeTimeline?.detailedReport,
        isNotNull,
      );

      await pumpReport(tester);

      expectAcceptedHumanReadableReport();
      expectDetailedEvidenceReportAbsent();

      expect(
        find.text(ThaiMirrorLifeTimelineSection.expandDetailsLabel),
        findsNothing,
      );
      expect(find.text('คำทำนายอดีต'), findsNothing);
      expect(find.textContaining('คำทำนายปัจจุบัน — อายุ'), findsNothing);
      expect(find.text('คำทำนาย 12 เดือนข้างหน้า'), findsOneWidget);
      expect(find.textContaining('ช่วงชีวิตถัดไป — อายุ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('accepted layout remains usable at desktop width', (
    tester,
  ) async {
    await pumpReport(tester, size: const Size(1440, 3200));

    expectAcceptedHumanReadableReport();
    expectDetailedEvidenceReportAbsent();
    expect(tester.takeException(), isNull);
  });

  testWidgets('anonymous invited-beta flag does not show badge panel', (
    tester,
  ) async {
    await pumpReport(
      tester,
      audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
    );
    expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    expectAcceptedHumanReadableReport();
    expectDetailedEvidenceReportAbsent();
  });

  testWidgets('ordinary non-invited user has no badge panel', (tester) async {
    await pumpReport(
      tester,
      audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      userId: 'user-not-invited',
    );
    expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    expectAcceptedHumanReadableReport();
    expectDetailedEvidenceReportAbsent();
  });

  testWidgets('internal tester without invite has no LEVEL1 badge leak', (
    tester,
  ) async {
    await pumpReport(
      tester,
      audience: const ThaiBetaEvidenceBadgeAudience.internalTester(),
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      userId: 'admin-not-invited',
    );
    expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    expectAcceptedHumanReadableReport();
    expectDetailedEvidenceReportAbsent();
  });

  testWidgets('eligible invited tester still sees accepted Life Map', (
    tester,
  ) async {
    await pumpReport(
      tester,
      audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      userId: 'invited-user-1',
    );
    expectAcceptedHumanReadableReport();
    expectDetailedEvidenceReportAbsent();
    expect(tester.takeException(), isNull);
  });
}
