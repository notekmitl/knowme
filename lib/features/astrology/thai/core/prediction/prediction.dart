import 'prediction_category.dart';
import 'prediction_evidence.dart';
import 'prediction_reason.dart';
import 'prediction_score.dart';
import 'prediction_window.dart';

/// V10 — a single deterministic prediction: one [category] in one [window].
///
/// Evidence only. There is **no copy** anywhere on this object: opportunities,
/// risks and reasons are all structured tags/codes. The strength/confidence
/// pair lives in [score]; the supporting signals live in [evidence]; the three
/// "why" axes are surfaced as [timingReason], [planetReason] and
/// [lifePeriodReason] (also duplicated into [reasons] for easy iteration).
class Prediction {
  const Prediction({
    required this.category,
    required this.window,
    required this.score,
    required this.evidence,
    required this.opportunities,
    required this.risks,
    required this.timingReason,
    required this.planetReason,
    required this.lifePeriodReason,
  });

  final PredictionCategory category;
  final PredictionWindow window;
  final PredictionScore score;

  final List<PredictionEvidence> evidence;
  final List<PredictionOpportunity> opportunities;
  final List<PredictionRisk> risks;

  final PredictionReason timingReason;
  final PredictionReason planetReason;
  final PredictionReason lifePeriodReason;

  int get strength => score.strength;
  int get confidence => score.confidence;

  /// The three required reasons in a fixed order.
  List<PredictionReason> get reasons =>
      [timingReason, planetReason, lifePeriodReason];
}
