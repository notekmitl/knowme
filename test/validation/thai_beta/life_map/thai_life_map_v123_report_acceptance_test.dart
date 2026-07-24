import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../narrative/thai_beta_narrative_fixtures.dart';

void main() {
  group('Life Map V1.2.3 report acceptance', () {
    testWidgets('shows eight Life Map periods collapsed with nested labels', (
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

      expect(find.text('แผนที่ชีวิตของคุณ'), findsOneWidget);
      expect(find.text('อดีต'), findsWidgets);
      expect(find.text('ปัจจุบัน'), findsWidgets);
      expect(find.text('อนาคต'), findsWidgets);
      expect(
        find.text(ThaiMirrorLifeTimelineSection.expandDetailsLabel),
        findsWidgets,
      );
      expect(
        find.text(ThaiMirrorLifeTimelineSection.subPeriodsLabel).hitTestable(),
        findsNothing,
      );

      final expand = find
          .text(ThaiMirrorLifeTimelineSection.expandDetailsLabel)
          .first;
      await tester.ensureVisible(expand);
      await tester.tap(expand);
      await tester.pumpAndSettle();

      // V1.2.6 — user detail shows life narrative sections, not raw nested lists.
      expect(find.text('สรุปช่วงนี้'), findsWidgets);
      expect(find.text('เรื่องที่เด่น'), findsWidgets);
      expect(find.text('สิ่งที่ควรระวัง'), findsWidgets);
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
