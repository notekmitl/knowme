import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/relevant_life_periods_selector.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_v12.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import 'thai_beta_narrative_fixtures.dart';

/// Thai Beta Report V1.2.1 — Relevant Timeline + Progressive Disclosure.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V1.2.1 presentation acceptance', () {
    test('V121-6 boundary ages keep engine inclusive windows', () {
      final view = ThaiBetaNarrativeComposer.narrativeView(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final timeline = view.lifeTimeline;
      expect(timeline, isNotNull);
      final ages = timeline!.periods.map((p) => p.ageLabel).toList();
      expect(ages.length, greaterThan(3));
      final selected = RelevantLifePeriodsSelector.select(
        periods: timeline.periods,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.length, lessThanOrEqualTo(3));
      expect(selected.where((p) => p.isCurrent), hasLength(1));
      // Source list length unchanged after selection.
      expect(timeline.periods.length, ages.length);
    });

    test('V121-8 long source → UI projection ≤3', () {
      final view = ThaiBetaNarrativeComposer.narrativeView(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final all = view.lifeTimeline!.periods;
      expect(all.length, greaterThanOrEqualTo(5));
      final lastAge = all.last.ageLabel;
      final end = int.parse(lastAge.split('–').last);
      expect(end, greaterThanOrEqualTo(100));
      final selected = RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.length, lessThanOrEqualTo(3));
      expect(selected.any((p) => p.ageLabel == lastAge), isFalse);
    });

    test('V121-16 V1.2 narrative still present on composed view', () {
      final result =
          ThaiBetaNarrativeComposer.compose(ThaiBetaNarrativeFixtures.fixtureA());
      expect(result.view.signatureInsight.isEmpty, isFalse);
      expect(result.view.strengths.title, ThaiBetaNarrativeV12.strengthsSectionTitle);
      expect(result.view.cautions.title, ThaiBetaNarrativeV12.cautionsSectionTitle);
      expect(result.view.advice.title, ThaiBetaNarrativeV12.adviceSectionTitle);
      expect(
        result.trace.entries.any((e) => e.sectionId == 'personal_core'),
        isTrue,
      );
    });

    test('V121-17 no-time policy unchanged', () {
      final noTime = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      );
      final unknown = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.incompleteTimeUnknownFlag(),
      );
      expect(noTime.view.birthDataConfidence.isComplete, isFalse);
      expect(
        noTime.view.signatureInsight.eyebrow,
        unknown.view.signatureInsight.eyebrow,
      );
    });

    test('V121-18 Wednesday daytime normalization unchanged', () {
      final analysis = ThaiBetaNarrativeFixtures.wednesdayDaytime();
      expect(analysis.isSuccess, isTrue);
      final snap = analysis.normalizedSnapshot!;
      expect(_thaiWeekdayNumber(snap.thaiAstrologicalDate), 4);
    });

    test('V121-20 Evidence Badge rollout unchanged', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });
  });

  group('V1.2.1 timeline UI', () {
    ThaiMirrorLifeTimelineState longState() {
      ThaiMirrorLifePeriodState period({
        required String age,
        required String name,
        required bool current,
        required bool past,
        required int accent,
      }) {
        return ThaiMirrorLifePeriodState(
          ageLabel: age,
          phaseName: name,
          planetLine: 'อิทธิพลทดสอบ • คำสำคัญ',
          keyword: 'คำสำคัญ',
          isCurrent: current,
          isPast: past,
          summary: 'สรุป$age',
          whatChanges: 'สิ่งที่เปลี่ยนใน$age',
          easier: 'ง่ายขึ้น',
          harder: 'ยากขึ้น',
          comparison: 'เปรียบเทียบ',
          evidenceLine: 'หลักฐาน',
          scores: const [
            ThaiMirrorPeriodScoreBar(label: 'การงาน', value: 70),
            ThaiMirrorPeriodScoreBar(label: 'การเงิน', value: 55),
          ],
          easeIndex: 1,
          accentIndex: accent,
        );
      }

      ThaiMirrorTimelineSegmentState segment({
        required String age,
        required String name,
        required bool current,
        required bool past,
        required int accent,
      }) {
        return ThaiMirrorTimelineSegmentState(
          ageLabel: age,
          phaseName: name,
          planetName: 'ทดสอบ',
          strength: 10,
          isCurrent: current,
          isPast: past,
          progress: current ? 0.4 : (past ? 1.0 : 0.0),
          accentIndex: accent,
        );
      }

      final periods = <ThaiMirrorLifePeriodState>[
        period(age: '1–10', name: 'ช่วงA', current: false, past: true, accent: 0),
        period(age: '11–20', name: 'ช่วงB', current: false, past: true, accent: 1),
        period(age: '21–30', name: 'ช่วงC', current: true, past: false, accent: 2),
        period(age: '31–40', name: 'ช่วงD', current: false, past: false, accent: 3),
        period(age: '120–137', name: 'ช่วงไกล', current: false, past: false, accent: 4),
      ];
      final segments = <ThaiMirrorTimelineSegmentState>[
        segment(age: '1–10', name: 'ช่วงA', current: false, past: true, accent: 0),
        segment(age: '11–20', name: 'ช่วงB', current: false, past: true, accent: 1),
        segment(age: '21–30', name: 'ช่วงC', current: true, past: false, accent: 2),
        segment(age: '31–40', name: 'ช่วงD', current: false, past: false, accent: 3),
        segment(age: '120–137', name: 'ช่วงไกล', current: false, past: false, accent: 4),
      ];

      return ThaiMirrorLifeTimelineState(
        sectionTitle: 'เส้นทางชีวิตของคุณ',
        sectionIntro: 'intro ยาว',
        currentStage: const ThaiMirrorCurrentStageState(
          eyebrow: 'คุณอยู่ช่วงไหนของชีวิต',
          currentAge: 25,
          ageLabel: '21–30',
          phaseName: 'ช่วงC',
          planetLine: 'อิทธิพลทดสอบ • คำสำคัญ',
          keyword: 'คำสำคัญ',
          yearsRemaining: 5,
          progress: 0.4,
          intro: 'อยู่ในช่วงปัจจุบัน',
          previousLabel: 'ช่วงก่อนหน้า: ช่วงB (11–20)',
          nextLabel: 'ช่วงถัดไป: ช่วงD (31–40)',
          accentIndex: 2,
        ),
        segments: segments,
        periods: periods,
        futurePreview: const ThaiMirrorFuturePreviewState(
          title: 'ช่วงต่อไปของคุณ',
          intro: 'preview ซ้ำกับช่วงถัดไป',
          transitionLabel: 'เปลี่ยนผ่าน',
          elementShiftLine: '',
          opportunitiesLine: 'โอกาส',
          challengesLine: 'ความท้าทาย',
        ),
      );
    }

    Future<void> pumpTimeline(
      WidgetTester tester, {
      required Size size,
      required bool compact,
    }) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ThaiMirrorLifeTimelineSection(
                state: longState(),
                relevantPeriodsOnly: compact,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('V121-8/12 compact: ≤3 periods, collapsed, no far age',
        (tester) async {
      await pumpTimeline(tester, size: const Size(390, 844), compact: true);
      expect(find.text('ช่วงชีวิตที่เกี่ยวข้อง'), findsOneWidget);
      expect(find.text('ช่วงA'), findsNothing);
      expect(find.text('ช่วงB'), findsWidgets);
      expect(find.text('ช่วงC'), findsWidgets);
      expect(find.text('ช่วงD'), findsWidgets);
      expect(find.text('ช่วงไกล'), findsNothing);
      expect(find.textContaining('137'), findsNothing);
      expect(find.text('ช่วงต่อไปของคุณ'), findsNothing);
      expect(
        find.text(ThaiMirrorLifeTimelineSection.expandDetailsLabel),
        findsWidgets,
      );
      expect(
        find.byKey(const Key('thai_life_timeline_score_explanation')).hitTestable(),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('V121-11/13 expand shows score explanation + scores',
        (tester) async {
      await pumpTimeline(tester, size: const Size(390, 1200), compact: true);
      final expand =
          find.text(ThaiMirrorLifeTimelineSection.expandDetailsLabel).first;
      await tester.ensureVisible(expand);
      await tester.pumpAndSettle();
      await tester.tap(expand);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('thai_life_timeline_score_explanation')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.text(ThaiMirrorLifeTimelineSection.scoreExplanation).hitTestable(),
        findsOneWidget,
      );
      expect(find.text('การงาน').hitTestable(), findsOneWidget);
      expect(find.text('70').hitTestable(), findsOneWidget);
      final collapse = find
          .text(ThaiMirrorLifeTimelineSection.collapseDetailsLabel)
          .hitTestable();
      await tester.ensureVisible(collapse);
      await tester.pumpAndSettle();
      await tester.tap(collapse);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('thai_life_timeline_score_explanation')).hitTestable(),
        findsNothing,
      );
    });

    testWidgets('V121-14 mobile width no exception', (tester) async {
      await pumpTimeline(tester, size: const Size(390, 844), compact: true);
      expect(tester.takeException(), isNull);
      final overflow = find.byWidgetPredicate(
        (w) => w is ErrorWidget,
      );
      expect(overflow, findsNothing);
    });

    testWidgets('V121-15 desktop width no exception', (tester) async {
      await pumpTimeline(tester, size: const Size(1280, 900), compact: true);
      expect(tester.takeException(), isNull);
    });

    testWidgets('V121-5 empty periods does not crash', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final empty = ThaiMirrorLifeTimelineState(
        sectionTitle: 'เส้นทางชีวิตของคุณ',
        sectionIntro: 'intro',
        currentStage: longState().currentStage,
        segments: const [],
        periods: const [],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThaiMirrorLifeTimelineSection(
              state: empty,
              relevantPeriodsOnly: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('ยังไม่มีข้อมูลช่วงชีวิต'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('V1.2.1 full report regression UI', () {
    late ThaiBetaAnalysis analysis;

    setUpAll(() {
      analysis = ThaiBetaNarrativeFixtures.fixtureA();
    });

    Future<void> pumpReport(WidgetTester tester, Size size) async {
      await tester.binding.setSurfaceSize(size);
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
    }

    testWidgets('V121-14/16/19/20 report: core + compact timeline + no badge',
        (tester) async {
      await pumpReport(tester, const Size(390, 844));
      expect(find.byType(ThaiBetaReportPage), findsOneWidget);
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
      expect(find.byKey(const Key('thai_consumer_signature_insight')), findsOneWidget);
      expect(find.text(ThaiBetaNarrativeV12.strengthsSectionTitle), findsOneWidget);
      expect(find.text('ช่วงชีวิตที่เกี่ยวข้อง'), findsOneWidget);
      expect(find.textContaining('137'), findsNothing);
      expect(
        find.text(ThaiMirrorLifeTimelineSection.expandDetailsLabel),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('V121-15 desktop report hierarchy', (tester) async {
      await pumpReport(tester, const Size(1280, 900));
      expect(find.byKey(const Key('thai_consumer_signature_insight')), findsOneWidget);
      expect(find.text('ช่วงชีวิตที่เกี่ยวข้อง'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

int _thaiWeekdayNumber(String ymd) {
  final parts = ymd.split('-');
  final d = DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
  final w = d.weekday;
  return w == DateTime.sunday ? 1 : w + 1;
}
