import 'package:flutter_test/flutter_test.dart';

import 'package:knowme/features/product_validation/product_funnel.dart';
import 'package:knowme/features/product_validation/product_insight.dart';
import 'package:knowme/features/product_validation/product_insights_engine.dart';
import 'package:knowme/features/product_validation/product_validation_events.dart';
import 'package:knowme/features/product_validation/product_validation_recorder.dart';

/// Phase A — product-validation measurement is deterministic and instrumentation
/// only: metrics, funnels and insights are pure functions of the event log.
void main() {
  // A controllable clock: each recorded event advances 1000ms.
  ProductValidationRecorder recorderWithClock() {
    var now = 0;
    return ProductValidationRecorder(clock: () => now += 1000);
  }

  List<ProductEvent> session(List<ProductEventType> types) {
    var t = 0;
    return [for (final ty in types) ProductEvent(type: ty, atMillis: t += 1000)];
  }

  test('a full session yields the expected per-session metrics', () {
    final r = recorderWithClock();
    r.sessionStarted();
    r.homeViewed();
    r.journeyStarted();
    r.insightViewed();
    r.predictionViewed();
    r.decisionViewed();
    r.askMoreViewed();
    r.conversationTopicOpened('career');
    r.conversationQuestionAsked('career_change');
    r.conversationAnswerViewed('career_change');
    r.reflectionViewed();

    final m = r.currentMetrics();
    expect(m.reachedWow, isTrue);
    expect(m.timeToFirstWowMs, 3000); // start@1000 → insight@4000
    expect(m.timeToFirstConversationMs, 8000); // start@1000 → ask@9000
    expect(m.questionsAsked, 1);
    expect(m.cardsOpened, 0);
    expect(m.conversationCompleted, isTrue);
    expect(m.reflectionCompleted, isTrue);
  });

  test('evidence expansions count as cards opened', () {
    final r = recorderWithClock();
    r.sessionStarted();
    r.insightViewed();
    r.evidenceExpanded('currentLife');
    r.evidenceExpanded('prediction');

    expect(r.currentMetrics().cardsOpened, 2);
  });

  test('funnel detects where users stop', () {
    final full = session([
      ProductEventType.homeViewed,
      ProductEventType.insightViewed,
      ProductEventType.predictionViewed,
      ProductEventType.decisionViewed,
      ProductEventType.askMoreViewed,
      ProductEventType.reflectionViewed,
    ]);
    final toDecision = session([
      ProductEventType.homeViewed,
      ProductEventType.insightViewed,
      ProductEventType.predictionViewed,
      ProductEventType.decisionViewed,
    ]);
    final toCurrentLife = session([
      ProductEventType.homeViewed,
      ProductEventType.insightViewed,
    ]);
    final homeOnly = session([ProductEventType.homeViewed]);

    final sessions = <List<ProductEvent>>[
      ...List.generate(4, (_) => full),
      ...List.generate(3, (_) => toDecision),
      ...List.generate(2, (_) => toCurrentLife),
      homeOnly,
    ];

    final funnel = ProductFunnel.fromSessions(sessions);
    expect(funnel.totalSessions, 10);

    int reached(ProductFunnelStage s) =>
        funnel.stages.firstWhere((r) => r.stage == s).reachedCount;
    expect(reached(ProductFunnelStage.home), 10);
    expect(reached(ProductFunnelStage.currentLife), 9);
    expect(reached(ProductFunnelStage.prediction), 7);
    expect(reached(ProductFunnelStage.decision), 7);
    expect(reached(ProductFunnelStage.conversation), 4);
    expect(reached(ProductFunnelStage.reflection), 4);

    final worst = funnel.biggestDropOff;
    expect(worst, isNotNull);
    expect(worst!.stage, ProductFunnelStage.conversation);
    expect(worst.dropOffFromPrevious, 3);
  });

  test('insights summarize WOW, curiosity, engagement and drop-off', () {
    final wow = session([
      ProductEventType.sessionStarted,
      ProductEventType.homeViewed,
      ProductEventType.insightViewed,
      ProductEventType.evidenceExpanded,
      ProductEventType.predictionViewed,
      ProductEventType.decisionViewed,
      ProductEventType.askMoreViewed,
      ProductEventType.conversationTopicOpened,
      ProductEventType.conversationQuestionAsked,
      ProductEventType.conversationAnswerViewed,
      ProductEventType.reflectionViewed,
    ]);
    final stalled = session([
      ProductEventType.sessionStarted,
      ProductEventType.homeViewed,
      ProductEventType.insightViewed,
    ]);

    final insights = ProductInsightsEngine.analyze([wow, wow, stalled, stalled]);

    expect(insights.sessionCount, 4);
    expect(insights.returnVisit, isTrue);
    expect(insights.ofKind(ProductInsightKind.wow), isNotEmpty);
    expect(insights.ofKind(ProductInsightKind.curiosity), isNotEmpty);
    expect(insights.ofKind(ProductInsightKind.engagement), isNotEmpty);

    // WOW reached in all 4 sessions.
    final wowRate = insights
        .ofKind(ProductInsightKind.wow)
        .firstWhere((i) => i.headline.startsWith('WOW reach rate'));
    expect(wowRate.value, 1.0);

    // 2 of 4 completed a conversation.
    final convComplete = insights
        .ofKind(ProductInsightKind.engagement)
        .firstWhere((i) => i.headline.startsWith('Conversation completion'));
    expect(convComplete.value, 0.5);

    // The two stalled sessions drop off after Current Life.
    final drop = insights.ofKind(ProductInsightKind.dropOff);
    expect(drop, isNotEmpty);
  });

  test('analysis is deterministic for the same sessions', () {
    final s = session([
      ProductEventType.sessionStarted,
      ProductEventType.homeViewed,
      ProductEventType.insightViewed,
      ProductEventType.predictionViewed,
    ]);
    final a = ProductInsightsEngine.analyze([s, s]);
    final b = ProductInsightsEngine.analyze([s, s]);
    expect(a.insights.map((i) => i.headline),
        b.insights.map((i) => i.headline));
    expect(a.funnel.stages.map((x) => x.reachedCount),
        b.funnel.stages.map((x) => x.reachedCount));
  });

  test('return visit is detected across sessions', () {
    final r = recorderWithClock();
    r.sessionStarted();
    r.homeViewed();
    r.sessionStarted(); // a second visit

    final insights = r.insights();
    expect(insights.sessionCount, 2);
    expect(insights.returnVisit, isTrue);
  });

  test('disabled recorder measures nothing', () {
    final r = recorderWithClock()..enabled = false;
    r.sessionStarted();
    r.insightViewed();
    expect(r.sessions, isEmpty);
  });
}
