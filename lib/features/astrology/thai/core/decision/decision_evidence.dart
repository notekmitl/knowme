import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_category.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_window.dart';

/// Where a piece of decision evidence came from. Every recommendation must be
/// traceable to these sources (the six required evidence inputs):
/// Prediction Intelligence, Timeline Intelligence, Current Age, Future Window,
/// Planet Relationship, Natal Context.
enum DecisionEvidenceSource {
  /// Weighted prediction strength over the scenario's categories (V10).
  predictionStrength,

  /// Weighted top-risk magnitude over the scenario's categories (V10).
  predictionRisk,

  /// Weighted prediction confidence over the scenario's categories (V10).
  predictionConfidence,

  /// Governing period strength tier (V9 Timeline Intelligence).
  timelineStrength,

  /// Where the person stands inside the current period (V9 Current Age).
  currentStage,

  /// How the best future window compares to acting now (V9 Future Window).
  futureOutlook,

  /// Governing period ruler ↔ natal anchor bond (V9 Planet Relationship).
  planetRelationship,

  /// Net natal alignment of the governing period (V9 Natal Context).
  natalAlignment,
}

/// A single, typed decision-evidence atom. No copy — just the signal and its
/// signed [magnitude] (positive argues for acting, negative argues against).
/// The optional fields let a consumer trace the atom back to its origin without
/// re-deriving anything.
class DecisionEvidence {
  const DecisionEvidence({
    required this.source,
    required this.magnitude,
    this.window,
    this.category,
    this.domain,
    this.planet,
    this.bond,
  });

  final DecisionEvidenceSource source;

  /// Signed contribution to the decision (− = conflicting, + = supporting).
  final int magnitude;

  final PredictionWindowKind? window;
  final PredictionCategory? category;
  final LifeDomain? domain;
  final LifePlanet? planet;
  final PlanetBond? bond;

  bool get isSupporting => magnitude > 0;
  bool get isConflicting => magnitude < 0;
}
