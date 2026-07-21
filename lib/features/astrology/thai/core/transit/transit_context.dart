import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// V15 — read-only adapter that gives the transit engine exactly what it needs,
/// **derived from a runtime [ReasoningResponse]** (never by calling a lower
/// engine). It exposes the natal ruler, the current life-period planet and the
/// evaluation date. Evidence only — no copy.
class TransitContext {
  const TransitContext({
    required this.natalRuler,
    required this.currentPlanet,
    required this.asOf,
  });

  /// Builds the context from the runtime output. When [asOf] is null it is
  /// reconstructed deterministically from the birth date and the runtime's
  /// reported current age.
  factory TransitContext.fromResponse(
    ReasoningResponse response, {
    required DateTime birthDate,
    DateTime? asOf,
  }) {
    final effectiveAsOf = asOf ??
        DateTime(
          birthDate.year + response.timeline.currentAge,
          birthDate.month,
          birthDate.day,
        );
    return TransitContext(
      natalRuler: response.timeline.source.natal.birthRuler,
      currentPlanet: response.timeline.currentPlanet,
      asOf: effectiveAsOf,
    );
  }

  final LifePlanet natalRuler;
  final LifePlanet currentPlanet;
  final DateTime asOf;
}
