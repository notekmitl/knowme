import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_catalog.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_flow.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_question.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_session.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_suggestion.dart';
import 'package:knowme/features/astrology/thai/conversation/conversation_topic.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart'
    as thai;
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart'
    as thai;
import 'package:knowme/features/runtime/adapters/thai_runtime_adapter.dart';
import 'package:knowme/features/runtime/reasoning_capability.dart';
import 'package:knowme/features/runtime/reasoning_runtime.dart';

const _runtime = ReasoningRuntime([ThaiRuntimeAdapter()]);
const _thaiRuntime = thai.ThaiReasoningRuntime();
final _asOf = DateTime(2026, 6, 27);

final _birthDates = <DateTime>[
  DateTime(1988, 3, 14),
  DateTime(1990, 7, 17),
  DateTime(1995, 1, 4),
  DateTime(1979, 11, 8),
  DateTime(2001, 5, 18),
  DateTime(1966, 9, 24),
];

ConversationSession _session(DateTime birth) =>
    ConversationSession.start(birthDate: birth, asOf: _asOf);

void main() {
  group('V16 — catalog integrity', () {
    test('ids unique; every follow-up resolves; every topic has questions', () {
      final ids = ConversationCatalog.questions.map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);

      for (final q in ConversationCatalog.questions) {
        for (final fid in q.followUpIds) {
          expect(() => ConversationCatalog.byId(fid), returnsNormally,
              reason: '${q.id} → $fid');
        }
        if (q.api == ConversationRuntimeApi.question) {
          expect(q.intent, isNotNull, reason: q.id);
        }
      }

      for (final topic in ConversationTopic.values) {
        expect(ConversationCatalog.forTopic(topic), isNotEmpty, reason: '$topic');
      }
    });
  });

  group('V16 — guided flow & example reproduction', () {
    test('openTopic lists that topic without calling the runtime', () {
      final s = ConversationFlow.openTopic(
        _session(_birthDates.first),
        ConversationTopic.currentLife,
      );
      expect(s.state.topic, ConversationTopic.currentLife);
      expect(s.state.availableQuestions,
          ConversationCatalog.forTopic(ConversationTopic.currentLife));
      expect(s.state.lastAnswer, isNull);
      expect(s.memory.askedQuestionIds, isEmpty);
    });

    test('Current Life → "Should I change jobs?" → suggested follow-up → answer',
        () {
      for (final b in _birthDates) {
        var s = ConversationFlow.openTopic(
          _session(b),
          ConversationTopic.currentLife,
        );

        s = ConversationFlow.ask(s, 'cl_career', runtime: _runtime);
        expect(s.state.lastQuestion!.id, 'cl_career');
        expect(s.state.lastAnswer!.stance, isNotNull);
        expect(s.state.lastAnswer!.action, isNotNull);

        // The example's suggested follow-up is offered.
        final followUp = s.state.suggestions
            .firstWhere((x) => x.questionId == 'future_opportunity');
        expect(followUp.label, 'What opportunity should I prepare for?');
        expect(followUp.reason, ConversationSuggestionReason.followUp);

        s = ConversationFlow.ask(s, 'future_opportunity', runtime: _runtime);
        expect(s.state.lastAnswer!.questionResult, isNotNull);
        expect(s.memory.askedQuestionIds, ['cl_career', 'future_opportunity']);
        expect(s.memory.history.length, 2);
      }
    });
  });

  group('V16 — runtime-only consistency', () {
    test('a question answer equals the Thai runtime called directly', () {
      for (final b in _birthDates) {
        final s = ConversationFlow.ask(
          _session(b),
          'career_change',
          runtime: _runtime,
        );
        final q = ConversationCatalog.byId('career_change');
        final direct = _thaiRuntime.question(thai.ReasoningRequest(
          birthDate: b,
          asOf: _asOf,
          question: q.intent,
        ));

        expect(s.state.lastAnswer!.confidence, direct.confidence);
        expect(s.state.lastAnswer!.action, direct.question!.result.answer.action);
        expect(s.state.lastAnswer!.stance, direct.question!.result.answer.stance);
      }
    });

    test('overview questions use evaluate/predict capability', () {
      final b = _birthDates.first;
      final overview = ConversationFlow.ask(_session(b), 'cl_overview',
          runtime: _runtime);
      expect(overview.state.lastAnswer!.questionResult, isNull);
      expect(overview.state.lastAnswer!.response.capability,
          ReasoningCapability.evaluate);

      final future =
          ConversationFlow.ask(_session(b), 'future_outlook', runtime: _runtime);
      expect(future.state.lastAnswer!.response.capability,
          ReasoningCapability.predict);
    });
  });

  group('V16 — suggestion logic', () {
    test('suggestions exclude already-asked and are capped', () {
      var s = _session(_birthDates.first);
      s = ConversationFlow.ask(s, 'career_change', runtime: _runtime);
      s = ConversationFlow.ask(s, 'career_timing', runtime: _runtime);

      expect(s.state.suggestions.length,
          lessThanOrEqualTo(ConversationFlow.maxSuggestions));
      for (final sug in s.state.suggestions) {
        expect(s.memory.asked(sug.questionId), isFalse);
      }
    });
  });

  group('V16 — determinism', () {
    test('identical session + question → identical answer & suggestions', () {
      for (final b in _birthDates) {
        final a = ConversationFlow.ask(_session(b), 'cl_career',
            runtime: _runtime);
        final c = ConversationFlow.ask(_session(b), 'cl_career',
            runtime: _runtime);
        expect(a.state.lastAnswer!.confidence, c.state.lastAnswer!.confidence);
        expect(a.state.lastAnswer!.stance, c.state.lastAnswer!.stance);
        expect(
          a.state.suggestions.map((s) => '${s.questionId}:${s.reason.name}'),
          c.state.suggestions.map((s) => '${s.questionId}:${s.reason.name}'),
        );
      }
    });
  });
}
