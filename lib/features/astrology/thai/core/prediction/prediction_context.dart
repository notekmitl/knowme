import 'package:knowme/features/astrology/thai/core/life_period/current_age_analysis.dart';
import 'package:knowme/features/astrology/thai/core/life_period/future_period_preview.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_natal_context.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';

/// V10 — the immutable input the Prediction Intelligence Foundation reasons
/// over. It is a thin, read-only adapter over the V9 [LifeTimelineIntelligence]
/// bundle: it adds nothing, derives nothing user-facing, and never mutates V9.
///
/// Keeping the engine's input behind this context means future consumers
/// (Future Prediction, Transit, Compatibility, AI Conversation) can feed the
/// same shape without depending on V9 internals directly.
class PredictionContext {
  const PredictionContext({required this.intelligence});

  /// Builds a context straight from a V9 intelligence bundle.
  factory PredictionContext.fromIntelligence(
    LifeTimelineIntelligence intelligence,
  ) =>
      PredictionContext(intelligence: intelligence);

  final LifeTimelineIntelligence intelligence;

  // --- Convenience accessors (no derivation, just forwarding) --------------

  LifeNatalContext get natal => intelligence.natal;

  CurrentAgeAnalysis get currentAge => intelligence.currentAge;

  FuturePeriodPreview get futurePreview => intelligence.futurePreview;

  /// The person's whole-year age at evaluation time.
  int get age => intelligence.currentAge.currentAge;

  /// True when birth time (lagna) is available — raises confidence.
  bool get hasLagna => intelligence.natal.hasLagna;

  /// Stable per-person seed for any tie-breaking that must be reproducible.
  /// Derived only from deterministic natal anchors (never wall-clock).
  int get seed {
    final ruler = intelligence.natal.birthRuler.index;
    final lord = (intelligence.natal.lagnaLord?.index ?? 0);
    final start = intelligence.timeline.startPlanet.index;
    return ruler * 31 + lord * 7 + start;
  }

  /// All life domains the engine may reference (stable order).
  static const List<LifeDomain> domains = LifeDomain.values;
}
