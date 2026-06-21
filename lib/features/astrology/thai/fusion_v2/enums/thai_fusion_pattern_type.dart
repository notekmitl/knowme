/// Structural synthesis pattern for [ThaiFusionInsight].
enum ThaiFusionPatternType {
  crossLayerAgreement,
  crossLayerTension,
  themeFactReinforcement,
  dimensionThemeAlignment,
  coverageGap,
  sparseFusionCoverage,
}

extension ThaiFusionPatternTypeLabels on ThaiFusionPatternType {
  String get id {
    return switch (this) {
      ThaiFusionPatternType.crossLayerAgreement => 'cross_layer_agreement',
      ThaiFusionPatternType.crossLayerTension => 'cross_layer_tension',
      ThaiFusionPatternType.themeFactReinforcement => 'theme_fact_reinforcement',
      ThaiFusionPatternType.dimensionThemeAlignment => 'dimension_theme_alignment',
      ThaiFusionPatternType.coverageGap => 'coverage_gap',
      ThaiFusionPatternType.sparseFusionCoverage => 'sparse_fusion_coverage',
    };
  }
}

ThaiFusionPatternType? parseThaiFusionPatternType(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final pattern in ThaiFusionPatternType.values) {
    if (pattern.id == normalized) {
      return pattern;
    }
  }
  return null;
}
