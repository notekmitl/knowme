import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// V11 — a structured tradeoff: a [gain] life-domain weighed against a [cost]
/// life-domain the same decision tends to press on. Evidence only — the domains
/// are V9 [LifeDomain] tags with 0–100 magnitudes; no copy.
class DecisionTradeoff {
  const DecisionTradeoff({
    required this.gain,
    required this.gainMagnitude,
    required this.cost,
    required this.costMagnitude,
  });

  /// The supportive domain the decision tends to open up.
  final LifeDomain gain;
  final int gainMagnitude;

  /// The domain the decision tends to ask care of.
  final LifeDomain cost;
  final int costMagnitude;

  /// Net of the tradeoff (gain − cost); positive favours the move.
  int get net => gainMagnitude - costMagnitude;
}
