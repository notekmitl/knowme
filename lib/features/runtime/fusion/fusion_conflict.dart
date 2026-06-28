import '../reasoning_module.dart';

/// P2 — a domain where providers disagree in direction.
///
/// [positiveModules] point favourable, [negativeModules] point cautionary, and
/// [spread] is the distance between the strongest opposing net contributions —
/// a measure of how sharp the disagreement is.
class FusionConflict {
  const FusionConflict({
    required this.domain,
    required this.positiveModules,
    required this.negativeModules,
    required this.spread,
  });

  final String domain;
  final List<ReasoningModule> positiveModules;
  final List<ReasoningModule> negativeModules;
  final int spread;
}
