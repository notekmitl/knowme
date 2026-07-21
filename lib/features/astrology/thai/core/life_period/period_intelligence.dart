import 'life_natal_context.dart';
import 'life_period_engine.dart';
import 'life_planet.dart';
import 'planet_element.dart';
import 'planet_relationship_engine.dart';

/// How long/heavy a period's ruling planet runs, derived from its strength
/// (the number of years the period lasts: 6–21).
enum PeriodStrengthTier { brief, moderate, strong, dominant }

extension PeriodStrengthTierInfo on PeriodStrengthTier {
  String get labelTh => switch (this) {
        PeriodStrengthTier.brief => 'ช่วงสั้น',
        PeriodStrengthTier.moderate => 'ช่วงปานกลาง',
        PeriodStrengthTier.strong => 'ช่วงยาวและเข้มข้น',
        PeriodStrengthTier.dominant => 'ช่วงยาวที่สุดของชีวิต',
      };
}

/// One influencing planet and how it relates to the period ruler — used to
/// surface "current dominant influences" without any narrative copy.
class PeriodInfluence {
  const PeriodInfluence({
    required this.planet,
    required this.role,
    required this.assessment,
  });

  final LifePlanet planet;

  /// Why this planet is in the picture (natal anchor, neighbour transition…).
  final InfluenceRole role;

  final PlanetRelationshipAssessment assessment;
}

enum InfluenceRole { birthRuler, lagnaLord, previousPeriod, nextPeriod, self }

/// V9 — structured intelligence for a single life period. Evidence only: no
/// 0–100 domain scoring (that remains in the presentation composite scorer) and
/// no prose. It answers *what kind of period this is and how it interacts with
/// who the person is*.
class PeriodIntelligence {
  const PeriodIntelligence({
    required this.index,
    required this.planet,
    required this.element,
    required this.strengthTier,
    required this.natalRulerBond,
    required this.lagnaLordBond,
    required this.previousBond,
    required this.nextBond,
    required this.natalHarmonyScore,
    required this.influences,
  });

  final int index;
  final LifePlanet planet;
  final ThaiElement element;
  final PeriodStrengthTier strengthTier;

  /// Period ruler vs the birth (weekday) ruler.
  final PlanetRelationshipAssessment natalRulerBond;

  /// Period ruler vs the lagna lord (null when birth time is unknown).
  final PlanetRelationshipAssessment? lagnaLordBond;

  /// Period ruler vs the previous / next period ruler (null at the ends).
  final PlanetRelationshipAssessment? previousBond;
  final PlanetRelationshipAssessment? nextBond;

  /// Net alignment of this period with the natal anchors (birth ruler + lagna
  /// lord). Positive → the period plays to who the person is; negative → the
  /// period challenges them.
  final int natalHarmonyScore;

  /// Influencing planets ordered strongest-magnitude first (for "dominant
  /// influences").
  final List<PeriodInfluence> influences;

  bool get isNatalHarmonious => natalHarmonyScore > 0;
  bool get isNatalChallenging => natalHarmonyScore < 0;
}

/// V9 — builds [PeriodIntelligence] for periods. Pure, deterministic, evidence
/// only.
abstract final class PeriodIntelligenceEngine {
  static PeriodStrengthTier tierForStrength(int strength) {
    if (strength <= 8) return PeriodStrengthTier.brief;
    if (strength <= 15) return PeriodStrengthTier.moderate;
    if (strength <= 19) return PeriodStrengthTier.strong;
    return PeriodStrengthTier.dominant;
  }

  static PeriodIntelligence evaluate({
    required PeriodState period,
    required LifeNatalContext natal,
  }) {
    final planet = period.planet;
    final natalRulerBond = PlanetRelationshipEngine.assess(
      planet,
      natal.birthRuler,
    );
    final lagnaLordBond = natal.lagnaLord == null
        ? null
        : PlanetRelationshipEngine.assess(planet, natal.lagnaLord!);
    final previousBond = period.previousPlanet == null
        ? null
        : PlanetRelationshipEngine.assess(planet, period.previousPlanet!);
    final nextBond = period.nextPlanet == null
        ? null
        : PlanetRelationshipEngine.assess(planet, period.nextPlanet!);

    var harmony = natalRulerBond.score;
    if (lagnaLordBond != null) harmony += lagnaLordBond.score;

    final influences = <PeriodInfluence>[
      PeriodInfluence(
        planet: natal.birthRuler,
        role: InfluenceRole.birthRuler,
        assessment: natalRulerBond,
      ),
      if (lagnaLordBond != null)
        PeriodInfluence(
          planet: natal.lagnaLord!,
          role: InfluenceRole.lagnaLord,
          assessment: lagnaLordBond,
        ),
      if (previousBond != null)
        PeriodInfluence(
          planet: period.previousPlanet!,
          role: InfluenceRole.previousPeriod,
          assessment: previousBond,
        ),
      if (nextBond != null)
        PeriodInfluence(
          planet: period.nextPlanet!,
          role: InfluenceRole.nextPeriod,
          assessment: nextBond,
        ),
    ]..sort(
        (a, b) => b.assessment.score.abs().compareTo(a.assessment.score.abs()),
      );

    return PeriodIntelligence(
      index: period.index,
      planet: planet,
      element: PlanetElements.of(planet),
      strengthTier: tierForStrength(period.strength),
      natalRulerBond: natalRulerBond,
      lagnaLordBond: lagnaLordBond,
      previousBond: previousBond,
      nextBond: nextBond,
      natalHarmonyScore: harmony,
      influences: influences,
    );
  }
}
