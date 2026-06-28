import 'product_validation_events.dart';

/// One funnel stage's aggregate result across many sessions.
class ProductFunnelStageResult {
  const ProductFunnelStageResult({
    required this.stage,
    required this.reachedCount,
    required this.conversionFromStart,
    required this.conversionFromPrevious,
    required this.dropOffFromPrevious,
  });

  final ProductFunnelStage stage;

  /// Sessions that reached this stage.
  final int reachedCount;

  /// Share of all sessions that reached this stage (0..1).
  final double conversionFromStart;

  /// Share of the previous stage's sessions that continued to this one (0..1).
  final double conversionFromPrevious;

  /// Sessions lost between the previous stage and this one.
  final int dropOffFromPrevious;
}

/// Phase A — the engagement funnel aggregated over a set of sessions.
///
/// This is where "where do users stop?" is answered: the stage with the largest
/// [dropOffFromPrevious] is the biggest leak.
class ProductFunnel {
  const ProductFunnel({
    required this.totalSessions,
    required this.stages,
  });

  final int totalSessions;
  final List<ProductFunnelStageResult> stages;

  /// Builds the funnel from sessions (each a chronological event list).
  factory ProductFunnel.fromSessions(List<List<ProductEvent>> sessions) {
    final total = sessions.length;
    final results = <ProductFunnelStageResult>[];

    int? previousReached;
    for (final stage in ProductFunnelStage.values) {
      final reached = sessions
          .where((s) => s.any((e) => e.type == stage.trigger))
          .length;

      final fromPrev = previousReached == null
          ? (total == 0 ? 0.0 : reached / total)
          : (previousReached == 0 ? 0.0 : reached / previousReached);
      final dropOff =
          previousReached == null ? 0 : (previousReached - reached).clamp(0, total);

      results.add(ProductFunnelStageResult(
        stage: stage,
        reachedCount: reached,
        conversionFromStart: total == 0 ? 0.0 : reached / total,
        conversionFromPrevious: fromPrev,
        dropOffFromPrevious: dropOff,
      ));
      previousReached = reached;
    }

    return ProductFunnel(totalSessions: total, stages: results);
  }

  /// The stage where the most sessions are lost (excludes the first stage).
  ProductFunnelStageResult? get biggestDropOff {
    ProductFunnelStageResult? worst;
    for (final r in stages) {
      if (r.stage == ProductFunnelStage.home) continue;
      if (worst == null || r.dropOffFromPrevious > worst.dropOffFromPrevious) {
        worst = r;
      }
    }
    if (worst == null || worst.dropOffFromPrevious == 0) return null;
    return worst;
  }
}
