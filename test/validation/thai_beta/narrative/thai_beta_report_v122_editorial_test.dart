import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_future_prediction_section.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_v12.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import 'thai_beta_narrative_fixtures.dart';

/// Thai Beta Narrative Editorial Pass V1.2.2 — user-facing chrome only.
///
/// Asserts warmer wording and absence of system-ish labels, without changing
/// Canon, calculation, curated block bodies, or scoring.
void main() {
  group('V1.2.2 editorial constants', () {
    test('V122-1 score explanation drops system ranking jargon', () {
      const copy = ThaiMirrorLifeTimelineSection.scoreExplanation;
      expect(copy, contains('ไม่ใช่เปอร์เซ็นต์ความแม่นยำ'));
      expect(copy, contains('ไม่ใช่'));
      expect(copy, isNot(contains('สัญญาณที่ระบบ')));
      expect(copy, isNot(contains('จัดลำดับเนื้อหา')));
      expect(copy, contains('เด่นพอให้อ่านก่อน'));
    });

    test('V122-2 Personal Core chrome uses ข้อมูล not หลักฐาน/สัญญาณ', () {
      expect(
        ThaiBetaNarrativeV12.personalCoreEyebrow(
          ThaiBetaNarrativeConfidenceBand.high,
        ),
        'แก่นที่เห็นชัดจากข้อมูลของคุณ',
      );
      expect(
        ThaiBetaNarrativeV12.personalCoreEyebrow(
          ThaiBetaNarrativeConfidenceBand.medium,
        ),
        'แก่นที่พอเห็นได้จากข้อมูลที่มี',
      );
      expect(
        ThaiBetaNarrativeV12.personalCoreSignature(
          ThaiBetaNarrativeConfidenceBand.high,
        ),
        isNot(contains('สัญญาณ')),
      );
      expect(
        ThaiBetaNarrativeV12.personalCoreSignature(
          ThaiBetaNarrativeConfidenceBand.high,
        ),
        contains('สังเกตตัวเอง'),
      );
      expect(
        ThaiBetaNarrativeV12.strengthsSectionTitle,
        'จุดแข็งที่เด่นในตัวคุณ',
      );
      expect(
        ThaiBetaNarrativeV12.strengthsSectionTitle,
        isNot(contains('หลักฐาน')),
      );
    });

    test('V122-3 future intro stays soft and non-fate', () {
      final intel = LifeTimelineIntelligenceEngine.fromBirthDate(
        DateTime(1982, 6, 6),
        asOf: DateTime(2026, 7, 22),
      );
      final prediction = PredictionIntelligenceEngine.fromIntelligence(intel);
      final model = PredictionComposer.compose(
        intelligence: prediction,
        seed: 7,
      );
      expect(model, isNotNull);
      expect(model!.sectionIntro, isNot(contains('ต่อไปนี้คือ')));
      expect(model.sectionIntro, contains('ไม่ใช่คำทำนาย'));
      for (final card in model.windows) {
        expect(card.evidenceDetail, isNot(contains('ที่มาเชิงเทคนิค')));
        expect(card.evidenceDetail, isNot(contains('เชิงเทคนิค')));
      }
    });
  });

  group('V1.2.2 report UI chrome', () {
    testWidgets('V122-4 confidence meter label is ความชัดของแนวโน้ม',
        (tester) async {
      final intel = LifeTimelineIntelligenceEngine.fromBirthDate(
        DateTime(1982, 6, 6),
        asOf: DateTime(2026, 7, 22),
      );
      final prediction = PredictionIntelligenceEngine.fromIntelligence(intel);
      final model = PredictionComposer.compose(
        intelligence: prediction,
        seed: 3,
      );
      expect(model, isNotNull);

      await tester.binding.setSurfaceSize(const Size(390, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ThaiMirrorFuturePredictionSection(state: model!),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ความชัดของแนวโน้ม'), findsWidgets);
      expect(find.text('ความมั่นใจของแนวโน้ม'), findsNothing);
    });

    testWidgets('V122-5 full report shows editorial titles, no old jargon',
        (tester) async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      await tester.binding.setSurfaceSize(const Size(390, 1600));
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

      expect(find.text(ThaiBetaNarrativeV12.strengthsSectionTitle), findsOneWidget);
      expect(find.text('จุดแข็งที่เด่นจากหลักฐาน'), findsNothing);
      expect(find.textContaining('สัญญาณที่ระบบ'), findsNothing);
      expect(find.textContaining('ที่มาเชิงเทคนิค'), findsNothing);
      expect(find.text('ความมั่นใจของแนวโน้ม'), findsNothing);
      expect(find.text('ความชัดของแนวโน้ม'), findsWidgets);
      expect(
        find.textContaining('โฟกัสช่วงที่เกี่ยวข้องกับตอนนี้'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
