// Phase A — the measurable moments of the Global Mirror Experience.
//
// This is instrumentation only: it observes the existing P3 experience. It does
// not change the runtime, the engines, or the UI. Events are deterministic
// records (a type + a timestamp + optional props) so metrics and funnels are
// pure functions of the event log.

/// Every product moment Phase A measures.
enum ProductEventType {
  /// A fresh experience session began (entry resolved).
  sessionStarted,

  /// The home / entry surface was shown.
  homeViewed,

  /// The user tapped "Begin" and entered the journey.
  journeyStarted,

  /// The Current Life read was shown — the WOW moment.
  insightViewed,

  /// The Prediction stage was shown.
  predictionViewed,

  /// The Decision stage was shown.
  decisionViewed,

  /// The Ask More / Conversation entry was shown.
  askMoreViewed,

  /// A conversation topic card was opened.
  conversationTopicOpened,

  /// A conversation question was asked (runtime answered).
  conversationQuestionAsked,

  /// The answer to a conversation question was shown.
  conversationAnswerViewed,

  /// A suggested follow-up card was tapped.
  conversationSuggestionTapped,

  /// A card's "What this is based on" evidence was expanded (a card opened).
  evidenceExpanded,

  /// The closing Reflection was shown.
  reflectionViewed,

  /// The journey was restarted from Reflection.
  journeyRestarted,
}

/// One recorded product moment.
class ProductEvent {
  const ProductEvent({
    required this.type,
    required this.atMillis,
    this.props = const {},
  });

  final ProductEventType type;

  /// Epoch milliseconds when the event was recorded (from the tracker's clock).
  final int atMillis;

  /// Optional structural context (e.g. `stage`, `topicId`, `questionId`,
  /// `cardId`). Never user content.
  final Map<String, Object?> props;
}

/// The ordered funnel stages, mirroring the P3 user flow exactly:
/// Home → Current Life → Prediction → Decision → Conversation → Reflection.
enum ProductFunnelStage {
  home,
  currentLife,
  prediction,
  decision,
  conversation,
  reflection,
}

extension ProductFunnelStageX on ProductFunnelStage {
  /// The event whose presence in a session means this stage was reached.
  ProductEventType get trigger {
    switch (this) {
      case ProductFunnelStage.home:
        return ProductEventType.homeViewed;
      case ProductFunnelStage.currentLife:
        return ProductEventType.insightViewed;
      case ProductFunnelStage.prediction:
        return ProductEventType.predictionViewed;
      case ProductFunnelStage.decision:
        return ProductEventType.decisionViewed;
      case ProductFunnelStage.conversation:
        return ProductEventType.askMoreViewed;
      case ProductFunnelStage.reflection:
        return ProductEventType.reflectionViewed;
    }
  }

  String get label {
    switch (this) {
      case ProductFunnelStage.home:
        return 'Home';
      case ProductFunnelStage.currentLife:
        return 'Current Life (WOW)';
      case ProductFunnelStage.prediction:
        return 'Prediction';
      case ProductFunnelStage.decision:
        return 'Decision';
      case ProductFunnelStage.conversation:
        return 'Conversation';
      case ProductFunnelStage.reflection:
        return 'Reflection';
    }
  }
}
