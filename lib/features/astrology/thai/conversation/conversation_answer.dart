import 'package:knowme/features/astrology/thai/core/decision/decision_action.dart';
import 'package:knowme/features/astrology/thai/core/question/question_answer.dart';
import 'package:knowme/features/astrology/thai/core/question/question_result.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart';

import 'conversation_question.dart';

/// V16 — the answer to a conversation question.
///
/// It is a thin, structured wrapper over the runtime output (evidence only — no
/// rendered prose). For `question` API calls it also exposes the V12
/// [QuestionResult] so a presenter can render stance/evidence later.
class ConversationAnswer {
  const ConversationAnswer({
    required this.questionId,
    required this.api,
    required this.response,
    required this.questionResult,
  });

  final String questionId;
  final ConversationRuntimeApi api;

  /// The untouched runtime response that produced this answer.
  final ReasoningResponse response;

  /// The V12 question result (only for `question` API calls; null otherwise).
  final QuestionResult? questionResult;

  int get confidence => response.confidence;

  /// The structured stance (only for `question` API calls).
  QuestionStance? get stance => questionResult?.answer.stance;

  /// The underlying decision verdict (only for `question` API calls).
  DecisionAction? get action => questionResult?.answer.action;
}
