import 'product_validation_events.dart';

/// Phase A — the per-session product metrics, derived purely from an event log.
///
/// These answer "what did this one run experience?" Aggregation across sessions
/// (rates, medians, funnels) happens in the insights engine.
class ProductMetrics {
  const ProductMetrics({
    required this.timeToFirstWowMs,
    required this.timeToFirstConversationMs,
    required this.cardsOpened,
    required this.questionsAsked,
    required this.predictionViewed,
    required this.decisionViewed,
    required this.conversationCompleted,
    required this.reflectionCompleted,
    required this.reachedWow,
  });

  /// Milliseconds from session start to the WOW moment (null if never reached).
  final int? timeToFirstWowMs;

  /// Milliseconds from session start to the first conversation question.
  final int? timeToFirstConversationMs;

  /// How many card evidence sections were expanded ("cards opened").
  final int cardsOpened;

  /// How many conversation questions were asked.
  final int questionsAsked;

  final bool predictionViewed;
  final bool decisionViewed;

  /// At least one conversation question was asked and answered.
  final bool conversationCompleted;

  /// The closing Reflection was reached.
  final bool reflectionCompleted;

  /// The Current Life (WOW) read was shown.
  final bool reachedWow;

  factory ProductMetrics.forSession(List<ProductEvent> events) {
    int? firstAt(ProductEventType type) {
      for (final e in events) {
        if (e.type == type) return e.atMillis;
      }
      return null;
    }

    int count(ProductEventType type) =>
        events.where((e) => e.type == type).length;

    bool has(ProductEventType type) => events.any((e) => e.type == type);

    // Session anchor: the explicit start, else the first event seen.
    final startAt = firstAt(ProductEventType.sessionStarted) ??
        (events.isEmpty ? null : events.first.atMillis);

    final wowAt = firstAt(ProductEventType.insightViewed);
    final convAt = firstAt(ProductEventType.conversationQuestionAsked);
    final answered = has(ProductEventType.conversationAnswerViewed);

    return ProductMetrics(
      timeToFirstWowMs:
          (startAt != null && wowAt != null) ? wowAt - startAt : null,
      timeToFirstConversationMs:
          (startAt != null && convAt != null) ? convAt - startAt : null,
      cardsOpened: count(ProductEventType.evidenceExpanded),
      questionsAsked: count(ProductEventType.conversationQuestionAsked),
      predictionViewed: has(ProductEventType.predictionViewed),
      decisionViewed: has(ProductEventType.decisionViewed),
      conversationCompleted:
          count(ProductEventType.conversationQuestionAsked) >= 1 && answered,
      reflectionCompleted: has(ProductEventType.reflectionViewed),
      reachedWow: wowAt != null,
    );
  }
}
