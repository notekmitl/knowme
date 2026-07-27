import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// V1.3.5 UI primary — proves the real `/beta/thai` report page renders the
/// detailed evidence report as the primary Life Map surface (not buried under
/// the legacy eight-period narrative).
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

  testWidgets('V1.3.5 is primary report on ThaiBetaReportPage (mobile)', (
    tester,
  ) async {
    await pumpReport(tester);

    expect(find.text('แผนที่ชีวิตของคุณ'), findsOneWidget);
    expect(find.text('พื้นดวงตลอดชีวิต'), findsOneWidget);
    expect(find.text('ภาพรวมชีวิต'), findsWidgets);
    expect(find.text('บุคลิกและวิธีดำเนินชีวิต'), findsOneWidget);
    expect(find.text('การงาน'), findsWidgets);
    expect(find.text('การเงิน'), findsWidgets);
    expect(find.text('ความรัก'), findsOneWidget);
    expect(find.text('สุขภาพ'), findsWidgets);
    expect(find.text('ข้อมูลดวงที่พบ'), findsWidgets);
    expect(find.text('คำทำนาย'), findsWidgets);
    expect(find.text('อดีต'), findsWidgets);
    expect(find.text('ปัจจุบัน'), findsWidgets);
    expect(find.text('อนาคต'), findsWidgets);
    expect(
      find.text('คำแนะนำ ข้อควรระวัง และหมายเหตุสุขภาพ'),
      findsOneWidget,
    );

    // Legacy primary chrome must not appear when detailed report is available.
    expect(find.text('ทำไมช่วงนี้ถึงสำคัญ'), findsNothing);
    expect(find.text('แปดช่วงดาวเสวยอายุ'), findsNothing);
    expect(find.textContaining('รายงานเชิงหลักฐาน'), findsNothing);

    // Current reading combines age-period + birthday-year metadata.
    expect(find.textContaining('ชั้นช่วงอายุ'), findsWidgets);
    expect(find.textContaining('ชั้นปีเกิด'), findsWidgets);

    // Raw evidence IDs stay internal.
    expect(find.textContaining('ev.lagna'), findsNothing);
    expect(find.textContaining('ev.period.'), findsNothing);
    expect(find.textContaining('ev.score.'), findsNothing);
    expect(find.textContaining('evidenceIds'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('V1.3.5 primary also at desktop width', (tester) async {
    await pumpReport(tester, size: const Size(1440, 3200));

    expect(find.text('พื้นดวงตลอดชีวิต'), findsOneWidget);
    expect(find.text('ทำไมช่วงนี้ถึงสำคัญ'), findsNothing);
    expect(find.text('แปดช่วงดาวเสวยอายุ'), findsNothing);
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
    expect(find.text('พื้นดวงตลอดชีวิต'), findsOneWidget);
  });

  testWidgets('ordinary non-invited user has no badge panel', (tester) async {
    await pumpReport(
      tester,
      audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      userId: 'user-not-invited',
    );
    expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
    expect(find.text('พื้นดวงตลอดชีวิต'), findsOneWidget);
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
    expect(find.text('พื้นดวงตลอดชีวิต'), findsOneWidget);
  });

  testWidgets('eligible invited tester keeps V1.3.5 primary surface', (
    tester,
  ) async {
    await pumpReport(
      tester,
      audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
      flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      userId: 'invited-user-1',
    );
    expect(find.text('พื้นดวงตลอดชีวิต'), findsOneWidget);
    expect(find.text('แปดช่วงดาวเสวยอายุ'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
