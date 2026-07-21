import '../content/models/thai_content_type.dart';
import '../theme/models/thai_presented_theme.dart';
import 'models/thai_mirror_theme_ref.dart';

/// Mirror-layer top theme selection — does not alter Theme Engine scores.
abstract final class ThaiMirrorTopThemeSelector {
  static const _leadershipId = 'leadership';

  static List<ThaiMirrorThemeRef> select({
    required List<ThaiPresentedTheme> sortedThemes,
    required int limit,
    required ThaiMirrorThemeRef Function(ThaiPresentedTheme) toRef,
  }) {
    if (sortedThemes.isEmpty) return const [];

    final pool = sortedThemes.take(limit + 4).toList(growable: false);
    final first = _pickFirst(pool);
    final ordered = <ThaiPresentedTheme>[first];

    for (final theme in pool) {
      if (theme.themeId == first.themeId) continue;
      ordered.add(theme);
      if (ordered.length >= limit) break;
    }

    return ordered.map(toRef).toList(growable: false);
  }

  static ThaiPresentedTheme _pickFirst(List<ThaiPresentedTheme> pool) {
    if (pool.isEmpty) {
      throw StateError('Cannot pick top theme from empty pool');
    }

    final top = pool.first;
    if (top.themeId != _leadershipId || pool.length == 1) {
      return top;
    }

    ThaiPresentedTheme? bestAlternative;
    for (final candidate in pool.skip(1)) {
      if (candidate.themeId == _leadershipId) continue;
      if (_mahabhutaEvidenceShare(candidate) >= 0.75) continue;

      if (bestAlternative == null ||
          candidate.score > bestAlternative.score) {
        bestAlternative = candidate;
      }
    }

    if (bestAlternative == null) return top;
    if (top.score - bestAlternative.score <= 0.18) {
      return bestAlternative;
    }

    return top;
  }

  static double _mahabhutaEvidenceShare(ThaiPresentedTheme theme) {
    if (theme.evidence.isEmpty) return 0;

    var mahabhuta = 0;
    for (final evidence in theme.evidence) {
      if (evidence.sourceType == ThaiContentType.mahabhutaPosition) {
        mahabhuta++;
      }
    }
    return mahabhuta / theme.evidence.length;
  }
}
