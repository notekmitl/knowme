import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../narrative/thai_beta_narrative_fixtures.dart';

void main() {
  group('Life Map V1.2.3 report acceptance', () {
    testWidgets('shows Predictive Narrative V2 past/current/future structure', (
      tester,
    ) async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      await tester.binding.setSurfaceSize(const Size(390, 2800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('คำทำนายปัจจุบัน — อายุ 44 ปี'), findsOneWidget);
      expect(find.text('คำทำนายอดีต'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('report-body-predictive-v2-horizon')),
          matching: find.text('แนวโน้ม 12 เดือนข้างหน้า'),
        ),
        findsOneWidget,
      );
      expect(find.text('ช่วงชีวิตถัดไป — อายุ 47–65 ปี'), findsOneWidget);
      expect(
        find.text(ThaiMirrorLifeTimelineSection.expandDetailsLabel),
        findsNothing,
      );
      expect(
        find.text(ThaiMirrorLifeTimelineSection.subPeriodsLabel).hitTestable(),
        findsNothing,
      );

      expect(find.text('อดีต'), findsNothing);
      expect(find.text('ปัจจุบัน'), findsNothing);
      expect(find.text('อนาคต'), findsNothing);
      expect(find.text('อดีตของคุณ'), findsNothing);
      expect(find.text('ช่วงปัจจุบัน'), findsNothing);
      expect(find.text('เรื่องสำคัญของช่วงนี้'), findsNothing);
      expect(find.text('จังหวะชีวิตระยะต่อไป'), findsNothing);
      expect(
        find.text(ThaiMirrorLifeTimelineSection.subPeriodsLabel),
        findsNothing,
      );
      expect(
        find.text(ThaiMirrorLifeTimelineSection.annualTaksaLabel),
        findsNothing,
      );
      expect(
        find.byKey(const Key('thai_life_timeline_score_explanation')),
        findsNothing,
      );
      // Unresolved Mahabhut is kept internal — user UI must not show system copy.
      expect(find.textContaining('ยังยืนยันตำแหน่งไม่ได้'), findsNothing);
      expect(find.textContaining('ยืนยันอันดับตำแหน่งไม่ได้'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('anonymous audience still hides Evidence Badge', (
      tester,
    ) async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      await tester.binding.setSurfaceSize(const Size(390, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Evidence'), findsNothing);
      expect(find.textContaining('หลักฐาน Canon'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
