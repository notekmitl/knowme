import 'package:knowme/features/astrology/thai/core/decision/decision_action.dart';
import 'package:knowme/features/astrology/thai/core/question/question_answer.dart';
import 'package:knowme/features/astrology/thai/core/question/question_result.dart';
import 'package:knowme/features/runtime/fusion/fusion_observation.dart';
import 'package:knowme/features/runtime/fusion/fusion_result.dart';
import 'package:knowme/features/runtime/reasoning_response.dart';

import 'conversation_question.dart';

/// V16 — the answer to a conversation question.
///
/// Since P2 the conversation consumes the **Fusion Runtime**, so [fusion] is the
/// unified cross-system result and [primary] is the answering provider's
/// observation (Thai today). For `question` API calls the V12 [questionResult] is
/// extracted from the primary observation's native Thai payload so a presenter
/// can render stance/evidence later. Evidence only — no rendered prose.
class ConversationAnswer {
  const ConversationAnswer({
    required this.questionId,
    required this.api,
    required this.fusion,
    required this.primary,
    required this.questionResult,
  });

  final String questionId;
  final ConversationRuntimeApi api;

  /// The unified cross-system fusion result that produced this answer.
  final FusionResult fusion;

  /// The provider observation the conversation reads from (Thai today).
  final FusionObservation primary;

  /// The V12 question result (only for `question` API calls; null otherwise).
  final QuestionResult? questionResult;

  /// The primary provider's system-agnostic response.
  ReasoningResponse get response => primary.response;

  /// The fused confidence (equals the provider's in single-provider mode).
  int get confidence => fusion.confidence.value;

  /// The structured stance (only for `question` API calls).
  QuestionStance? get stance => questionResult?.answer.stance;

  /// The underlying decision verdict (only for `question` API calls).
  DecisionAction? get action => questionResult?.answer.action;
}
