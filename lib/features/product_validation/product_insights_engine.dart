import 'product_funnel.dart';
import 'product_insight.dart';
import 'product_metrics.dart';
import 'product_validation_events.dart';

/// Phase A — turns raw sessions into **product** insights (about the product,
/// never about a specific user).
///
/// Pure and deterministic: the same sessions always yield the same insights.
/// No AI, no heuristics beyond fixed arithmetic. It answers three questions —
/// did users WOW, where did they get curious/engaged, and where did they stop?
abstract final class ProductInsightsEngine {
  static ProductInsights analyze(List<List<ProductEvent>> sessions) {
    final total = sessions.length;
    final funnel = ProductFunnel.fromSessions(sessions);
    final metrics = [for (final s in sessions) ProductMetrics.forSession(s)];

    final insights = <ProductInsight>[];
    if (total > 0) {
      insights.addAll(_wow(total, metrics));
      insights.addAll(_curiosity(total, sessions, metrics));
      insights.addAll(_engagement(total, metrics));
    }
    final drop = _dropOff(funnel);
    if (drop != null) insights.add(drop);

    return ProductInsights(
      sessionCount: total,
      funnel: funnel,
      insights: insights,
      returnVisit: total > 1,
    );
  }

  // --- WOW -----------------------------------------------------------------

  static List<ProductInsight> _wow(int total, List<ProductMetrics> metrics) {
    final reached = metrics.where((m) => m.reachedWow).length;
    final wowRate = reached / total;

    final times = [
      for (final m in metrics)
        if (m.timeToFirstWowMs != null) m.timeToFirstWowMs!,
    ];
    final medianMs = _median(times);

    final out = <ProductInsight>[
      ProductInsight(
        kind: ProductInsightKind.wow,
        headline: 'WOW reach rate: ${_pct(wowRate)}',
        detail:
            '$reached of $total sessions saw their Current Life read (the WOW '
            'moment).',
        value: wowRate,
      ),
    ];
    if (medianMs != null) {
      out.add(ProductInsight(
        kind: ProductInsightKind.wow,
        headline: 'Median time to first WOW: ${_secs(medianMs)}',
        detail: 'Half of WOW-reaching sessions hit it faster than this.',
        value: medianMs,
      ));
    }
    return out;
  }

  // --- Curiosity -----------------------------------------------------------

  static List<ProductInsight> _curiosity(
    int total,
    List<List<ProductEvent>> sessions,
    List<ProductMetrics> metrics,
  ) {
    final expanded = metrics.where((m) => m.cardsOpened > 0).length;
    final openedTopic = sessions
        .where((s) =>
            s.any((e) => e.type == ProductEventType.conversationTopicOpened))
        .length;

    return [
      ProductInsight(
        kind: ProductInsightKind.curiosity,
        headline: 'Evidence curiosity: ${_pct(expanded / total)}',
        detail:
            '$expanded of $total sessions opened a card\'s "what this is based '
            'on" detail.',
        value: expanded / total,
      ),
      ProductInsight(
        kind: ProductInsightKind.curiosity,
        headline: 'Topic exploration: ${_pct(openedTopic / total)}',
        detail:
            '$openedTopic of $total sessions opened a conversation topic.',
        value: openedTopic / total,
      ),
    ];
  }

  // --- Engagement ----------------------------------------------------------

  static List<ProductInsight> _engagement(
    int total,
    List<ProductMetrics> metrics,
  ) {
    final asked = [for (final m in metrics) m.questionsAsked];
    final askingSessions = asked.where((n) => n > 0).length;
    final totalAsked = asked.fold<int>(0, (a, b) => a + b);
    final avgPerAsking =
        askingSessions == 0 ? 0.0 : totalAsked / askingSessions;
    final convComplete = metrics.where((m) => m.conversationCompleted).length;
    final reflectComplete = metrics.where((m) => m.reflectionCompleted).length;

    return [
      ProductInsight(
        kind: ProductInsightKind.engagement,
        headline: 'Conversation completion: ${_pct(convComplete / total)}',
        detail:
            '$convComplete of $total sessions asked and received at least one '
            'answer.',
        value: convComplete / total,
      ),
      ProductInsight(
        kind: ProductInsightKind.engagement,
        headline:
            'Questions per engaged session: ${avgPerAsking.toStringAsFixed(1)}',
        detail:
            '$totalAsked questions across $askingSessions engaged sessions.',
        value: avgPerAsking,
      ),
      ProductInsight(
        kind: ProductInsightKind.engagement,
        headline: 'Reflection completion: ${_pct(reflectComplete / total)}',
        detail:
            '$reflectComplete of $total sessions reached the closing '
            'reflection.',
        value: reflectComplete / total,
      ),
    ];
  }

  // --- Drop-off ------------------------------------------------------------

  static ProductInsight? _dropOff(ProductFunnel funnel) {
    final worst = funnel.biggestDropOff;
    if (worst == null) return null;
    final index = ProductFunnelStage.values.indexOf(worst.stage);
    final previous = ProductFunnelStage.values[index - 1];
    final lostShare = 1 - worst.conversionFromPrevious;
    return ProductInsight(
      kind: ProductInsightKind.dropOff,
      headline:
          'Biggest drop-off: ${previous.label} → ${worst.stage.label}',
      detail:
          '${worst.dropOffFromPrevious} sessions stopped here '
          '(${_pct(lostShare)} of those who reached ${previous.label}).',
      value: lostShare,
    );
  }

  // --- Helpers -------------------------------------------------------------

  static int? _median(List<int> values) {
    if (values.isEmpty) return null;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return ((sorted[mid - 1] + sorted[mid]) / 2).round();
  }

  static String _pct(double ratio) => '${(ratio * 100).round()}%';

  static String _secs(int ms) => '${(ms / 1000).toStringAsFixed(1)}s';
}
