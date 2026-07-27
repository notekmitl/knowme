import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../validation/thai_beta/narrative/thai_beta_narrative_fixtures.dart';

/// V1.2.6 — Life Map period detail shows age-aware narrative (no score bars /
/// raw nested astrology lists) on the production Thai Beta report path.
void main() {
  Future<void> pumpReport(
    WidgetTester tester, {
    Size size = const Size(390, 2800),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: ThaiBetaNarrativeFixtures.fixtureA(),
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
          featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('timeline section renders with a birth date', (tester) async {
    await pumpReport(tester);

    expect(find.text('แผนที่ชีวิตของคุณ'), findsOneWidget);
    expect(find.text('อดีต'), findsWidgets);
    expect(find.text('ปัจจุบัน'), findsWidgets);
    expect(find.text('อนาคต'), findsWidgets);
  });

  testWidgets('period cards expand to life narrative without score bars', (
    tester,
  ) async {
    await pumpReport(tester);

    // V1.3.5 primary: detailed report replaces expandable legacy period cards.
    expect(find.text('พื้นดวงตลอดชีวิต'), findsOneWidget);
    expect(find.text('ข้อมูลดวงที่พบ'), findsWidgets);
    expect(find.text('คำทำนาย'), findsWidgets);
    expect(
      find.byKey(const Key('thai_life_timeline_score_explanation')),
      findsNothing,
    );
    expect(
      find.text(ThaiMirrorLifeTimelineSection.subPeriodsLabel),
      findsNothing,
    );
    expect(
      find.text(ThaiMirrorLifeTimelineSection.annualTaksaLabel),
      findsNothing,
    );
    expect(find.text('แปดช่วงดาวเสวยอายุ'), findsNothing);
  });

  testWidgets('timeline still renders without a birth time (weekday only)', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 2800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: ThaiBetaNarrativeFixtures.fixtureB(),
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
          featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('แผนที่ชีวิตของคุณ'), findsOneWidget);
  });

  testWidgets('timeline strip shows full Thai phase names without ellipsis', (
    tester,
  ) async {
    await pumpReport(tester, size: const Size(390, 3200));

    expect(find.textContaining('…'), findsNothing);
  });

  testWidgets('desktop width shows narrative sections without overflow', (
    tester,
  ) async {
    await pumpReport(tester, size: const Size(1440, 2000));

    expect(find.text('พื้นดวงตลอดชีวิต'), findsOneWidget);
    expect(find.text('คำทำนาย'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
