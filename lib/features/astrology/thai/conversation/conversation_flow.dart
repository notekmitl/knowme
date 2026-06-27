import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart'
    as thai;
import 'package:knowme/features/runtime/adapters/thai_runtime_adapter.dart';
import 'package:knowme/features/runtime/reasoning_capability.dart';
import 'package:knowme/features/runtime/reasoning_module.dart';
import 'package:knowme/features/runtime/reasoning_request.dart';
import 'package:knowme/features/runtime/reasoning_runtime.dart';

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
/// Since V17 it drives the experience through the **global** [ReasoningRuntime]
/// (defaulting to a runtime that hosts only the Thai provider), never calling a
/// system runtime or a lower engine directly: the user opens a topic, picks a
/// predefined question, the runtime answers, and the flow suggests the next
/// questions. No free text, no parser, no LLM, no AI — every step is a pure
/// function of the session, the chosen question id and the runtime output.
abstract final class ConversationFlow {
  static const int maxSuggestions = 3;

  /// The default global runtime for the conversation: Thai is the only provider.
  static const ReasoningRuntime defaultRuntime =
      ReasoningRuntime([ThaiRuntimeAdapter()]);

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
    ReasoningRuntime runtime = defaultRuntime,
  }) {
    final question = ConversationCatalog.byId(questionId);
    final response = runtime.run(_request(session, question));

    final answer = ConversationAnswer(
      questionId: question.id,
      api: question.api,
      response: response,
      questionResult: question.api == ConversationRuntimeApi.question
          ? (response.raw as thai.ReasoningResponse).question!.result
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

  static ReasoningRequest _request(
    ConversationSession session,
    ConversationQuestion question,
  ) =>
      ReasoningRequest(
        module: ReasoningModule.thaiAstrology,
        capability: _capability(question.api),
        birthDate: session.birthDate,
        asOf: session.asOf,
        parameters: {
          'lagnaLord': session.lagnaLord,
          'questionIntent': question.intent,
          'scenarioFocus': question.scenarioFocus,
        },
      );

  static ReasoningCapability _capability(ConversationRuntimeApi api) {
    switch (api) {
      case ConversationRuntimeApi.evaluate:
        return ReasoningCapability.evaluate;
      case ConversationRuntimeApi.predict:
        return ReasoningCapability.predict;
      case ConversationRuntimeApi.decide:
        return ReasoningCapability.decide;
      case ConversationRuntimeApi.question:
        return ReasoningCapability.question;
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
