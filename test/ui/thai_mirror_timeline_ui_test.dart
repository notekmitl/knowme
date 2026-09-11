import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../validation/thai_beta/narrative/thai_beta_narrative_fixtures.dart';

/// The production Thai Beta report exposes the accepted shared-report timeline
/// and keeps the retired interactive Life Map labels out of the reader surface.
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

  testWidgets('known report renders the predictive timeline contract', (
    tester,
  ) async {
    await pumpReport(tester);

    expect(find.text('คำทำนายอดีต'), findsOneWidget);
    expect(find.textContaining('คำทำนายปัจจุบัน — อายุ 44 ปี'), findsOneWidget);
    expect(find.text('แนวโน้ม 12 เดือนข้างหน้า'), findsWidgets);
    expect(
      find.byKey(const ValueKey('report-body-predictive-v2-horizon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('report-timeline-predictive-v2-past-heading')),
      findsOneWidget,
    );
  });

  testWidgets('known timeline omits retired expansion and score controls', (
    tester,
  ) async {
    await pumpReport(tester);

    expect(find.text('แผนที่ชีวิตของคุณ'), findsNothing);
    expect(find.text('ดูรายละเอียดช่วงชีวิต'), findsNothing);
    expect(
      find.byKey(const Key('thai_life_timeline_score_explanation')),
      findsNothing,
    );
    expect(find.text('ช่วงย่อย'), findsNothing);
    expect(find.text('ทักษาประจำปี'), findsNothing);
  });

  testWidgets(
    'unknown-time report renders only its four fail-closed chapters',
    (tester) async {
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

      for (final title in [
        'ส่วนที่ 1 · พื้นดวงของคุณ',
        'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
        'ส่วนที่ 3 · แนวโน้มข้างหน้า',
        'ส่วนที่ 4 · ที่มาและข้อจำกัด',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(find.text('คำทำนายอดีต'), findsNothing);
      expect(find.textContaining('คำทำนายปัจจุบัน'), findsNothing);
      expect(find.text('แนวโน้ม 12 เดือนข้างหน้า'), findsNothing);
    },
  );

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

    expect(find.text('คำทำนายอดีต'), findsOneWidget);
    expect(find.textContaining('คำทำนายปัจจุบัน'), findsOneWidget);
    expect(find.text('แนวโน้ม 12 เดือนข้างหน้า'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
