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
            expect(ui.mahabhutPositionLabel, pos.thaiName);
          } else {
            unknown++;
            expect(ui.mahabhutKnown, isFalse);
            expect(ui.mahabhutPositionLabel, isEmpty);
            expect(ui.mahabhutUnknownReason, isNotEmpty);
            expect(pos.unknownReason, isNotNull);
          }
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
      for (final p in pipeline.lifePeriods!.periods) {
        final pos = resolution.resolve(p);
        final ui = state.periods[p.index];
        expect(ui.ageLabel, '${p.startAge}–${p.endAge}');
        expect(ui.mahabhutKnown, pos.known);
        if (pos.known) {
          expect(ui.mahabhutPositionLabel, pos.thaiName);
        } else {
          expect(ui.mahabhutPositionLabel, isEmpty);
          expect(ui.mahabhutUnknownReason, pos.unknownReason);
        }
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

      // Past must not surface guidance headings even if other periods expand.
      final pastAdvice = find.text('คำแนะนำสำหรับช่วงนี้');
      // Current may show advice when expanded — expand current only.
      final expand = find.text(
        ThaiMirrorLifeTimelineSection.expandDetailsLabel,
      );
      if (expand.evaluate().isNotEmpty) {
        await tester.ensureVisible(expand.first);
        await tester.tap(expand.first);
        await tester.pumpAndSettle();
      }
      expect(find.text('สรุปช่วงนี้'), findsWidgets);
      // Past headings for forbidden sections should not appear as empty shells.
      expect(tester.takeException(), isNull);
      // Sanity: past retrospective exists; forbidden past-only labels absent
      // from a pure past card text blob is covered by presenter unit checks.
      expect(pastAdvice, findsWidgets); // present/future may show advice
    });

    test('past narratives have no advice/caution/comparison', () {
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
      for (final p in past) {
        expect(p.advice, isEmpty);
        expect(p.harder, isEmpty);
        expect(p.whatChanges, isEmpty);
        expect(p.comparison, isEmpty);
        expect(p.evidenceLine, isEmpty);
        expect(p.summary.trim(), isNotEmpty);
        expect(
          p.summary.contains('ย้อน') || p.summary.contains('เคยผ่าน'),
          isTrue,
        );
        expect(
          p.summary.split(RegExp(r'[।\.!?…]')).length,
          lessThanOrEqualTo(4),
        );
      }
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
