import 'conversation_answer.dart';

/// V16 — the deterministic record of a conversation so far.
///
/// Tracks the order of asked question ids and the answers, so the flow can avoid
/// re-suggesting answered questions and a presenter can replay the thread. No
/// persistence here (no Firestore) — it is an in-memory value object.
class ConversationMemory {
  const ConversationMemory({
    this.askedQuestionIds = const [],
    this.history = const [],
  });

  final List<String> askedQuestionIds;
  final List<ConversationAnswer> history;

  bool asked(String questionId) => askedQuestionIds.contains(questionId);

  ConversationMemory record(String questionId, ConversationAnswer answer) =>
      ConversationMemory(
        askedQuestionIds: [...askedQuestionIds, questionId],
        history: [...history, answer],
      );
}
