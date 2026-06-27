import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart';
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart';

import 'conversation_answer.dart';
import 'conversation_catalog.dart';
import 'conversation_memory.dart';
import 'conversation_question.dart';
import 'conversation_session.dart';
import 'conversation_state.dart';
import 'conversation_suggestion.dart';
import 'conversation_topic.dart';

/// V16 — the deterministic guided-conversation engine.
///
/// It drives the experience entirely through the V13 [ThaiReasoningRuntime]
/// (never calling a lower engine, never the simulation/transit layers): the user
/// opens a topic, picks a predefined question, the runtime answers, and the flow
/// suggests the next questions. No free text, no parser, no LLM, no AI — every
/// step is a pure function of the session, the chosen question id and the
/// runtime output.
abstract final class ConversationFlow {
  static const int maxSuggestions = 3;

  /// Opens [topic], listing its selectable questions. No runtime call.
  static ConversationSession openTopic(
    ConversationSession session,
    ConversationTopic topic,
  ) =>
      session.copyWith(
        state: ConversationState(
          topic: topic,
          availableQuestions: ConversationCatalog.forTopic(topic),
        ),
      );

  /// Asks the question [questionId]: runs the runtime, records the answer and
  /// computes the next suggestions.
  static ConversationSession ask(
    ConversationSession session,
    String questionId, {
    ThaiReasoningRuntime runtime = const ThaiReasoningRuntime(),
  }) {
    final question = ConversationCatalog.byId(questionId);
    final response = _run(runtime, session, question);

    final answer = ConversationAnswer(
      questionId: question.id,
      api: question.api,
      response: response,
      questionResult: question.api == ConversationRuntimeApi.question
          ? response.question!.result
          : null,
    );

    final memory = session.memory.record(question.id, answer);
    final suggestions = _suggestions(question, memory);

    return session.copyWith(
      state: ConversationState(
        topic: question.topic,
        availableQuestions: ConversationCatalog.forTopic(question.topic),
        lastQuestion: question,
        lastAnswer: answer,
        suggestions: suggestions,
      ),
      memory: memory,
    );
  }

  // --- Internals -----------------------------------------------------------

  static ReasoningResponse _run(
    ThaiReasoningRuntime runtime,
    ConversationSession session,
    ConversationQuestion question,
  ) {
    final request = ReasoningRequest(
      birthDate: session.birthDate,
      lagnaLord: session.lagnaLord,
      asOf: session.asOf,
      question: question.intent,
      scenarioFocus: question.scenarioFocus,
    );
    switch (question.api) {
      case ConversationRuntimeApi.evaluate:
        return runtime.evaluate(request);
      case ConversationRuntimeApi.predict:
        return runtime.predict(request);
      case ConversationRuntimeApi.decide:
        return runtime.decide(request);
      case ConversationRuntimeApi.question:
        return runtime.question(request);
    }
  }

  static List<ConversationSuggestion> _suggestions(
    ConversationQuestion asked,
    ConversationMemory memory,
  ) {
    final out = <ConversationSuggestion>[];

    // Curated follow-ups first.
    for (final id in asked.followUpIds) {
      if (memory.asked(id)) continue;
      final q = ConversationCatalog.byId(id);
      out.add(_suggestion(q, ConversationSuggestionReason.followUp));
      if (out.length == maxSuggestions) return out;
    }

    // Fall back to unasked siblings in the same topic.
    for (final q in ConversationCatalog.forTopic(asked.topic)) {
      if (q.id == asked.id || memory.asked(q.id)) continue;
      if (out.any((s) => s.questionId == q.id)) continue;
      out.add(_suggestion(q, ConversationSuggestionReason.deepen));
      if (out.length == maxSuggestions) return out;
    }

    return out;
  }

  static ConversationSuggestion _suggestion(
    ConversationQuestion q,
    ConversationSuggestionReason reason,
  ) =>
      ConversationSuggestion(
        questionId: q.id,
        topic: q.topic,
        label: q.label,
        reason: reason,
      );
}
