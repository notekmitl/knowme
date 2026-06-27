import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/period_composite_score.dart';

void main() {
  group('LifePeriodEngine — traditional Thai 8-day cycle', () {
    test('Saturday birth reproduces the canonical sequence and durations', () {
      final t = LifePeriodEngine.build(
        birthWeekday: DateTime.saturday,
        currentAge: 36,
      );

      // Saturn → Jupiter → Rahu → Venus → Sun → Moon → Mars → Mercury.
      expect(t.startPlanet, LifePlanet.saturn);
      expect(t.periods[0].planet, LifePlanet.saturn);
      expect(t.periods[1].planet, LifePlanet.jupiter);
      expect(t.periods[2].planet, LifePlanet.rahu);
      expect(t.periods[3].planet, LifePlanet.venus);
      expect(t.periods[4].planet, LifePlanet.sun);
      expect(t.periods[5].planet, LifePlanet.moon);
      expect(t.periods[6].planet, LifePlanet.mars);
      expect(t.periods[7].planet, LifePlanet.mercury);

      // Strengths → durations: 10, 19, 12, 21, 6, 15, 8, 17.
      expect(t.periods[0].startAge, 1);
      expect(t.periods[0].endAge, 10);
      expect(t.periods[1].startAge, 11);
      expect(t.periods[1].endAge, 29);
      expect(t.periods[2].startAge, 30);
      expect(t.periods[2].endAge, 41);
      expect(t.periods[3].startAge, 42);
      expect(t.periods[3].endAge, 62);
    });

    test('current period, progress, remaining and neighbours at age 36', () {
      final t = LifePeriodEngine.build(
        birthWeekday: DateTime.saturday,
        currentAge: 36,
      );
      final cur = t.current;
      expect(cur.planet, LifePlanet.rahu); // 30–41
      expect(cur.isCurrent, isTrue);
      expect(cur.remainingYears, 41 - 36);
      expect(cur.previousPlanet, LifePlanet.jupiter);
      expect(cur.nextPlanet, LifePlanet.venus);
      expect(cur.progress, greaterThan(0));
      expect(cur.progress, lessThanOrEqualTo(1));
      // past/current/future partition.
      expect(t.periods[1].isPast, isTrue);
      expect(t.periods[3].isFuture, isTrue);
    });

    test('coverage reaches ~120 and every weekday starts at its ruler', () {
      const expected = {
        DateTime.monday: LifePlanet.moon,
        DateTime.tuesday: LifePlanet.mars,
        DateTime.wednesday: LifePlanet.mercury,
        DateTime.thursday: LifePlanet.jupiter,
        DateTime.friday: LifePlanet.venus,
        DateTime.saturday: LifePlanet.saturn,
        DateTime.sunday: LifePlanet.sun,
      };
      expected.forEach((weekday, planet) {
        final t = LifePeriodEngine.build(birthWeekday: weekday, currentAge: 1);
        expect(t.startPlanet, planet);
        expect(t.periods.last.endAge, greaterThanOrEqualTo(120));
        // Ages are contiguous with no gaps.
        for (var i = 1; i < t.periods.length; i++) {
          expect(t.periods[i].startAge, t.periods[i - 1].endAge + 1);
        }
      });
    });

    test('ageFrom computes whole-year age respecting birthday', () {
      final birth = DateTime(1990, 6, 15);
      expect(LifePeriodEngine.ageFrom(birth, asOf: DateTime(2020, 6, 14)), 29);
      expect(LifePeriodEngine.ageFrom(birth, asOf: DateTime(2020, 6, 15)), 30);
      expect(LifePeriodEngine.ageFrom(birth, asOf: DateTime(2020, 12, 1)), 30);
    });

    test('fromBirthDate consumes a canonical birth date end-to-end', () {
      // 1989-04-15 is a Saturday → Saturn start; at 2026-06-26 the person is 37.
      final t = LifePeriodEngine.fromBirthDate(
        DateTime(1989, 4, 15),
        asOf: DateTime(2026, 6, 26),
      );
      expect(t.startPlanet, LifePlanet.saturn);
      expect(t.currentAge, 37);
      expect(t.current.startAge, lessThanOrEqualTo(37));
      expect(t.current.endAge, greaterThanOrEqualTo(37));
    });
  });

  group('PlanetRelationshipMatrix', () {
    test('friend / enemy lookups and net score', () {
      expect(
        PlanetRelationshipMatrix.relation(LifePlanet.sun, LifePlanet.moon),
        PlanetRelation.friend,
      );
      expect(
        PlanetRelationshipMatrix.relation(LifePlanet.saturn, LifePlanet.sun),
        PlanetRelation.enemy,
      );
      expect(
        PlanetRelationshipMatrix.relation(LifePlanet.mercury, LifePlanet.jupiter),
        PlanetRelation.neutral,
      );
      final net = PlanetRelationshipMatrix.netScore(
        LifePlanet.saturn,
        [LifePlanet.venus, LifePlanet.sun], // friend + enemy → 0
      );
      expect(net, 0);
    });
  });

  group('PeriodCompositeScore', () {
    test('produces seven clamped scores influenced by evidence', () {
      final t = LifePeriodEngine.build(
        birthWeekday: DateTime.friday,
        currentAge: 30,
      );
      final evidence = ThaiMirrorEvidenceComposer.profileFor(
        const ['empathetic', 'loyal', 'creative'],
      );
      final scores = PeriodCompositeScore.evaluate(
        period: t.current,
        lagnaLord: LifePlanet.venus,
        evidence: evidence,
        seed: 12345,
      );
      for (final v in [
        scores.career,
        scores.money,
        scores.love,
        scores.health,
        scores.growth,
        scores.opportunity,
        scores.pressure,
      ]) {
        expect(v, inInclusiveRange(0, 100));
      }
      expect(scores.rankedSupport.length, 6);
      expect(scores.easeIndex, inInclusiveRange(0, 100));
    });
  });
}
