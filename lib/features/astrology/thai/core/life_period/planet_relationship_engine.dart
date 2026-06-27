import 'life_planet.dart';
import 'planet_element.dart';
import 'planet_relationship_matrix.dart';

/// V9 — combined planetary relationship.
///
/// The traditional natural-friendship table ([PlanetRelationshipMatrix], V8)
/// answers *friend / neutral / enemy*. V9 adds the element axis
/// ([PlanetElements]) and folds the two into a single human-meaningful bond:
/// *support → harmony → neutral → friction → conflict*.
///
/// "Friend/Enemy" is the natural relation; "Support/Conflict" is the combined
/// bond; "Element relationship" is the element relation. All five concepts the
/// timeline needs come from one assessment.
enum PlanetBond { support, harmony, neutral, friction, conflict }

extension PlanetBondInfo on PlanetBond {
  /// Signed direction (+ helps, − strains, 0 mixed/neutral). Useful for
  /// presentation scoring without re-deriving the bond.
  int get direction => switch (this) {
        PlanetBond.support => 2,
        PlanetBond.harmony => 1,
        PlanetBond.neutral => 0,
        PlanetBond.friction => -1,
        PlanetBond.conflict => -2,
      };

  bool get isPositive => direction > 0;
  bool get isNegative => direction < 0;

  String get labelTh => switch (this) {
        PlanetBond.support => 'ส่งเสริมกันชัดเจน',
        PlanetBond.harmony => 'เข้ากันได้ดี',
        PlanetBond.neutral => 'เป็นกลาง',
        PlanetBond.friction => 'มีแรงเสียดทาน',
        PlanetBond.conflict => 'ขัดแย้งกันชัดเจน',
      };
}

/// A full, deterministic relationship assessment between two planets.
class PlanetRelationshipAssessment {
  const PlanetRelationshipAssessment({
    required this.from,
    required this.to,
    required this.natural,
    required this.element,
    required this.bond,
    required this.score,
  });

  final LifePlanet from;
  final LifePlanet to;

  /// Natural friend / neutral / enemy (V8 table).
  final PlanetRelation natural;

  /// Element supporting / neutral / conflicting.
  final ElementRelation element;

  /// Combined human bond.
  final PlanetBond bond;

  /// Combined signed score (natural*2 + element), range −3..+3.
  final int score;

  bool get isSupportive => bond.isPositive;
  bool get isConflicting => bond.isNegative;
}

abstract final class PlanetRelationshipEngine {
  /// Assess [from] against [to], combining natural + element relationships.
  ///
  /// Scoring: natural contributes ±2 (friend/enemy), element contributes ±1.
  /// The summed score maps to a [PlanetBond]:
  ///   ≥ 2 → support · 1 → harmony · 0 → neutral · −1 → friction · ≤ −2 → conflict
  static PlanetRelationshipAssessment assess(LifePlanet from, LifePlanet to) {
    final natural = PlanetRelationshipMatrix.relation(from, to);
    final element = PlanetElements.relation(from, to);
    final score = natural.score * 2 + element.score;
    return PlanetRelationshipAssessment(
      from: from,
      to: to,
      natural: natural,
      element: element,
      bond: _bondForScore(score),
      score: score,
    );
  }

  static PlanetBond _bondForScore(int score) {
    if (score >= 2) return PlanetBond.support;
    if (score == 1) return PlanetBond.harmony;
    if (score == 0) return PlanetBond.neutral;
    if (score == -1) return PlanetBond.friction;
    return PlanetBond.conflict;
  }

  /// Net combined score of [planet] against several [others]. Mirrors
  /// [PlanetRelationshipMatrix.netScore] but on the richer combined scale.
  static int netScore(LifePlanet planet, Iterable<LifePlanet> others) {
    var total = 0;
    for (final other in others) {
      total += assess(planet, other).score;
    }
    return total;
  }

  /// The strongest supportive planet for [planet] among [candidates] (highest
  /// score), or null if none is net-positive.
  static LifePlanet? strongestAlly(
    LifePlanet planet,
    Iterable<LifePlanet> candidates,
  ) {
    LifePlanet? best;
    var bestScore = 0;
    for (final c in candidates) {
      if (c == planet) continue;
      final s = assess(planet, c).score;
      if (s > bestScore) {
        bestScore = s;
        best = c;
      }
    }
    return best;
  }

  /// The strongest opposing planet for [planet] among [candidates] (lowest
  /// score), or null if none is net-negative.
  static LifePlanet? strongestRival(
    LifePlanet planet,
    Iterable<LifePlanet> candidates,
  ) {
    LifePlanet? worst;
    var worstScore = 0;
    for (final c in candidates) {
      if (c == planet) continue;
      final s = assess(planet, c).score;
      if (s < worstScore) {
        worstScore = s;
        worst = c;
      }
    }
    return worst;
  }
}
