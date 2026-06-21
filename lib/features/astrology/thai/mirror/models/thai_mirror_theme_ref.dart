import '../../theme/models/thai_theme_confidence_level.dart';

/// A theme referenced inside a Mirror section or top-themes list.
class ThaiMirrorThemeRef {
  const ThaiMirrorThemeRef({
    required this.themeId,
    required this.themeName,
    required this.score,
    required this.confidence,
    this.description,
  });

  final String themeId;
  final String themeName;
  final double score;
  final ThaiThemeConfidenceLevel confidence;

  /// Short reflective description from [ThemeRegistry] (not predictive).
  final String? description;

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorThemeRef &&
        other.themeId == themeId &&
        other.themeName == themeName &&
        other.score == score &&
        other.confidence == confidence &&
        other.description == description;
  }

  @override
  int get hashCode =>
      Object.hash(themeId, themeName, score, confidence, description);
}
