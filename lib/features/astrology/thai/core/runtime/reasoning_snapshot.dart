import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_recommendation.dart';
import 'package:knowme/features/astrology/thai/core/life_period/current_age_analysis.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/life_period/period_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_result.dart';

/// V13 — a stable, summarized view of the V9 timeline layer. Exposes the few
/// fields a consumer needs plus the full [source] for power use; no copy.
class TimelineSnapshot {
  const TimelineSnapshot({
    required this.currentAge,
    required this.currentPlanet,
    required this.strengthTier,
    required this.stage,
    required this.natalHarmonyScore,
    required this.hasNextPeriod,
    required this.source,
  });

  factory TimelineSnapshot.of(LifeTimelineIntelligence intel) {
    final c = intel.currentAge;
    return TimelineSnapshot(
      currentAge: c.currentAge,
      currentPlanet: c.intelligence.planet,
      strengthTier: c.intelligence.strengthTier,
      stage: c.stage,
      natalHarmonyScore: c.intelligence.natalHarmonyScore,
      hasNextPeriod: intel.futurePreview.hasNext,
      source: intel,
    );
  }

  final int currentAge;
  final LifePlanet currentPlanet;
  final PeriodStrengthTier strengthTier;
  final LifePhaseStage stage;
  final int natalHarmonyScore;
  final bool hasNextPeriod;

  /// The full V9 result, for consumers that need everything.
  final LifeTimelineIntelligence source;
}

/// V13 — a stable, summarized view of the V10 prediction layer.
class PredictionSnapshot {
  const PredictionSnapshot({
    required this.top,
    required this.predictionCount,
    required this.windowCount,
    required this.source,
  });

  factory PredictionSnapshot.of(PredictionIntelligence intel) {
    final ranked = intel.ranked;
    return PredictionSnapshot(
      top: ranked.take(3).toList(growable: false),
      predictionCount: intel.predictions.length,
      windowCount: intel.windows.where((w) => w.available).length,
      source: intel,
    );
  }

  /// The strongest predictions (confidence-weighted), at most three.
  final List<Prediction> top;
  final int predictionCount;
  final int windowCount;

  final PredictionIntelligence source;
}

/// V13 — a stable, summarized view of the V11 decision layer. [focus] is the
/// recommendation the request centred on (an explicit scenario, else the most
/// actionable one).
class DecisionSnapshot {
  const DecisionSnapshot({
    required this.focus,
    required this.recommendations,
    required this.source,
  });

  factory DecisionSnapshot.of(
    DecisionIntelligence intel,
    DecisionRecommendation focus,
  ) =>
      DecisionSnapshot(
        focus: focus,
        recommendations: intel.recommendations,
        source: intel,
      );

  final DecisionRecommendation focus;
  final List<DecisionRecommendation> recommendations;

  final DecisionIntelligence source;
}

/// V13 — a stable, summarized view of the V12 question layer.
class QuestionSnapshot {
  const QuestionSnapshot({required this.result});

  final QuestionResult result;

  int get confidence => result.confidence;
}
