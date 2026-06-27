import 'package:knowme/features/astrology/thai/core/decision/decision_action.dart';
import 'package:knowme/features/astrology/thai/core/question/question_answer.dart';
import 'package:knowme/features/astrology/thai/core/question/question_result.dart';
import 'package:knowme/features/runtime/reasoning_response.dart';

import 'conversation_question.dart';

/// V16 — the answer to a conversation question.
///
/// Since V17 the conversation consumes the **global** `ReasoningRuntime`, so
/// [response] is the system-agnostic `ReasoningResponse`. For `question` API
/// calls the V12 [questionResult] is extracted from the response's native Thai
/// payload so a presenter can render stance/evidence later. Evidence only — no
/// rendered prose.
class ConversationAnswer {
  const ConversationAnswer({
    required this.questionId,
    required this.api,
    required this.response,
    required this.questionResult,
  });

  final String questionId;
  final ConversationRuntimeApi api;

  /// The system-agnostic runtime response that produced this answer.
  final ReasoningResponse response;

  /// The V12 question result (only for `question` API calls; null otherwise).
  final QuestionResult? questionResult;

  int get confidence => response.confidence;

  /// The structured stance (only for `question` API calls).
  QuestionStance? get stance => questionResult?.answer.stance;

  /// The underlying decision verdict (only for `question` API calls).
  DecisionAction? get action => questionResult?.answer.action;
}
