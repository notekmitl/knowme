import 'product_funnel.dart';

/// The kind of product signal an insight represents.
enum ProductInsightKind {
  /// Did users hit the WOW moment, and how fast?
  wow,

  /// Where did users become curious (expand, explore)?
  curiosity,

  /// Where did users become engaged (ask, complete, return)?
  engagement,

  /// Where did users stop?
  dropOff,
}

/// One product-level insight (about the product, never about a specific user).
class ProductInsight {
  const ProductInsight({
    required this.kind,
    required this.headline,
    required this.detail,
    this.value,
  });

  final ProductInsightKind kind;
  final String headline;
  final String detail;

  /// Optional numeric backing (a rate 0..1, a count, or a duration in ms).
  final num? value;
}

/// Phase A — the full product-validation read for a set of sessions.
class ProductInsights {
  const ProductInsights({
    required this.sessionCount,
    required this.funnel,
    required this.insights,
    required this.returnVisit,
  });

  final int sessionCount;
  final ProductFunnel funnel;
  final List<ProductInsight> insights;

  /// True once more than one session has been observed.
  final bool returnVisit;

  List<ProductInsight> ofKind(ProductInsightKind kind) =>
      [for (final i in insights) if (i.kind == kind) i];
}
