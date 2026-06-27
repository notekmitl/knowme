import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// Coarse outlook band for a scenario at its decisive window.
enum DecisionOutlookBand { favourable, mixed, unfavourable }

/// V11 — the projected outcome of acting on a scenario at its decisive window.
/// Evidence only: a band, a net favourability score and the leading
/// opportunity / risk domains. No copy, no forecast prose.
class DecisionOutcome {
  const DecisionOutcome({
    required this.band,
    required this.favourability,
    this.leadingOpportunity,
    this.leadingRisk,
  });

  final DecisionOutlookBand band;

  /// Net favourability (0–100) at the decisive window.
  final int favourability;

  /// The strongest supportive domain (null when none stands out).
  final LifeDomain? leadingOpportunity;

  /// The most pressing risk domain (null when none stands out).
  final LifeDomain? leadingRisk;

  static DecisionOutlookBand bandFor(int favourability) {
    if (favourability >= 60) return DecisionOutlookBand.favourable;
    if (favourability >= 45) return DecisionOutlookBand.mixed;
    return DecisionOutlookBand.unfavourable;
  }
}
