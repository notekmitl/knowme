import 'thai_theme_confidence_level.dart';
import 'thai_theme_evidence.dart';

/// UI-ready theme output from [ThaiThemePresenter].
class ThaiPresentedTheme {
  const ThaiPresentedTheme({
    required this.themeId,
    required this.themeName,
    required this.category,
    required this.description,
    required this.score,
    required this.confidence,
    required this.evidence,
  });

  final String themeId;
  final String themeName;
  final String category;
  final String description;
  final double score;
  final ThaiThemeConfidenceLevel confidence;
  final List<ThaiThemeEvidence> evidence;

  @override
  bool operator ==(Object other) {
    return other is ThaiPresentedTheme &&
        other.themeId == themeId &&
        other.themeName == themeName &&
        other.category == category &&
        other.description == description &&
        other.score == score &&
        other.confidence == confidence &&
        _listEquals(other.evidence, evidence);
  }

  @override
  int get hashCode => Object.hash(
        themeId,
        themeName,
        category,
        description,
        score,
        confidence,
        Object.hashAll(evidence),
      );

  static bool _listEquals(List<ThaiThemeEvidence> a, List<ThaiThemeEvidence> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
