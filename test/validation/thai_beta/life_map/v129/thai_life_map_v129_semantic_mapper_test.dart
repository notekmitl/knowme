import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_semantic_mapper.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_semantics.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/period_composite_score.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/period_narrative_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_life_stage_context.dart';

void main() {
  group('semantic mapper contract', () {
    test('claims always include situation domain consequence ids', () {
      for (final planet in LifePlanet.values) {
        final period = PeriodState(
          index: 2,
          planet: planet,
          startAge: 30,
          endAge: 40,
          strength: 10,
          isCurrent: true,
          isPast: false,
          progress: 0.4,
          remainingYears: 5,
          previousPlanet: LifePlanet.moon,
          nextPlanet: LifePlanet.mars,
        );
        final scores = PeriodCompositeScore.evaluate(
          period: period,
          lagnaLord: LifePlanet.sun,
          evidence: EvidenceProfile.fromThemeIds(const ['structure']),
          seed: 9,
        );
        final sem = LifeMapSemanticMapper.build(
          tense: LifeMapVerdictTense.current,
          band: ThaiLifeStageBand.workingAdult,
          data: LifePlanets.of(planet),
          scores: scores,
          seed: 9,
        );
        expect(sem.hasSituationDomainConsequence, isTrue);
        expect(sem.primary.evidenceKeys, isNotEmpty);
        expect(sem.slotsDuplicate(), isFalse);
        expect(
          LifeMapVerdictCopy.violatesPrimaryBody(sem.primary.situationTh),
          isFalse,
        );
        expect(
          LifeMapVerdictCopy.looksLikeAbstractOnly(sem.primary.situationTh),
          isFalse,
        );
      }
    });

    test('composer past/current/future attach semantics', () {
      PeriodNarrative compose({
        required bool isPast,
        required bool isCurrent,
        required LifePlanet planet,
        required int age,
      }) {
        final period = PeriodState(
          index: 1,
          planet: planet,
          startAge: age - 5,
          endAge: age + 5,
          strength: 10,
          isCurrent: isCurrent,
          isPast: isPast,
          progress: isCurrent ? 0.5 : (isPast ? 1 : 0),
          remainingYears: isCurrent ? 5 : 0,
          previousPlanet: LifePlanet.saturn,
          nextPlanet: LifePlanet.jupiter,
        );
        final scores = PeriodCompositeScore.evaluate(
          period: period,
          lagnaLord: LifePlanet.sun,
          evidence: EvidenceProfile.fromThemeIds(const ['action']),
          seed: 4,
        );
        return PeriodNarrativeComposer.compose(
          period: period,
          narrativeAge: age,
          scores: scores,
          lagnaLord: LifePlanet.sun,
          evidence: EvidenceProfile.fromThemeIds(const ['action']),
          topThemeTags: const ['มั่นคง'],
          seed: 4,
        );
      }

      final past = compose(
        isPast: true,
        isCurrent: false,
        planet: LifePlanet.saturn,
        age: 35,
      );
      final current = compose(
        isPast: false,
        isCurrent: true,
        planet: LifePlanet.mars,
        age: 35,
      );
      final future = compose(
        isPast: false,
        isCurrent: false,
        planet: LifePlanet.jupiter,
        age: 45,
      );

      expect(past.semantics?.tense, LifeMapVerdictTense.past);
      expect(current.semantics?.tense, LifeMapVerdictTense.current);
      expect(future.semantics?.tense, LifeMapVerdictTense.future);
      expect(past.semantics!.primary.situationId, isNotEmpty);
      expect(current.semantics!.primary.domainId, isNotEmpty);
      expect(future.semantics!.primary.consequenceId, isNotEmpty);
      expect(
        past.semantics!.primary.situationId,
        isNot(equals(current.semantics!.primary.situationId)),
      );
    });

    test(
      'swapping only planet name is insufficient — domains differ by affinity',
      () {
        final saturn = LifeMapSemanticMapper.build(
          tense: LifeMapVerdictTense.past,
          band: ThaiLifeStageBand.workingAdult,
          data: LifePlanets.of(LifePlanet.saturn),
          scores: const PeriodScores(
            career: 80,
            money: 70,
            love: 40,
            health: 50,
            growth: 55,
            opportunity: 45,
            pressure: 75,
          ),
          seed: 1,
        );
        final venus = LifeMapSemanticMapper.build(
          tense: LifeMapVerdictTense.past,
          band: ThaiLifeStageBand.workingAdult,
          data: LifePlanets.of(LifePlanet.venus),
          scores: const PeriodScores(
            career: 50,
            money: 70,
            love: 90,
            health: 60,
            growth: 55,
            opportunity: 65,
            pressure: 30,
          ),
          seed: 1,
        );
        expect(saturn.primary.domain, isNot(equals(venus.primary.domain)));
        expect(
          saturn.primary.situationId,
          isNot(equals(venus.primary.situationId)),
        );
      },
    );
  });
}
