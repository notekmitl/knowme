import 'package:knowme/features/astrology/thai/core/question/question_topic.dart';

/// V16 — the eight conversation topics a user can explore (Supported V1).
///
/// Six map onto a V12 [QuestionTopic] (used to build decision questions);
/// [currentLife] and [future] are overview topics answered via the runtime's
/// `evaluate`/`predict`/`decide` APIs rather than a single decision scenario.
enum ConversationTopic {
  currentLife,
  career,
  money,
  relationship,
  family,
  health,
  growth,
  future,
}

extension ConversationTopicMapping on ConversationTopic {
  /// The V12 question topic this maps to, or null for overview topics
  /// ([currentLife], [future]).
  QuestionTopic? get questionTopic {
    switch (this) {
      case ConversationTopic.career:
        return QuestionTopic.career;
      case ConversationTopic.money:
        return QuestionTopic.finance;
      case ConversationTopic.relationship:
        return QuestionTopic.relationship;
      case ConversationTopic.family:
        return QuestionTopic.family;
      case ConversationTopic.health:
        return QuestionTopic.health;
      case ConversationTopic.growth:
        return QuestionTopic.education;
      case ConversationTopic.currentLife:
      case ConversationTopic.future:
        return null;
    }
  }
}
