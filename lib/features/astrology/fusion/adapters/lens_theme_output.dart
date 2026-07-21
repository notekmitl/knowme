import '../domain/entities/fusion_category.dart';
import '../domain/entities/theme_family.dart';

/// Normalized theme output from one astrology lens adapter.
class LensThemeOutput {
  const LensThemeOutput({
    required this.lensId,
    required this.themeId,
    required this.category,
    required this.family,
    required this.confidence,
    required this.evidence,
  });

  /// Stable lens identifier (e.g. `western_natal`). Not limited to known enums.
  final String lensId;
  final String themeId;
  final FusionCategory category;
  final ThemeFamily family;
  final double confidence;
  final List<String> evidence;

  @override
  bool operator ==(Object other) {
    return other is LensThemeOutput &&
        other.lensId == lensId &&
        other.themeId == themeId &&
        other.category == category &&
        other.family == family &&
        other.confidence == confidence &&
        _listEquals(other.evidence, evidence);
  }

  @override
  int get hashCode =>
      Object.hash(lensId, themeId, category, family, confidence, Object.hashAll(evidence));

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
