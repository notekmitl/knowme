/// Global Theme Contract version identifier (GF-F1.5).
abstract final class GlobalThemeContract {
  static const String version = 'global_theme.v1';
}

/// Mapping disposition for theme normalization audit trail.
enum GlobalThemeMappingOutcome {
  normalized,
  rejected,
}

/// Explicit mapping or rejection decision — no silent drops.
class GlobalThemeMappingDecision {
  const GlobalThemeMappingDecision({
    required this.outcome,
    required this.reason,
    this.globalThemeId,
  });

  const GlobalThemeMappingDecision.normalized({
    required String globalThemeId,
    required this.reason,
  })  : outcome = GlobalThemeMappingOutcome.normalized,
        globalThemeId = globalThemeId;

  const GlobalThemeMappingDecision.rejected({
    required this.reason,
  })  : outcome = GlobalThemeMappingOutcome.rejected,
        globalThemeId = null;

  final GlobalThemeMappingOutcome outcome;
  final String? globalThemeId;
  final String reason;

  bool get isNormalized => outcome == GlobalThemeMappingOutcome.normalized;
  bool get isRejected => outcome == GlobalThemeMappingOutcome.rejected;
}

/// One row in the theme coverage matrix (GF-F1.5 audit output).
class ThemeCoverageRow {
  const ThemeCoverageRow({
    required this.sourceLayer,
    required this.sourceKind,
    required this.sourceId,
    this.themeFamily,
    required this.outcome,
    this.globalThemeId,
    required this.reason,
  });

  final String sourceLayer;
  final String sourceKind;
  final String sourceId;
  final String? themeFamily;
  final GlobalThemeMappingOutcome outcome;
  final String? globalThemeId;
  final String reason;
}
