import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/period_composite_score.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/period_narrative_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_life_stage_context.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_narrative_blocks.dart';

void main() {
  group('life-stage classification', () {
    test('boundaries have no gap or overlap for ages 1–108', () {
      ThaiLifeStageBand? prev;
      for (var age = 1; age <= 108; age++) {
        final band = ThaiLifeStageContext.fromAge(age);
        if (prev != null) {
          final order = ThaiLifeStageBand.values.indexOf(band);
          final prevOrder = ThaiLifeStageBand.values.indexOf(prev);
          expect(order >= prevOrder, isTrue, reason: 'age $age');
        }
        prev = band;
      }
      expect(ThaiLifeStageContext.fromAge(6), ThaiLifeStageBand.earlyChildhood);
      expect(ThaiLifeStageContext.fromAge(7), ThaiLifeStageBand.schoolAge);
      expect(ThaiLifeStageContext.fromAge(13), ThaiLifeStageBand.teen);
      expect(ThaiLifeStageContext.fromAge(18), ThaiLifeStageBand.youngAdult);
      expect(ThaiLifeStageContext.fromAge(30), ThaiLifeStageBand.workingAdult);
      expect(ThaiLifeStageContext.fromAge(50), ThaiLifeStageBand.midlife);
      expect(ThaiLifeStageContext.fromAge(65), ThaiLifeStageBand.elder);
    });
  });

  group('age-appropriate narrative', () {
    PeriodNarrative composeForced({
      required int start,
      required int end,
      required int narrativeAge,
      required LifePlanet planet,
      LifePlanet? previous,
      LifePlanet? next,
      int index = 0,
    }) {
      final period = PeriodState(
        index: index,
        planet: planet,
        startAge: start,
        endAge: end,
        strength: end - start + 1,
        isCurrent: false,
        isPast: true,
        progress: 1,
        remainingYears: 0,
        previousPlanet: previous,
        nextPlanet: next,
      );
      final evidence = EvidenceProfile.fromThemeIds(const ['thinking']);
      final scores = PeriodCompositeScore.evaluate(
        period: period,
        lagnaLord: LifePlanet.sun,
        evidence: evidence,
        seed: 42,
      );
      return PeriodNarrativeComposer.compose(
        period: period,
        narrativeAge: narrativeAge,
        scores: scores,
        lagnaLord: LifePlanet.sun,
        evidence: evidence,
        topThemeTags: const ['รอบคอบ'],
        seed: 42,
      );
    }

    test('early childhood avoids adult career/money/romance framing', () {
      final n = composeForced(
        start: 1,
        end: 10,
        narrativeAge: 5,
        planet: LifePlanet.saturn,
      );
      expect(n.stageLabel, 'วัยเด็กเล็ก');
      expect(n.advice.contains('ผู้ปกครอง'), isTrue);
      final blob = '${n.summary}${n.whatChanges}${n.harder}${n.advice}';
      expect(blob.contains('อาชีพ'), isFalse);
      expect(blob.contains('ลงทุน'), isFalse);
      expect(blob.contains('คู่ครอง'), isFalse);
      expect(blob.contains('คิดรอบก่อนตอบ'), isFalse);
    });

    test('working adult may discuss work and responsibility', () {
      final n = composeForced(
        start: 30,
        end: 40,
        narrativeAge: 35,
        planet: LifePlanet.jupiter,
        previous: LifePlanet.saturn,
        next: LifePlanet.rahu,
        index: 2,
      );
      expect(n.stageLabel, 'วัยทำงาน');
      final blob = '${n.summary}${n.whatChanges}${n.advice}';
      expect(
        blob.contains('งาน') ||
            blob.contains('เป้าหมาย') ||
            blob.contains('รับผิดชอบ'),
        isTrue,
      );
    });

    test(
      'first period has empty comparison; later periods have comparison',
      () {
        final timeline = LifePeriodEngine.build(
          birthWeekday: DateTime.monday,
          currentAge: 40,
        );
        final evidence = EvidenceProfile.fromThemeIds(const ['structure']);
        PeriodNarrative compose(PeriodState p) {
          final scores = PeriodCompositeScore.evaluate(
            period: p,
            lagnaLord: LifePlanet.moon,
            evidence: evidence,
            seed: 7,
          );
          return PeriodNarrativeComposer.compose(
            period: p,
            narrativeAge: p.isCurrent
                ? timeline.currentAge
                : p.isPast
                ? p.endAge
                : p.startAge,
            scores: scores,
            lagnaLord: LifePlanet.moon,
            evidence: evidence,
            topThemeTags: const ['มั่นคง'],
            seed: 7,
          );
        }

        expect(compose(timeline.periods.first).comparison, isEmpty);
        expect(compose(timeline.periods[1]).comparison, isNotEmpty);
      },
    );

    test(
      'presenter uses actual age inside a long current astrology period',
      () {
        final expectedStages = <int, String>{
          11: 'วัยเรียน',
          12: 'วัยเรียน',
          13: 'วัยรุ่น',
          17: 'วัยรุ่น',
          18: 'วัยเริ่มต้นผู้ใหญ่',
          29: 'วัยเริ่มต้นผู้ใหญ่',
        };

        for (final entry in expectedStages.entries) {
          final timeline = LifePeriodEngine.build(
            birthWeekday: DateTime.monday,
            currentAge: entry.key,
          );
          final state = TimelinePresenter.build(
            lifePeriods: timeline,
            lagnaLordKey: 'moon',
            orderedThemeIds: const ['thinking'],
            topThemeTags: const ['รอบคอบ'],
            profileSeed: 7,
          );
          final current = state!.periods.singleWhere((p) => p.isCurrent);
          expect(
            current.stageLabel,
            entry.value,
            reason: 'current age ${entry.key}',
          );
        }
      },
    );

    test(
      'child and teen current periods never use adult narrative framing',
      () {
        for (final age in const [7, 11, 12, 13, 15, 17]) {
          final timeline = LifePeriodEngine.build(
            birthWeekday: DateTime.monday,
            currentAge: age,
          );
          final state = TimelinePresenter.build(
            lifePeriods: timeline,
            lagnaLordKey: 'moon',
            orderedThemeIds: const ['thinking'],
            topThemeTags: const ['รอบคอบ'],
            profileSeed: 7,
          );
          final current = state!.periods.singleWhere((p) => p.isCurrent);
          final blob =
              '${current.summary}${current.whatChanges}${current.harder}'
              '${current.advice}';
          expect(blob.contains('วัยเริ่มทำงาน'), isFalse, reason: 'age $age');
          expect(blob.contains('บทบาทผู้ใหญ่'), isFalse, reason: 'age $age');
          expect(blob.contains('ลงทุน'), isFalse, reason: 'age $age');
          expect(blob.contains('คู่ครอง'), isFalse, reason: 'age $age');
        }
      },
    );

    test('past and future periods use the nearest boundary age', () {
      final age5 = TimelinePresenter.build(
        lifePeriods: LifePeriodEngine.build(
          birthWeekday: DateTime.monday,
          currentAge: 5,
        ),
        lagnaLordKey: 'moon',
        orderedThemeIds: const ['thinking'],
        topThemeTags: const ['รอบคอบ'],
        profileSeed: 7,
      )!;
      final nextFromAge5 = age5.periods.firstWhere(
        (p) => !p.isPast && !p.isCurrent,
      );
      expect(nextFromAge5.ageLabel, '16–23');
      expect(nextFromAge5.stageLabel, 'วัยรุ่น');

      final age30 = TimelinePresenter.build(
        lifePeriods: LifePeriodEngine.build(
          birthWeekday: DateTime.monday,
          currentAge: 30,
        ),
        lagnaLordKey: 'moon',
        orderedThemeIds: const ['thinking'],
        topThemeTags: const ['รอบคอบ'],
        profileSeed: 7,
      )!;
      final previousFromAge30 = age30.periods.lastWhere((p) => p.isPast);
      expect(previousFromAge30.ageLabel, '16–23');
      expect(previousFromAge30.stageLabel, 'วัยเริ่มต้นผู้ใหญ่');
    });
  });

  group('Thai composition hygiene', () {
    test(
      'no broken fragment example and no double spaces in curated heroes',
      () {
        for (final block in ThaiBetaCuratedNarrativeBlocks.all) {
          for (final line in block.heroSentences) {
            expect(line.contains('คิดรอบก่อนตอบ'), isFalse);
            expect(line.contains('  '), isFalse);
          }
        }
      },
    );

    test('timeline presenter intro no longer invites raw ดาวแทรก UI', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.wednesday,
        currentAge: 35,
      );
      final state = TimelinePresenter.build(
        lifePeriods: timeline,
        lagnaLordKey: 'mercury',
        orderedThemeIds: const ['thinking'],
        topThemeTags: const ['รอบคอบ'],
        profileSeed: 1,
      );
      expect(state, isNotNull);
      expect(state!.sectionIntro.contains('ดาวแทรก'), isFalse);
      expect(state.sectionIntro.contains('ทักษาจร'), isFalse);
      expect(state.periods.length, 8);
      for (final p in state.periods) {
        expect(p.summary.trim(), isNotEmpty);
        expect(
          p.advice.trim().isNotEmpty || p.easier.trim().isNotEmpty,
          isTrue,
        );
        expect(p.stageLabel, isNotEmpty);
      }
    });
  });
}
