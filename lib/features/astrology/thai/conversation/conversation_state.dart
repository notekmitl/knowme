import 'conversation_answer.dart';
import 'conversation_question.dart';
import 'conversation_suggestion.dart';
import 'conversation_topic.dart';

/// V16 — the current screen state of the guided conversation.
///
/// Immutable: the flow returns a new state for each step. Holds the open
/// [topic], the questions [availableQuestions] the user can pick, the
/// [lastQuestion]/[lastAnswer] just resolved, and the [suggestions] for the next
/// step.
class ConversationState {
  const ConversationState({
    this.topic,
    this.availableQuestions = const [],
    this.lastQuestion,
    this.lastAnswer,
    this.suggestions = const [],
  });

  final ConversationTopic? topic;
  final List<ConversationQuestion> availableQuestions;
  final ConversationQuestion? lastQuestion;
  final ConversationAnswer? lastAnswer;
  final List<ConversationSuggestion> suggestions;

  ConversationState copyWith({
    ConversationTopic? topic,
    List<ConversationQuestion>? availableQuestions,
    ConversationQuestion? lastQuestion,
    ConversationAnswer? lastAnswer,
    List<ConversationSuggestion>? suggestions,
  }) =>
      ConversationState(
        topic: topic ?? this.topic,
        availableQuestions: availableQuestions ?? this.availableQuestions,
        lastQuestion: lastQuestion ?? this.lastQuestion,
        lastAnswer: lastAnswer ?? this.lastAnswer,
        suggestions: suggestions ?? this.suggestions,
      );
}
