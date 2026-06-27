import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// V15 — a single transit evidence atom, shaped to merge cleanly with the
/// runtime's `ReasoningEvidence`.
///
/// [sourceName] is a stable code (e.g. `transitDayVsNatal`), never copy.
/// [magnitude] is the signed contribution. Transit only ever *contributes*
/// evidence — it never decides, predicts or answers.
class TransitEvidence {
  const TransitEvidence({
    required this.sourceName,
    required this.magnitude,
    required this.domain,
    required this.planet,
  });

  final String sourceName;
  final int magnitude;
  final LifeDomain domain;
  final LifePlanet planet;
}
