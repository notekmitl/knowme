import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';

import '../copy/thai_mirror_evidence_composer.dart';

/// Seven composite life scores for a single period (0–100).
class PeriodScores {
  const PeriodScores({
    required this.career,
    required this.money,
    required this.love,
    required this.health,
    required this.growth,
    required this.opportunity,
    required this.pressure,
  });

  final int career;
  final int money;
  final int love;
  final int health;
  final int growth;
  final int opportunity;
  final int pressure;

  /// Domains ordered strongest → weakest (pressure excluded; it is friction).
  List<MapEntry<String, int>> get rankedSupport {
    final entries = <MapEntry<String, int>>[
      MapEntry('career', career),
      MapEntry('money', money),
      MapEntry('love', love),
      MapEntry('health', health),
      MapEntry('growth', growth),
      MapEntry('opportunity', opportunity),
    ]..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String get topDomain => rankedSupport.first.key;
  String get weakestDomain => rankedSupport.last.key;

  /// Average of the supportive domains — an "ease" reading for the period.
  int get easeIndex =>
      ((career + money + love + health + growth + opportunity) / 6).round();
}

/// V8 — Composite Period Score engine.
///
/// Combines, with no duplicated logic elsewhere:
///   • planet intrinsic domain affinity
///   • planet strength (longer/stronger period → more active)
///   • relationship between the period planet and the lagna lord + neighbours
///   • the person's existing evidence (dominant facet bias)
///   • deterministic seeded nuance
abstract final class PeriodCompositeScore {
  static PeriodScores evaluate({
    required PeriodState period,
    required LifePlanet? lagnaLord,
    required EvidenceProfile evidence,
    required int seed,
  }) {
    final affinity = LifePlanets.of(period.planet).affinity;

    // Strength bias: map 6–21 → roughly -6..+9 of "activity".
    final strengthBias = (((period.strength - 6) / 15.0) * 14 - 4).round();

    // Relationship to the lagna lord plus the neighbouring period planets.
    final relatives = <LifePlanet>[
      ?lagnaLord,
      ?period.previousPlanet,
      ?period.nextPlanet,
    ];
    final net = relatives.isEmpty
        ? 0
        : PlanetRelationshipMatrix.netScore(period.planet, relatives);
    // Scale net (-3..3-ish) into a confidence delta.
    final confidence = (net * 5).clamp(-15, 15);

    // Evidence bias: the person's dominant facet nudges its home domains.
    final facetBias = _facetBias(evidence.primary);
    final secondBias = _facetBias(evidence.secondary);

    int s(int base, String domain, {bool friction = false}) {
      var v = base + strengthBias;
      if (friction) {
        // Enemies raise pressure; friends ease it.
        v -= confidence;
      } else {
        v += confidence;
      }
      v += (facetBias[domain] ?? 0);
      v += ((secondBias[domain] ?? 0) * 0.5).round();
      v += _nuance(seed, domain);
      return v.clamp(2, 99);
    }

    return PeriodScores(
      career: s(affinity.career, 'career'),
      money: s(affinity.money, 'money'),
      love: s(affinity.love, 'love'),
      health: s(affinity.health, 'health'),
      growth: s(affinity.growth, 'growth'),
      opportunity: s(affinity.opportunity, 'opportunity'),
      pressure: s(affinity.pressure, 'pressure', friction: true),
    );
  }

  static Map<String, int> _facetBias(ReportFacet facet) {
    switch (facet) {
      case ReportFacet.thinking:
        return {'growth': 8, 'career': 4, 'money': 3};
      case ReportFacet.action:
        return {'career': 8, 'opportunity': 6, 'health': 3};
      case ReportFacet.structure:
        return {'career': 6, 'money': 7, 'health': 3};
      case ReportFacet.people:
        return {'love': 9, 'health': 4, 'opportunity': 3};
      case ReportFacet.independent:
        return {'career': 5, 'growth': 5, 'money': 4};
      case ReportFacet.leadership:
        return {'career': 8, 'opportunity': 6, 'money': 4};
      case ReportFacet.novelty:
        return {'opportunity': 8, 'growth': 6, 'career': 3};
      case ReportFacet.emotion:
        return {'love': 8, 'health': 7};
      case ReportFacet.drive:
        return {'career': 7, 'opportunity': 6, 'money': 4};
      case ReportFacet.caution:
        return {'money': 7, 'health': 5, 'growth': 3};
    }
  }

  static int _nuance(int seed, String domain) {
    final h = (seed ^ (domain.hashCode * 2654435761)).abs();
    return (h % 7) - 3; // -3..+3
  }
}
