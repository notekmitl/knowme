import 'package:knowme/features/astrology/thai/core/prediction/prediction_window.dart';

/// V11 — a scenario's timing assessment for one prediction horizon. Evidence
/// only. Carries the same age bounds as the underlying [PredictionWindow] plus
/// the scenario-specific [favourability] (net of risk) used to pick best/worst
/// timing.
class DecisionWindow {
  const DecisionWindow({
    required this.kind,
    required this.startAge,
    required this.endAge,
    required this.favourability,
    required this.risk,
    required this.confidence,
    required this.available,
  });

  /// An unavailable window (e.g. no next life period in the final period).
  const DecisionWindow.unavailable(this.kind)
      : startAge = 0,
        endAge = 0,
        favourability = 0,
        risk = 0,
        confidence = 0,
        available = false;

  final PredictionWindowKind kind;
  final int startAge;
  final int endAge;

  /// Net favourability (0–100): weighted strength minus weighted risk.
  final int favourability;

  /// Weighted top-risk magnitude (0–100) for the scenario in this window.
  final int risk;

  /// Weighted prediction confidence (0–100) for the scenario in this window.
  final int confidence;

  final bool available;
}
