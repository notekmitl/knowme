import 'thai_theme_confidence_level.dart';
import 'thai_theme_evidence.dart';

/// Mirror-ready theme output from [ThaiThemeEngine].
class ThaiThemeResult {
  const ThaiThemeResult({
    required this.themeId,
    required this.score,
    required this.confidence,
    required this.evidence,
  });

  final String themeId;
  final double score;
  final ThaiThemeConfidenceLevel confidence;
  final List<ThaiThemeEvidence> evidence;

  @override
  bool operator ==(Object other) {
    return other is ThaiThemeResult &&
        other.themeId == themeId &&
        other.score == score &&
        other.confidence == confidence &&
        _listEquals(other.evidence, evidence);
  }

  @override
  int get hashCode =>
      Object.hash(themeId, score, confidence, Object.hashAll(evidence));

  static bool _listEquals(List<ThaiThemeEvidence> a, List<ThaiThemeEvidence> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
