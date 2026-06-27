import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/current_age_analysis.dart';
import 'package:knowme/features/astrology/thai/core/life_period/future_period_preview.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_natal_context.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/life_period/period_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_element.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';

void main() {
  group('PlanetElements — element model', () {
    test('every planet has an element', () {
      for (final p in LifePlanet.values) {
        expect(() => PlanetElements.of(p), returnsNormally);
      }
    });

    test('element relation is symmetric and matches the model', () {
      // same element → supporting
      expect(
        PlanetElements.relation(LifePlanet.sun, LifePlanet.mars),
        ElementRelation.supporting,
      );
      // fire (sun) ↔ air (saturn) → supporting
      expect(
        PlanetElements.relation(LifePlanet.sun, LifePlanet.saturn),
        ElementRelation.supporting,
      );
      // fire (sun) ↔ water (moon) → conflicting
      expect(
        PlanetElements.relation(LifePlanet.sun, LifePlanet.moon),
        ElementRelation.conflicting,
      );
      // earth (mercury) ↔ air (jupiter) → conflicting
      expect(
        PlanetElements.relation(LifePlanet.mercury, LifePlanet.jupiter),
        ElementRelation.conflicting,
      );
      // earth (mercury) ↔ water (venus) → supporting
      expect(
        PlanetElements.relation(LifePlanet.mercury, LifePlanet.venus),
        ElementRelation.supporting,
      );
      // symmetry
      for (final a in LifePlanet.values) {
        for (final b in LifePlanet.values) {
          expect(
            PlanetElements.relation(a, b),
            PlanetElements.relation(b, a),
            reason: 'element relation must be symmetric ($a,$b)',
          );
        }
      }
    });
  });

  group('PlanetRelationshipEngine — combined bond', () {
    test('combines natural + element into a signed score and bond', () {
      // Sun↔Moon: natural friend (+2) but element conflicting (−1) → +1 harmony.
      final sunMoon = PlanetRelationshipEngine.assess(
        LifePlanet.sun,
        LifePlanet.moon,
      );
      expect(sunMoon.natural, PlanetRelation.friend);
      expect(sunMoon.element, ElementRelation.conflicting);
      expect(sunMoon.score, 1);
      expect(sunMoon.bond, PlanetBond.harmony);

      // Saturn↔Sun: natural enemy (−2), element supporting (+1) → −1 friction.
      final saturnSun = PlanetRelationshipEngine.assess(
        LifePlanet.saturn,
        LifePlanet.sun,
      );
      expect(saturnSun.natural, PlanetRelation.enemy);
      expect(saturnSun.score, -1);
      expect(saturnSun.bond, PlanetBond.friction);
    });

    test('score stays within −3..+3 for all planet pairs', () {
      for (final a in LifePlanet.values) {
        for (final b in LifePlanet.values) {
          final s = PlanetRelationshipEngine.assess(a, b).score;
          expect(s, inInclusiveRange(-3, 3));
        }
      }
    });

    test('strongestAlly / strongestRival pick the extreme scores', () {
      final candidates = LifePlanet.values;
      final ally = PlanetRelationshipEngine.strongestAlly(
        LifePlanet.sun,
        candidates,
      );
      final rival = PlanetRelationshipEngine.strongestRival(
        LifePlanet.sun,
        candidates,
      );
      if (ally != null) {
        expect(
          PlanetRelationshipEngine.assess(LifePlanet.sun, ally).score,
          greaterThan(0),
        );
      }
      if (rival != null) {
        expect(
          PlanetRelationshipEngine.assess(LifePlanet.sun, rival).score,
          lessThan(0),
        );
      }
    });
  });

  group('PeriodIntelligenceEngine', () {
    test('strength tiers map from planet strength', () {
      expect(
        PeriodIntelligenceEngine.tierForStrength(6),
        PeriodStrengthTier.brief,
      );
      expect(
        PeriodIntelligenceEngine.tierForStrength(15),
        PeriodStrengthTier.moderate,
      );
      expect(
        PeriodIntelligenceEngine.tierForStrength(19),
        PeriodStrengthTier.strong,
      );
      expect(
        PeriodIntelligenceEngine.tierForStrength(21),
        PeriodStrengthTier.dominant,
      );
    });

    test('produces per-period intelligence aligned to the timeline', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.friday,
        currentAge: 30,
      );
      const natal = LifeNatalContext(
        birthRuler: LifePlanet.venus,
        lagnaLord: LifePlanet.saturn,
      );
      for (final p in timeline.periods) {
        final intel = PeriodIntelligenceEngine.evaluate(
          period: p,
          natal: natal,
        );
        expect(intel.index, p.index);
        expect(intel.planet, p.planet);
        expect(intel.natalRulerBond.to, LifePlanet.venus);
        expect(intel.lagnaLordBond?.to, LifePlanet.saturn);
        // influences are ordered by descending magnitude.
        for (var i = 1; i < intel.influences.length; i++) {
          expect(
            intel.influences[i - 1].assessment.score.abs(),
            greaterThanOrEqualTo(intel.influences[i].assessment.score.abs()),
          );
        }
      }
    });

    test('lagna lord bond is absent when birth time unknown', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.monday,
        currentAge: 20,
      );
      const natal = LifeNatalContext(birthRuler: LifePlanet.moon);
      final intel = PeriodIntelligenceEngine.evaluate(
        period: timeline.current,
        natal: natal,
      );
      expect(intel.lagnaLordBond, isNull);
      expect(intel.natalHarmonyScore, intel.natalRulerBond.score);
    });
  });

  group('CurrentAgeAnalysisEngine', () {
    test('stage maps from progress', () {
      expect(
        CurrentAgeAnalysisEngine.stageForProgress(0.1),
        LifePhaseStage.opening,
      );
      expect(
        CurrentAgeAnalysisEngine.stageForProgress(0.5),
        LifePhaseStage.peak,
      );
      expect(
        CurrentAgeAnalysisEngine.stageForProgress(0.9),
        LifePhaseStage.closing,
      );
    });

    test('flags an approaching transition near the period end', () {
      // Saturday birth: Saturn 1–10. At age 9 → closing stage, 1 year remaining.
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.saturday,
        currentAge: 9,
      );
      const natal = LifeNatalContext(birthRuler: LifePlanet.saturn);
      final analysis = CurrentAgeAnalysisEngine.evaluate(
        timeline: timeline,
        natal: natal,
      );
      expect(analysis.stage, LifePhaseStage.closing);
      expect(analysis.transitionApproaching, isTrue);
      expect(
        analysis.factors,
        contains(CurrentAgeFactor.transitionApproaching),
      );
      // dominant influences never include the next-period planet.
      expect(
        analysis.dominantInfluences
            .every((i) => i.role != InfluenceRole.nextPeriod),
        isTrue,
      );
    });
  });

  group('FuturePeriodPreviewEngine', () {
    test('previews the next period with transition + domains', () {
      // Saturday birth, age 5 → current Saturn (1–10), next Jupiter (11–29).
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.saturday,
        currentAge: 5,
      );
      const natal = LifeNatalContext(birthRuler: LifePlanet.saturn);
      final preview = FuturePeriodPreviewEngine.evaluate(
        timeline: timeline,
        natal: natal,
      );
      expect(preview.hasNext, isTrue);
      expect(preview.nextPeriod?.planet, LifePlanet.jupiter);
      expect(preview.yearsUntil, 10 - 5);
      expect(preview.transition, isNotNull);
      expect(preview.elementShift, isNotNull);
      expect(preview.opportunities, isNotEmpty);
      expect(preview.challenges, isNotEmpty);
      // opportunities are the next planet's strongest domains; challenges its
      // weakest — they must not overlap.
      expect(
        preview.opportunities.toSet().intersection(preview.challenges.toSet()),
        isEmpty,
      );
    });

    test('returns none at the final period', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.saturday,
        currentAge: 130,
      );
      const natal = LifeNatalContext(birthRuler: LifePlanet.saturn);
      final preview = FuturePeriodPreviewEngine.evaluate(
        timeline: timeline,
        natal: natal,
      );
      expect(preview.hasNext, isFalse);
      expect(preview.nextPeriod, isNull);
    });
  });

  group('LifeTimelineIntelligenceEngine — aggregator', () {
    test('bundles timeline + per-period + current + future, deterministically',
        () {
      final birth = DateTime(1989, 4, 15); // Saturday
      final asOf = DateTime(2026, 6, 26);
      final a = LifeTimelineIntelligenceEngine.fromBirthDate(
        birth,
        lagnaLord: LifePlanet.mercury,
        asOf: asOf,
      );
      final b = LifeTimelineIntelligenceEngine.fromBirthDate(
        birth,
        lagnaLord: LifePlanet.mercury,
        asOf: asOf,
      );

      // One intelligence per period, same indexing as the timeline.
      expect(a.periodIntelligence.length, a.timeline.periods.length);
      expect(
        a.currentIntelligence.index,
        a.timeline.currentIndex,
      );
      expect(a.natal.birthRuler, LifePlanet.saturn);
      expect(a.natal.lagnaLord, LifePlanet.mercury);

      // Determinism: identical inputs → identical structure.
      expect(a.currentAge.currentAge, b.currentAge.currentAge);
      expect(a.currentAge.stage, b.currentAge.stage);
      expect(a.currentAge.factors, b.currentAge.factors);
      expect(
        a.futurePreview.nextPeriod?.planet,
        b.futurePreview.nextPeriod?.planet,
      );
      expect(a.futurePreview.opportunities, b.futurePreview.opportunities);
    });

    test('fromTimeline reuses an externally computed timeline', () {
      final timeline = LifePeriodEngine.fromBirthDate(
        DateTime(1990, 6, 15),
        asOf: DateTime(2026, 6, 26),
      );
      final intel = LifeTimelineIntelligenceEngine.fromTimeline(
        timeline,
        lagnaLord: LifePlanet.jupiter,
      );
      expect(intel.timeline, same(timeline));
      expect(intel.natal.birthRuler, timeline.startPlanet);
    });
  });
}
