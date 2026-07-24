import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_life_map_mahabhut_resolution.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_life_timeline_section.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// V1.2.6 follow-up — past/present/future density + Mahabhut user-surface hygiene.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mahabhut diagnostic (8 periods)', () {
    late ThaiCanonEvidenceRepository repository;

    setUpAll(() async {
      ThaiCanonEvidenceRepository.clearCachedForTest();
      repository = await ThaiCanonEvidenceRepository.loadFromAsset();
      ThaiCanonEvidenceRepository.bindCachedForTest(repository);
    });

    tearDownAll(ThaiCanonEvidenceRepository.clearCachedForTest);

    test(
      '1972-04-04 fixture stays known=7 / unknown=1 with internal reason',
      () async {
        final analysis = await ThaiBetaAnalysisRunner.runAsync(
          ThaiBetaInput(
            firstName: 'QA',
            lastName: 'User',
            birthDate: DateTime(1972, 4, 4),
            birthHour: 2,
            birthMinute: 0,
            province: 'กรุงเทพมหานคร',
            provinceKey: 'bangkok',
          ),
        );
        expect(analysis.isSuccess, isTrue);

        final pipeline = analysis.pipelineResult!;
        final resolution = ThaiLifeMapMahabhutResolution.tryCreate(
          profile: pipeline.profile,
          birthData: pipeline.birthData,
          canonIndex: repository.index,
        )!;

        var known = 0;
        var unknown = 0;
        for (final p in pipeline.lifePeriods!.periods) {
          final pos = resolution.resolve(p);
          final ui = analysis.consumerViewState!.lifeTimeline!.periods[p.index];
          if (pos.known) {
            known++;
            expect(ui.mahabhutKnown, isTrue);
          } else {
            unknown++;
            expect(ui.mahabhutKnown, isFalse);
            expect(ui.mahabhutUnknownReason, isNotEmpty);
            expect(pos.unknownReason, isNotNull);
          }
          // Report-level: any unknown ⇒ hide Mahabhut on every card.
          expect(ui.mahabhutShownOnReport, isFalse);
          expect(ui.mahabhutPositionLabel, isEmpty);
          expect(ui.mahabhutDescription, isEmpty);
        }
        expect(known, 7);
        expect(unknown, 1);
      },
    );

    test('sample QA fixture diagnostic rows cover all eight periods', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final resolution = ThaiLifeMapMahabhutResolution.tryCreate(
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      )!;
      final state = TimelinePresenter.build(
        lifePeriods: pipeline.lifePeriods,
        lagnaLordKey: 'moon',
        orderedThemeIds: const ['thinking'],
        topThemeTags: const ['รอบคอบ'],
        profileSeed: 1,
        profile: pipeline.profile,
        birthData: pipeline.birthData,
        canonIndex: repository.index,
      )!;

      expect(state.periods, hasLength(8));
      final allKnown = pipeline.lifePeriods!.periods.every(
        (p) => resolution.resolve(p).known,
      );
      expect(allKnown, isTrue);
      expect(state.periods.every((p) => p.mahabhutShownOnReport), isTrue);
      for (final p in pipeline.lifePeriods!.periods) {
        final pos = resolution.resolve(p);
        final ui = state.periods[p.index];
        expect(ui.ageLabel, '${p.startAge}–${p.endAge}');
        expect(ui.mahabhutKnown, pos.known);
        expect(ui.mahabhutPositionLabel, pos.thaiName);
        expect(ui.mahabhutDescription, isNotEmpty);
      }
    });
  });

  group('Past / present / future UX', () {
    testWidgets('past cards omit advice and unknown mahabhut copy', (
      tester,
    ) async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      await tester.binding.setSurfaceSize(const Size(390, 3200));
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
      expect(find.text('สิ่งที่น่าจะผ่านมา'), findsWidgets);
      expect(find.textContaining('ยังยืนยันตำแหน่งไม่ได้'), findsNothing);
      expect(find.textContaining('ยืนยันอันดับตำแหน่งไม่ได้'), findsNothing);
      expect(find.textContaining('ธีมหลัก'), findsNothing);
      expect(find.textContaining('ซ่อนรายละเอียดช่วงชีวิต'), findsNothing);
      expect(find.textContaining('เรื่องสำคัญของช่วงนี้'), findsWidgets);

      final expand = find.text(
        ThaiMirrorLifeTimelineSection.expandDetailsLabel,
      );
      if (expand.evaluate().isNotEmpty) {
        await tester.ensureVisible(expand.first);
        await tester.tap(expand.first);
        await tester.pumpAndSettle();
      }
      expect(find.text('สรุปช่วงนี้'), findsWidgets);
      expect(find.textContaining('ซ่อนรายละเอียดช่วงชีวิต'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    test('past narratives have denser retrospective without advice', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.friday,
        currentAge: 45,
      );
      final state = TimelinePresenter.build(
        lifePeriods: timeline,
        lagnaLordKey: 'sun',
        orderedThemeIds: const ['structure'],
        topThemeTags: const ['มั่นคง'],
        profileSeed: 3,
      )!;
      final past = state.periods.where((p) => p.isPast).toList();
      expect(past, isNotEmpty);
      final summaries = <String>{};
      for (final p in past) {
        expect(p.advice, isEmpty);
        expect(p.harder, isEmpty);
        expect(p.whatChanges, isEmpty);
        expect(p.comparison, isEmpty);
        expect(p.evidenceLine, isEmpty);
        expect(p.summary.trim(), isNotEmpty);
        expect(p.summary.contains('\n\n'), isTrue);
        final chars = p.summary.replaceAll(RegExp(r'\s+'), '').runes.length;
        final approxWords = (chars / 2.5).round();
        expect(approxWords, inInclusiveRange(90, 170));
        expect(chars, greaterThanOrEqualTo(200));
        expect(
          p.summary.contains('อาจ') ||
              p.summary.contains('แนวโน้ม') ||
              p.summary.contains('ย้อน'),
          isTrue,
        );
        expect(p.summary.contains('คำแนะนำ'), isFalse);
        expect(p.summary.contains('สิ่งที่ควรระวัง'), isFalse);
        expect(p.summary.contains('แนวทางส่งเสริม'), isFalse);
        expect(p.summary.contains('ลองนึกย้อน'), isFalse);
        expect(p.summary.contains('ลองทบทวน'), isFalse);
        expect(p.summary.contains('ลองสังเกต'), isFalse);
        expect(p.summary.trim().endsWith('หรือไม่'), isFalse);
        summaries.add(p.summary);
      }
      expect(summaries.length, past.length);
      // Across past cards, life facets should not collapse to school-only copy.
      final joined = summaries.join('\n');
      expect(
        joined.contains('บ้าน') ||
            joined.contains('ครอบครัว') ||
            joined.contains('งาน') ||
            joined.contains('เปลี่ยน'),
        isTrue,
      );
      final future = state.periods.where((p) => !p.isPast && !p.isCurrent);
      for (final p in future) {
        expect(
          p.summary.contains('อาจ') || p.summary.contains('เมื่อถึง'),
          isTrue,
        );
        expect(p.advice, isNotEmpty);
      }
      final current = state.periods.singleWhere((p) => p.isCurrent);
      expect(current.advice, isNotEmpty);
      expect(current.harder, isNotEmpty);
    });
  });
}
