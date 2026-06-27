import 'package:knowme/features/astrology/thai/core/prediction/prediction_window.dart';

/// V12 — an optional, structured constraint a caller can attach to a question.
/// Evidence only — no copy, no parsing. The engine honours these deterministically.
class QuestionConstraint {
  const QuestionConstraint({this.horizon, this.minConfidence});

  /// No constraint.
  static const QuestionConstraint none = QuestionConstraint();

  /// Focus the answer on a specific horizon when set (the engine prefers the
  /// best/worst timing window that matches it).
  final PredictionWindowKind? horizon;

  /// A minimum acceptable confidence; the result reports whether it is met. The
  /// engine never silently rewrites the verdict — it only flags the threshold.
  final int? minConfidence;

  bool get isEmpty => horizon == null && minConfidence == null;
}
