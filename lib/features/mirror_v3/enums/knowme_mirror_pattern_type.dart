/// Structural pattern types detected by MV1 engines.
enum KnowMeMirrorPatternType {
  crossSystemAgreement,
  crossLensAgreement,
  crossSystemTension,
  crossLensTension,
  themeFactReinforcement,
  dimensionCoverageGap,
  singleSourceBlindSpot,
}

extension KnowMeMirrorPatternTypeLabels on KnowMeMirrorPatternType {
  String get id {
    return switch (this) {
      KnowMeMirrorPatternType.crossSystemAgreement => 'cross_system_agreement',
      KnowMeMirrorPatternType.crossLensAgreement => 'cross_lens_agreement',
      KnowMeMirrorPatternType.crossSystemTension => 'cross_system_tension',
      KnowMeMirrorPatternType.crossLensTension => 'cross_lens_tension',
      KnowMeMirrorPatternType.themeFactReinforcement =>
        'theme_fact_reinforcement',
      KnowMeMirrorPatternType.dimensionCoverageGap => 'dimension_coverage_gap',
      KnowMeMirrorPatternType.singleSourceBlindSpot =>
        'single_source_blind_spot',
    };
  }
}
