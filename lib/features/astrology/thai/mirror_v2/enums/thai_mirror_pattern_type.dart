/// Structural pattern type for [ThaiMirrorInsight].
enum ThaiMirrorPatternType {
  dominantTheme,
  coActivatedThemes,
  sparseCoverage,
  balancedSpread,
}

extension ThaiMirrorPatternTypeLabels on ThaiMirrorPatternType {
  String get id {
    return switch (this) {
      ThaiMirrorPatternType.dominantTheme => 'dominant_theme',
      ThaiMirrorPatternType.coActivatedThemes => 'co_activated_themes',
      ThaiMirrorPatternType.sparseCoverage => 'sparse_coverage',
      ThaiMirrorPatternType.balancedSpread => 'balanced_spread',
    };
  }
}

ThaiMirrorPatternType? parseThaiMirrorPatternType(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final pattern in ThaiMirrorPatternType.values) {
    if (pattern.id == normalized) {
      return pattern;
    }
  }
  return null;
}
