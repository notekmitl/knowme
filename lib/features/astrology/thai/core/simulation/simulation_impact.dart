import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// Coarse valence band for a simulated magnitude.
enum SimulationImpactBand {
  stronglyPositive,
  positive,
  neutral,
  negative,
  stronglyNegative,
}

/// V14 — a single 0–100 magnitude plus its valence band and (optionally) the
/// life-domain it concerns. Used for an option's expected outcome, its potential
/// opportunity and its potential risk. Evidence only — no copy.
///
/// Construct via [SimulationImpact.favourable] (higher score = better) or
/// [SimulationImpact.risk] (higher magnitude = worse) so the band always reads
/// on a "how good is this" axis.
class SimulationImpact {
  const SimulationImpact._(this.score, this.band, this.domain);

  /// A favourable magnitude (e.g. expected outcome, opportunity): higher = better.
  factory SimulationImpact.favourable(int score, {LifeDomain? domain}) =>
      SimulationImpact._(_clamp(score), _favourableBand(_clamp(score)), domain);

  /// A risk magnitude: higher = worse (band inverts accordingly).
  factory SimulationImpact.risk(int magnitude, {LifeDomain? domain}) =>
      SimulationImpact._(_clamp(magnitude), _riskBand(_clamp(magnitude)), domain);

  /// 0–100 magnitude.
  final int score;
  final SimulationImpactBand band;

  /// The life-domain this impact concerns (null for an overall expected outcome).
  final LifeDomain? domain;

  static int _clamp(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);

  static SimulationImpactBand _favourableBand(int s) {
    if (s >= 65) return SimulationImpactBand.stronglyPositive;
    if (s >= 55) return SimulationImpactBand.positive;
    if (s >= 45) return SimulationImpactBand.neutral;
    if (s >= 35) return SimulationImpactBand.negative;
    return SimulationImpactBand.stronglyNegative;
  }

  static SimulationImpactBand _riskBand(int m) {
    if (m >= 65) return SimulationImpactBand.stronglyNegative;
    if (m >= 55) return SimulationImpactBand.negative;
    if (m >= 45) return SimulationImpactBand.neutral;
    if (m >= 35) return SimulationImpactBand.positive;
    return SimulationImpactBand.stronglyPositive;
  }
}
