import 'package:knowme/features/astrology/thai/core/life_period/current_age_analysis.dart';
import 'package:knowme/features/astrology/thai/core/life_period/future_period_preview.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_natal_context.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';

/// V11 — the immutable input the Decision Intelligence layer reasons over.
///
/// A thin, read-only adapter over the V10 [PredictionIntelligence] result (which
/// itself wraps the V9 [LifeTimelineIntelligence] bundle). It adds nothing and
/// derives nothing user-facing — keeping the decision engine's input behind this
/// context lets future consumers (Transit, Compatibility, AI Conversation,
/// Future Chat) feed the same shape without depending on V10 internals.
class DecisionContext {
  const DecisionContext({required this.prediction});

  /// Builds a context straight from a V10 prediction result.
  factory DecisionContext.fromPrediction(PredictionIntelligence prediction) =>
      DecisionContext(prediction: prediction);

  final PredictionIntelligence prediction;

  // --- Convenience accessors (no derivation, just forwarding) --------------

  LifeTimelineIntelligence get intelligence =>
      prediction.context.intelligence;

  LifeNatalContext get natal => intelligence.natal;

  CurrentAgeAnalysis get currentAge => intelligence.currentAge;

  FuturePeriodPreview get futurePreview => intelligence.futurePreview;

  /// The person's whole-year age at evaluation time.
  int get age => intelligence.currentAge.currentAge;

  /// True when birth time (lagna) is available — raises confidence.
  bool get hasLagna => intelligence.natal.hasLagna;

  /// Stable per-person seed for any reproducible tie-breaking. Derived only
  /// from deterministic natal anchors (never wall-clock).
  int get seed => prediction.context.seed;
}
