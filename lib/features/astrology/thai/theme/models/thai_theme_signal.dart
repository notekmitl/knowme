import 'thai_theme_signal_source.dart';

/// Aggregated theme signal from one or more Thai content lenses.
class ThaiThemeSignal {
  const ThaiThemeSignal({
    required this.themeId,
    required this.score,
    required this.sources,
  });

  final String themeId;
  final double score;
  final List<ThaiThemeSignalSource> sources;

  @override
  bool operator ==(Object other) {
    return other is ThaiThemeSignal &&
        other.themeId == themeId &&
        other.score == score &&
        _listEquals(other.sources, sources);
  }

  @override
  int get hashCode => Object.hash(themeId, score, Object.hashAll(sources));

  static bool _listEquals(
    List<ThaiThemeSignalSource> a,
    List<ThaiThemeSignalSource> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
