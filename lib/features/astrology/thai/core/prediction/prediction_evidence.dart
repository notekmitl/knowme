import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';

/// Where a piece of prediction evidence came from. Lets tests and (later)
/// presenters reason about provenance without re-deriving anything.
enum PredictionEvidenceSource {
  /// Category affinity of the governing period's ruling planet.
  categoryAffinity,

  /// Period ruler ↔ natal anchor alignment (V9 natalHarmonyScore).
  natalHarmony,

  /// Period length / strength tier.
  periodStrength,

  /// Where in the window the person stands (stage / proximity).
  timing,

  /// Quality of the transition into the governing period.
  transition,

  /// A neighbouring period's bond (previous / next ruler).
  neighbourBond,

  /// The next period's intrinsic opportunity domains (V9 future preview).
  futureOpportunity,

  /// The next period's intrinsic challenge domains (V9 future preview).
  futureChallenge,
}

/// A single, typed evidence atom. No copy — just the signal and its signed
/// [magnitude] contribution to the prediction strength.
class PredictionEvidence {
  const PredictionEvidence({
    required this.source,
    required this.magnitude,
    this.planet,
    this.domain,
    this.bond,
  });

  final PredictionEvidenceSource source;

  /// Signed contribution to strength (can be negative for strain signals).
  final int magnitude;

  final LifePlanet? planet;
  final LifeDomain? domain;
  final PlanetBond? bond;
}

/// A structured opportunity — a supportive [LifeDomain] the window tends to
/// open, with a 0–100 [magnitude] from intrinsic affinity. No copy.
class PredictionOpportunity {
  const PredictionOpportunity({
    required this.domain,
    required this.magnitude,
    required this.source,
  });

  final LifeDomain domain;
  final int magnitude;
  final PredictionEvidenceSource source;
}

/// A structured risk — a domain (often [LifeDomain.pressure]) the window asks
/// care of, with a 0–100 [magnitude]. No copy.
class PredictionRisk {
  const PredictionRisk({
    required this.domain,
    required this.magnitude,
    required this.source,
  });

  final LifeDomain domain;
  final int magnitude;
  final PredictionEvidenceSource source;
}
