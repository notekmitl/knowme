import 'models/thai_theme_confidence_level.dart';

/// Deterministic confidence rules for Thai Theme Engine V1.
///
/// Confidence is derived only from [sourceCount] and [totalScore].
abstract final class ThaiThemeConfidenceRules {
  /// Minimum score for medium confidence with a single source.
  static const double mediumScoreThreshold = 1.0;

  /// Minimum score for high confidence with two corroborating sources.
  static const double highScoreThreshold = 1.5;

  /// Minimum distinct sources for high confidence on corroboration alone.
  static const int highSourceCountThreshold = 3;

  /// Minimum distinct sources for medium confidence via corroboration.
  static const int mediumSourceCountThreshold = 2;

  static ThaiThemeConfidenceLevel evaluate({
    required int sourceCount,
    required double totalScore,
  }) {
    if (sourceCount >= highSourceCountThreshold ||
        (sourceCount >= mediumSourceCountThreshold &&
            totalScore >= highScoreThreshold)) {
      return ThaiThemeConfidenceLevel.high;
    }

    if (sourceCount >= mediumSourceCountThreshold ||
        totalScore >= mediumScoreThreshold) {
      return ThaiThemeConfidenceLevel.medium;
    }

    return ThaiThemeConfidenceLevel.low;
  }
}
