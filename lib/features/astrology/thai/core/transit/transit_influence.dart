import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'transit_event.dart';

/// V15 — the directional effect of a [TransitEvent] on one life [domain].
///
/// [magnitude] is signed: positive nudges the domain up, negative strains it.
/// Evidence only — a structured contribution, never copy or a decision.
class TransitInfluence {
  const TransitInfluence({
    required this.source,
    required this.domain,
    required this.magnitude,
  });

  final TransitEventKind source;
  final LifeDomain domain;

  /// Signed contribution (negative = strain).
  final int magnitude;
}
