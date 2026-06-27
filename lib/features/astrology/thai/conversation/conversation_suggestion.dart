import 'conversation_topic.dart';

/// Why the conversation is suggesting a next question.
enum ConversationSuggestionReason {
  /// A curated follow-up to the question just answered.
  followUp,

  /// A sibling question in the same topic (when follow-ups are exhausted).
  deepen,
}

/// V16 — a suggested next question, surfaced after an answer. Deterministic; the
/// user picks one (or opens another topic). [label] is a structural prompt, not
/// Thai consumer copy.
class ConversationSuggestion {
  const ConversationSuggestion({
    required this.questionId,
    required this.topic,
    required this.label,
    required this.reason,
  });

  final String questionId;
  final ConversationTopic topic;
  final String label;
  final ConversationSuggestionReason reason;
}
