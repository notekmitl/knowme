/// Synthesized meaning from cross-lens fusion (not a reflection repeat).
class FusionInsight {
  const FusionInsight({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

/// Primary + optional tension-derived secondary fusion insight.
class FusionInsightResult {
  const FusionInsightResult({
    this.primary,
    this.secondary,
  });

  final FusionInsight? primary;
  final FusionInsight? secondary;

  bool get hasAny => primary != null || secondary != null;
}
