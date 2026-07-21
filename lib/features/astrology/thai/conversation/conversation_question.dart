import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';

import 'conversation_topic.dart';

/// Which runtime API a conversation question drives. Conversation consumes the
/// runtime only — these map 1:1 to `ThaiReasoningRuntime` methods.
enum ConversationRuntimeApi { evaluate, predict, decide, question }

/// V16 — one selectable question in the guided conversation.
///
/// It is a **structured, predefined** prompt (no free text, no parsing): a
/// stable [id], the [topic] it belongs to, a developer-facing English [label]
/// (a later presenter localises this to Thai consumer copy), the runtime [api]
/// to call, the optional [intent]/[scenarioFocus] that parametrise the call, and
/// the [followUpIds] the conversation may suggest next.
class ConversationQuestion {
  const ConversationQuestion({
    required this.id,
    required this.topic,
    required this.label,
    required this.api,
    this.intent,
    this.scenarioFocus,
    this.followUpIds = const [],
  });

  final String id;
  final ConversationTopic topic;

  /// Structural label for selection — NOT Thai consumer copy. A presentation
  /// layer maps the question [id] to localized prose later.
  final String label;

  final ConversationRuntimeApi api;

  /// The structured intent for `question` API calls.
  final QuestionIntent? intent;

  /// The scenario focus for `decide` API calls.
  final DecisionScenario? scenarioFocus;

  /// Stable ids of the follow-up questions the conversation may suggest.
  final List<String> followUpIds;
}
