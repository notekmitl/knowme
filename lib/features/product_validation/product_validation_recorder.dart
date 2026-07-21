import 'product_insight.dart';
import 'product_insights_engine.dart';
import 'product_metrics.dart';
import 'product_validation_events.dart';

/// Phase A — the instrumentation surface the experience calls.
///
/// One method per measurable product moment. Implementations decide whether and
/// how to record; the experience never depends on a concrete tracker.
abstract class ProductValidationTracker {
  void sessionStarted();
  void homeViewed();
  void journeyStarted();
  void insightViewed();
  void predictionViewed();
  void decisionViewed();
  void askMoreViewed();
  void conversationTopicOpened(String topicId);
  void conversationQuestionAsked(String questionId);
  void conversationAnswerViewed(String questionId);
  void conversationSuggestionTapped(String questionId);
  void evidenceExpanded(String cardId);
  void reflectionViewed();
  void journeyRestarted();

  // Phase C — Daily Mirror.
  void dailyMirrorOpened();
  void dailyActionClicked();
  void dailyConversationStarted();

  // Phase D — Daily Habit loop.
  void dailyReflectionSaved();
}

/// A tracker that records nothing — for tests, or to disable measurement.
class NoopProductValidationTracker implements ProductValidationTracker {
  const NoopProductValidationTracker();

  @override
  void sessionStarted() {}
  @override
  void homeViewed() {}
  @override
  void journeyStarted() {}
  @override
  void insightViewed() {}
  @override
  void predictionViewed() {}
  @override
  void decisionViewed() {}
  @override
  void askMoreViewed() {}
  @override
  void conversationTopicOpened(String topicId) {}
  @override
  void conversationQuestionAsked(String questionId) {}
  @override
  void conversationAnswerViewed(String questionId) {}
  @override
  void conversationSuggestionTapped(String questionId) {}
  @override
  void evidenceExpanded(String cardId) {}
  @override
  void reflectionViewed() {}
  @override
  void journeyRestarted() {}
  @override
  void dailyMirrorOpened() {}
  @override
  void dailyActionClicked() {}
  @override
  void dailyConversationStarted() {}
  @override
  void dailyReflectionSaved() {}
}

/// Collects product events in memory and derives metrics/insights on demand.
///
/// Deterministic given its [clock]. Sessions are delimited by [sessionStarted];
/// the current session plus all earlier ones form the analysis input. There is
/// no backend sink — this is an internal validation tool read by the internal
/// dashboard within a running app. A persistent sink can be added later without
/// changing callers.
class ProductValidationRecorder implements ProductValidationTracker {
  ProductValidationRecorder({int Function()? clock})
      : _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  final int Function() _clock;

  /// When false, all `track*` calls are ignored (measurement off).
  bool enabled = true;

  final List<List<ProductEvent>> _completed = [];
  List<ProductEvent> _current = [];

  /// All sessions observed so far (completed + the in-progress one).
  List<List<ProductEvent>> get sessions => [
        ..._completed,
        if (_current.isNotEmpty) _current,
      ];

  /// Events of the in-progress session.
  List<ProductEvent> get currentEvents => List.unmodifiable(_current);

  // --- Tracker API ---------------------------------------------------------

  @override
  void sessionStarted() {
    if (!enabled) return;
    if (_current.isNotEmpty) {
      _completed.add(_current);
      _current = [];
    }
    _record(ProductEventType.sessionStarted);
  }

  @override
  void homeViewed() => _record(ProductEventType.homeViewed);
  @override
  void journeyStarted() => _record(ProductEventType.journeyStarted);
  @override
  void insightViewed() => _record(ProductEventType.insightViewed);
  @override
  void predictionViewed() => _record(ProductEventType.predictionViewed);
  @override
  void decisionViewed() => _record(ProductEventType.decisionViewed);
  @override
  void askMoreViewed() => _record(ProductEventType.askMoreViewed);

  @override
  void conversationTopicOpened(String topicId) => _record(
        ProductEventType.conversationTopicOpened,
        {'topicId': topicId},
      );

  @override
  void conversationQuestionAsked(String questionId) => _record(
        ProductEventType.conversationQuestionAsked,
        {'questionId': questionId},
      );

  @override
  void conversationAnswerViewed(String questionId) => _record(
        ProductEventType.conversationAnswerViewed,
        {'questionId': questionId},
      );

  @override
  void conversationSuggestionTapped(String questionId) => _record(
        ProductEventType.conversationSuggestionTapped,
        {'questionId': questionId},
      );

  @override
  void evidenceExpanded(String cardId) =>
      _record(ProductEventType.evidenceExpanded, {'cardId': cardId});

  @override
  void reflectionViewed() => _record(ProductEventType.reflectionViewed);
  @override
  void journeyRestarted() => _record(ProductEventType.journeyRestarted);
  @override
  void dailyMirrorOpened() => _record(ProductEventType.dailyMirrorOpened);
  @override
  void dailyActionClicked() => _record(ProductEventType.dailyActionClicked);
  @override
  void dailyConversationStarted() =>
      _record(ProductEventType.dailyConversationStarted);
  @override
  void dailyReflectionSaved() =>
      _record(ProductEventType.dailyReflectionSaved);

  // --- Reads ---------------------------------------------------------------

  /// Metrics for the in-progress session.
  ProductMetrics currentMetrics() => ProductMetrics.forSession(_current);

  /// Product insights across all observed sessions.
  ProductInsights insights() => ProductInsightsEngine.analyze(sessions);

  /// Clears everything (tests / dashboard reset).
  void reset() {
    _completed.clear();
    _current = [];
  }

  // --- Internals -----------------------------------------------------------

  void _record(ProductEventType type, [Map<String, Object?> props = const {}]) {
    if (!enabled) return;
    _current.add(ProductEvent(type: type, atMillis: _clock(), props: props));
  }
}
