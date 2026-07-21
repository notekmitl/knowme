import 'question_constraint.dart';
import 'question_topic.dart';

/// V12 — the supported structured question intents (Supported Intent V1).
///
/// These are **intent objects, not parsed text**. A caller (a UI control, a
/// voice assistant, a future AI front-end) constructs the intent directly; this
/// layer never parses natural language.
enum QuestionIntentKind {
  /// "Should I …?" — a go/no-go on the topic now.
  shouldI,

  /// "When should I …?" — best timing for the topic.
  whenShouldI,

  /// "Should I wait …?" — is a later window materially better?
  shouldIWait,

  /// "What should I prepare …?" — what to mitigate before acting.
  whatShouldIPrepare,

  /// "What is the biggest opportunity …?" — the leading upside.
  biggestOpportunity,

  /// "What is the biggest risk …?" — the leading downside.
  biggestRisk,
}

/// V12 — a fully structured question: an [kind] about a [topic], with an
/// optional [constraint]. No copy, no parser.
class QuestionIntent {
  const QuestionIntent({
    required this.kind,
    required this.topic,
    this.constraint = QuestionConstraint.none,
  });

  final QuestionIntentKind kind;
  final QuestionTopic topic;
  final QuestionConstraint constraint;
}
