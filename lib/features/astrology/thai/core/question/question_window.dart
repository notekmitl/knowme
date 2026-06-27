import 'package:knowme/features/astrology/thai/core/decision/decision_window.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_window.dart';

/// Why a window is relevant to a question.
enum QuestionWindowRole {
  /// The window the answer points at.
  focus,

  /// The most favourable available window for the topic.
  best,

  /// The least favourable available window for the topic.
  worst,
}

/// V12 — a window surfaced as relevant to a question. A thin projection of the
/// V11 [DecisionWindow] tagged with the [role] that made it relevant. Evidence
/// only — no copy.
class QuestionWindow {
  const QuestionWindow({
    required this.kind,
    required this.role,
    required this.startAge,
    required this.endAge,
    required this.favourability,
    required this.available,
  });

  factory QuestionWindow.fromDecision(
    DecisionWindow window,
    QuestionWindowRole role,
  ) =>
      QuestionWindow(
        kind: window.kind,
        role: role,
        startAge: window.startAge,
        endAge: window.endAge,
        favourability: window.favourability,
        available: window.available,
      );

  final PredictionWindowKind kind;
  final QuestionWindowRole role;
  final int startAge;
  final int endAge;
  final int favourability;
  final bool available;
}
