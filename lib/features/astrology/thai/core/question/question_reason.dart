import 'package:knowme/features/astrology/thai/core/decision/decision_reason.dart';

/// V12 — a decision reason re-ranked by relevance to a question intent.
///
/// It carries the underlying V11 [DecisionReason] axis ([kind]) and [code]
/// unchanged (codes only — never prose) plus the signed [magnitude] and a
/// [priority] (0 = most relevant to the asked intent). The engine never invents
/// new reasons; it only orders the decision's reasons by what the question asks.
class QuestionReason {
  const QuestionReason({
    required this.kind,
    required this.code,
    required this.magnitude,
    required this.priority,
  });

  factory QuestionReason.fromDecision(DecisionReason reason, int priority) =>
      QuestionReason(
        kind: reason.kind,
        code: reason.code,
        magnitude: reason.magnitude,
        priority: priority,
      );

  final DecisionReasonKind kind;
  final DecisionReasonCode code;
  final int magnitude;

  /// 0-based rank — lower is more relevant to the question intent.
  final int priority;
}
