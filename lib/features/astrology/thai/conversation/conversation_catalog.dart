import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';
import 'package:knowme/features/astrology/thai/core/question/question_topic.dart';

import 'conversation_question.dart';
import 'conversation_topic.dart';

/// V16 — the deterministic catalog of selectable questions and their follow-up
/// graph. This is the fixed structure of the guided conversation: there is no
/// free text, no parsing, no generation. A presentation layer maps question ids
/// to localized copy.
abstract final class ConversationCatalog {
  static const List<ConversationQuestion> questions = [
    // --- Current Life (overview + cross-domain entry points) ----------------
    ConversationQuestion(
      id: 'cl_overview',
      topic: ConversationTopic.currentLife,
      label: 'Where does my life stand right now?',
      api: ConversationRuntimeApi.evaluate,
      followUpIds: ['cl_focus', 'cl_career', 'future_outlook'],
    ),
    ConversationQuestion(
      id: 'cl_focus',
      topic: ConversationTopic.currentLife,
      label: 'What should I focus on now?',
      api: ConversationRuntimeApi.decide,
      followUpIds: ['cl_career', 'money_invest', 'future_opportunity'],
    ),
    ConversationQuestion(
      id: 'cl_career',
      topic: ConversationTopic.currentLife,
      label: 'Should I change jobs?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.career,
      ),
      followUpIds: ['future_opportunity', 'career_timing', 'career_prepare'],
    ),

    // --- Career --------------------------------------------------------------
    ConversationQuestion(
      id: 'career_change',
      topic: ConversationTopic.career,
      label: 'Should I make a career change?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.career,
      ),
      followUpIds: ['career_timing', 'career_prepare', 'career_risk'],
    ),
    ConversationQuestion(
      id: 'career_timing',
      topic: ConversationTopic.career,
      label: 'When should I make a career move?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whenShouldI,
        topic: QuestionTopic.career,
      ),
      followUpIds: ['career_prepare', 'career_risk'],
    ),
    ConversationQuestion(
      id: 'career_prepare',
      topic: ConversationTopic.career,
      label: 'What should I prepare for in my career?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whatShouldIPrepare,
        topic: QuestionTopic.career,
      ),
      followUpIds: ['career_risk', 'career_change'],
    ),
    ConversationQuestion(
      id: 'career_risk',
      topic: ConversationTopic.career,
      label: 'What is the biggest career risk?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.biggestRisk,
        topic: QuestionTopic.career,
      ),
      followUpIds: ['career_change', 'career_timing'],
    ),

    // --- Money ---------------------------------------------------------------
    ConversationQuestion(
      id: 'money_invest',
      topic: ConversationTopic.money,
      label: 'Should I invest now?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.investment,
      ),
      followUpIds: ['money_timing', 'money_plan', 'money_risk'],
    ),
    ConversationQuestion(
      id: 'money_plan',
      topic: ConversationTopic.money,
      label: 'Should I focus on financial planning?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.finance,
      ),
      followUpIds: ['money_invest', 'money_risk'],
    ),
    ConversationQuestion(
      id: 'money_timing',
      topic: ConversationTopic.money,
      label: 'When is the best time for money decisions?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whenShouldI,
        topic: QuestionTopic.finance,
      ),
      followUpIds: ['money_plan', 'money_invest'],
    ),
    ConversationQuestion(
      id: 'money_risk',
      topic: ConversationTopic.money,
      label: 'What is the biggest financial risk?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.biggestRisk,
        topic: QuestionTopic.finance,
      ),
      followUpIds: ['money_plan', 'money_invest'],
    ),

    // --- Relationship --------------------------------------------------------
    ConversationQuestion(
      id: 'rel_forward',
      topic: ConversationTopic.relationship,
      label: 'Should I take my relationship forward?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.relationship,
      ),
      followUpIds: ['rel_marriage', 'rel_timing'],
    ),
    ConversationQuestion(
      id: 'rel_marriage',
      topic: ConversationTopic.relationship,
      label: 'Is it a good time for marriage?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.marriage,
      ),
      followUpIds: ['rel_timing', 'rel_forward'],
    ),
    ConversationQuestion(
      id: 'rel_timing',
      topic: ConversationTopic.relationship,
      label: 'When is the best time for love decisions?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whenShouldI,
        topic: QuestionTopic.relationship,
      ),
      followUpIds: ['rel_forward', 'rel_marriage'],
    ),

    // --- Family --------------------------------------------------------------
    ConversationQuestion(
      id: 'fam_plan',
      topic: ConversationTopic.family,
      label: 'Is it a good time for family planning?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.family,
      ),
      followUpIds: ['fam_prepare', 'fam_timing'],
    ),
    ConversationQuestion(
      id: 'fam_prepare',
      topic: ConversationTopic.family,
      label: 'What should I prepare for my family?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whatShouldIPrepare,
        topic: QuestionTopic.family,
      ),
      followUpIds: ['fam_plan', 'fam_timing'],
    ),
    ConversationQuestion(
      id: 'fam_timing',
      topic: ConversationTopic.family,
      label: 'When is the best time for family decisions?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whenShouldI,
        topic: QuestionTopic.family,
      ),
      followUpIds: ['fam_plan', 'fam_prepare'],
    ),

    // --- Health --------------------------------------------------------------
    ConversationQuestion(
      id: 'health_improve',
      topic: ConversationTopic.health,
      label: 'Should I act on my health now?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.health,
      ),
      followUpIds: ['health_timing', 'health_risk'],
    ),
    ConversationQuestion(
      id: 'health_timing',
      topic: ConversationTopic.health,
      label: 'When should I focus on my health?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whenShouldI,
        topic: QuestionTopic.health,
      ),
      followUpIds: ['health_improve', 'health_risk'],
    ),
    ConversationQuestion(
      id: 'health_risk',
      topic: ConversationTopic.health,
      label: 'What is the biggest health risk?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.biggestRisk,
        topic: QuestionTopic.health,
      ),
      followUpIds: ['health_improve', 'health_timing'],
    ),

    // --- Growth --------------------------------------------------------------
    ConversationQuestion(
      id: 'growth_learn',
      topic: ConversationTopic.growth,
      label: 'Should I invest in learning and growth?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.shouldI,
        topic: QuestionTopic.education,
      ),
      followUpIds: ['growth_opportunity', 'growth_timing'],
    ),
    ConversationQuestion(
      id: 'growth_timing',
      topic: ConversationTopic.growth,
      label: 'When should I pursue growth?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whenShouldI,
        topic: QuestionTopic.education,
      ),
      followUpIds: ['growth_learn', 'growth_opportunity'],
    ),
    ConversationQuestion(
      id: 'growth_opportunity',
      topic: ConversationTopic.growth,
      label: 'What is my biggest growth opportunity?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.biggestOpportunity,
        topic: QuestionTopic.education,
      ),
      followUpIds: ['growth_learn', 'growth_timing'],
    ),

    // --- Future (overview + forward-looking) --------------------------------
    ConversationQuestion(
      id: 'future_outlook',
      topic: ConversationTopic.future,
      label: 'What does my near future look like?',
      api: ConversationRuntimeApi.predict,
      followUpIds: ['future_opportunity', 'future_prepare'],
    ),
    ConversationQuestion(
      id: 'future_opportunity',
      topic: ConversationTopic.future,
      label: 'What opportunity should I prepare for?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.biggestOpportunity,
        topic: QuestionTopic.career,
      ),
      followUpIds: ['future_prepare', 'cl_career'],
    ),
    ConversationQuestion(
      id: 'future_prepare',
      topic: ConversationTopic.future,
      label: 'What should I prepare for next?',
      api: ConversationRuntimeApi.question,
      intent: QuestionIntent(
        kind: QuestionIntentKind.whatShouldIPrepare,
        topic: QuestionTopic.career,
      ),
      followUpIds: ['future_opportunity', 'future_outlook'],
    ),
  ];

  static final Map<String, ConversationQuestion> _byId = {
    for (final q in questions) q.id: q,
  };

  /// The question with [id]. Throws if unknown (ids are a fixed catalog).
  static ConversationQuestion byId(String id) {
    final q = _byId[id];
    if (q == null) {
      throw ArgumentError.value(id, 'id', 'Unknown conversation question');
    }
    return q;
  }

  /// All questions for [topic], in catalog order.
  static List<ConversationQuestion> forTopic(ConversationTopic topic) =>
      [for (final q in questions) if (q.topic == topic) q];
}
