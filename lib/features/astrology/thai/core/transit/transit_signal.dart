import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';

/// V15 — the raw relationship between a transiting planet and a target planet.
///
/// It reuses the shared V9 [PlanetRelationshipEngine] (no duplicate scoring) to
/// produce the combined [bond] and signed [score] (−3..+3). Evidence only.
class TransitSignal {
  const TransitSignal({
    required this.transiting,
    required this.target,
    required this.bond,
    required this.score,
  });

  /// Builds the signal by assessing [transiting] against [target].
  factory TransitSignal.between(LifePlanet transiting, LifePlanet target) {
    final a = PlanetRelationshipEngine.assess(transiting, target);
    return TransitSignal(
      transiting: transiting,
      target: target,
      bond: a.bond,
      score: a.score,
    );
  }

  /// The planet currently transiting (e.g. the day-of-week ruler).
  final LifePlanet transiting;

  /// The natal / current-period planet it relates to.
  final LifePlanet target;

  final PlanetBond bond;

  /// Combined signed relationship score (−3..+3).
  final int score;
}
