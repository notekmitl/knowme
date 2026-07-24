import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/past_retrospective_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/period_composite_score.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/period_narrative_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_life_stage_context.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';

/// V1.2.6 follow-up — past narrative life breadth without retrospective prompts.
void main() {
  group('Past life-breadth narrative', () {
    test(
      'child past prefers home/family/school facets for Saturn foundation',
      () {
        final period = PeriodState(
          index: 0,
          planet: LifePlanet.saturn,
          startAge: 1,
          endAge: 10,
          strength: 10,
          isCurrent: false,
          isPast: true,
          progress: 1,
          remainingYears: 0,
          previousPlanet: null,
          nextPlanet: LifePlanet.jupiter,
        );
        final evidence = EvidenceProfile.fromThemeIds(const ['structure']);
        final scores = PeriodCompositeScore.evaluate(
          period: period,
          lagnaLord: LifePlanet.sun,
          evidence: evidence,
          seed: 11,
        );
        final text = PastRetrospectiveComposer.compose(
          band: ThaiLifeStageBand.schoolAge,
          data: LifePlanets.of(LifePlanet.saturn),
          scores: scores,
          seed: 11,
          periodIndex: 0,
        );
        expect(
          PastRetrospectiveComposer.containsRetrospectivePrompt(text),
          isFalse,
        );
        expect(text.contains('บ้าน') || text.contains('ครอบครัว'), isTrue);
        expect(text.contains('อาชีพ'), isFalse);
        expect(text.contains('คู่ครอง'), isFalse);
        expect(text.contains('ลงทุน'), isFalse);
        expect(
          PastRetrospectiveComposer.approxWordCount(text),
          inInclusiveRange(90, 170),
        );
      },
    );

    test('adult past may discuss work/money when affinity supports it', () {
      final period = PeriodState(
        index: 2,
        planet: LifePlanet.mars,
        startAge: 30,
        endAge: 37,
        strength: 8,
        isCurrent: false,
        isPast: true,
        progress: 1,
        remainingYears: 0,
        previousPlanet: LifePlanet.moon,
        nextPlanet: LifePlanet.mercury,
      );
      final evidence = EvidenceProfile.fromThemeIds(const ['action']);
      final scores = PeriodCompositeScore.evaluate(
        period: period,
        lagnaLord: LifePlanet.sun,
        evidence: evidence,
        seed: 22,
      );
      final text = PastRetrospectiveComposer.compose(
        band: ThaiLifeStageBand.workingAdult,
        data: LifePlanets.of(LifePlanet.mars),
        scores: scores,
        seed: 22,
        periodIndex: 2,
      );
      expect(
        PastRetrospectiveComposer.containsRetrospectivePrompt(text),
        isFalse,
      );
      expect(
        text.contains('งาน') ||
            text.contains('อาชีพ') ||
            text.contains('หน้าที่') ||
            text.contains('รายได้'),
        isTrue,
      );
      expect(text.contains('ลองนึกย้อน'), isFalse);
    });

    test('different planets yield meaningfully different past summaries', () {
      final ages = <int, int>{45: DateTime.friday};
      final timeline = LifePeriodEngine.build(
        birthWeekday: ages.values.first,
        currentAge: ages.keys.first,
      );
      final state = TimelinePresenter.build(
        lifePeriods: timeline,
        lagnaLordKey: 'sun',
        orderedThemeIds: const ['structure'],
        topThemeTags: const ['มั่นคง'],
        profileSeed: 9,
      )!;
      final past = state.periods.where((p) => p.isPast).toList();
      expect(past.length, greaterThanOrEqualTo(2));
      for (final p in past) {
        expect(
          PastRetrospectiveComposer.containsRetrospectivePrompt(p.summary),
          isFalse,
        );
        expect(p.summary.contains('ลองทบทวน'), isFalse);
        expect(p.summary.trim().endsWith('หรือไม่'), isFalse);
      }
      expect(past.map((p) => p.summary).toSet().length, past.length);

      // Report-wide: not only school/homework vocabulary.
      final blob = past.map((p) => p.summary).join('\n');
      final schoolOnly =
          blob.contains('การบ้าน') &&
          !blob.contains('บ้าน') &&
          !blob.contains('งาน') &&
          !blob.contains('เปลี่ยน');
      expect(schoolOnly, isFalse);
    });

    test('composer path past narrative has no prompt pad', () {
      final period = PeriodState(
        index: 0,
        planet: LifePlanet.jupiter,
        startAge: 11,
        endAge: 29,
        strength: 19,
        isCurrent: false,
        isPast: true,
        progress: 1,
        remainingYears: 0,
        previousPlanet: LifePlanet.saturn,
        nextPlanet: LifePlanet.rahu,
      );
      final evidence = EvidenceProfile.fromThemeIds(const ['thinking']);
      final scores = PeriodCompositeScore.evaluate(
        period: period,
        lagnaLord: LifePlanet.moon,
        evidence: evidence,
        seed: 7,
      );
      final narrative = PeriodNarrativeComposer.compose(
        period: period,
        narrativeAge: 29,
        scores: scores,
        lagnaLord: LifePlanet.moon,
        evidence: evidence,
        topThemeTags: const ['รอบคอบ'],
        seed: 7,
      );
      expect(narrative.advice, isEmpty);
      expect(
        PastRetrospectiveComposer.containsRetrospectivePrompt(
          narrative.summary,
        ),
        isFalse,
      );
      expect(narrative.summary.contains('\n\n'), isTrue);
    });
  });
}
