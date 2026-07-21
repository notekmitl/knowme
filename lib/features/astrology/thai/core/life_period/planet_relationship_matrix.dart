import 'life_planet.dart';

/// V8 — reusable planetary relationship engine.
///
/// Relationships follow the traditional natural-friendship table used across
/// Thai/Vedic astrology. The table is stored as configuration (never inlined in
/// the UI) so the period engine can evaluate the period planet against any
/// relevant planet (lagna lord, neighbouring periods) and turn the result into
/// evidence: a friendly planet lifts confidence/harmony, an enemy adds friction.
enum PlanetRelation { friend, neutral, enemy }

extension PlanetRelationScore on PlanetRelation {
  /// Signed weight applied to composite scores.
  int get score => switch (this) {
        PlanetRelation.friend => 1,
        PlanetRelation.neutral => 0,
        PlanetRelation.enemy => -1,
      };

  String get labelTh => switch (this) {
        PlanetRelation.friend => 'ส่งเสริมกัน',
        PlanetRelation.neutral => 'เป็นกลาง',
        PlanetRelation.enemy => 'ขัดแย้งกัน',
      };
}

abstract final class PlanetRelationshipMatrix {
  /// Friends per planet. Anything not listed as friend or enemy is neutral.
  static const Map<LifePlanet, Set<LifePlanet>> _friends = {
    LifePlanet.sun: {LifePlanet.moon, LifePlanet.mars, LifePlanet.jupiter},
    LifePlanet.moon: {LifePlanet.sun, LifePlanet.mercury},
    LifePlanet.mars: {LifePlanet.sun, LifePlanet.moon, LifePlanet.jupiter},
    LifePlanet.mercury: {LifePlanet.sun, LifePlanet.venus},
    LifePlanet.jupiter: {LifePlanet.sun, LifePlanet.moon, LifePlanet.mars},
    LifePlanet.venus: {LifePlanet.mercury, LifePlanet.saturn, LifePlanet.rahu},
    LifePlanet.saturn: {LifePlanet.mercury, LifePlanet.venus, LifePlanet.rahu},
    LifePlanet.rahu: {LifePlanet.venus, LifePlanet.saturn, LifePlanet.mercury},
  };

  /// Enemies per planet.
  static const Map<LifePlanet, Set<LifePlanet>> _enemies = {
    LifePlanet.sun: {LifePlanet.venus, LifePlanet.saturn, LifePlanet.rahu},
    LifePlanet.moon: {LifePlanet.rahu},
    LifePlanet.mars: {LifePlanet.mercury},
    LifePlanet.mercury: {LifePlanet.moon},
    LifePlanet.jupiter: {LifePlanet.mercury, LifePlanet.venus},
    LifePlanet.venus: {LifePlanet.sun, LifePlanet.moon},
    LifePlanet.saturn: {LifePlanet.sun, LifePlanet.moon, LifePlanet.mars},
    LifePlanet.rahu: {LifePlanet.sun, LifePlanet.moon, LifePlanet.mars},
  };

  static PlanetRelation relation(LifePlanet from, LifePlanet to) {
    if (from == to) return PlanetRelation.friend;
    if (_friends[from]?.contains(to) ?? false) return PlanetRelation.friend;
    if (_enemies[from]?.contains(to) ?? false) return PlanetRelation.enemy;
    return PlanetRelation.neutral;
  }

  /// Net relationship score of [planet] against a set of [others] (e.g. the
  /// lagna lord plus the previous and next period planets).
  static int netScore(LifePlanet planet, Iterable<LifePlanet> others) {
    var total = 0;
    for (final other in others) {
      total += relation(planet, other).score;
    }
    return total;
  }

  static List<LifePlanet> friendsOf(LifePlanet planet) =>
      _friends[planet]?.toList(growable: false) ?? const [];

  static List<LifePlanet> enemiesOf(LifePlanet planet) =>
      _enemies[planet]?.toList(growable: false) ?? const [];
}
