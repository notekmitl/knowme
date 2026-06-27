import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// V15 — the time window a transit applies to, with its ruling planet.
///
/// For the current-day transit, [start] and [end] are the same calendar day.
/// Evidence only — date bounds + the day's ruling planet; no copy.
class TransitWindow {
  const TransitWindow({
    required this.start,
    required this.end,
    required this.ruler,
  });

  final DateTime start;
  final DateTime end;

  /// The planet ruling this window (e.g. the day-of-week ruler).
  final LifePlanet ruler;
}
