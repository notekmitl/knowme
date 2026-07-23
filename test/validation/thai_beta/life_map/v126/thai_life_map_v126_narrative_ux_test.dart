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
        scores: scores,
        lagnaLord: LifePlanet.sun,
        evidence: evidence,
        topThemeTags: const ['รอบคอบ'],
        seed: 42,
      );
    }

    test('early childhood avoids adult career/money/romance framing', () {
      final n = composeForced(start: 1, end: 6, planet: LifePlanet.saturn);
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
