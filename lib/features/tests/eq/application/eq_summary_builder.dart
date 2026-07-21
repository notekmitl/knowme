import 'package:knowme/core/i18n/app_text.dart';

import '../domain/eq_models.dart';
import '../domain/eq_summary_models.dart';
import '../domain/eq_test_type.dart';

/// Deterministic EQ Summary synthesis (no AI, no scores in copy).
abstract final class EqSummaryBuilder {
  static EqSummaryContent? build(EqSummaryInput input) {
    if (!input.hasAllSix) return null;

    final themeA = _themeBand(
      input.resultFor(EqTestType.stress)!.level,
      input.resultFor(EqTestType.regulation)!.level,
    );
    final themeB = _themeBand(
      input.resultFor(EqTestType.empathy)!.level,
      input.resultFor(EqTestType.social)!.level,
    );
    final themeC = _themeBand(
      input.resultFor(EqTestType.awareness)!.level,
      input.resultFor(EqTestType.decision)!.level,
    );

    final opening = AppText.t(_openingKey(themeA, themeB, themeC));
    final contrast = AppText.t(_contrastKey(themeA, themeB, themeC));
    final closing = AppText.t(_closingKey(themeA, themeB, themeC));
    final narrative = '$opening\n\n$contrast\n\n$closing';

    final weakestTheme = _weakestTheme(themeA, themeB, themeC);

    return EqSummaryContent(
      narrative: narrative,
      guidance: AppText.t('eq_summary_guidance_$weakestTheme'),
      disclosure: AppText.t('eq_summary_disclosure'),
    );
  }

  /// Theme A = stress + regulation, B = empathy + social, C = awareness + decision.
  static String _themeBand(String a, String b) => _weakerLevel(a, b);

  static String _weakerLevel(String a, String b) {
    return _levelRank(a) <= _levelRank(b) ? a : b;
  }

  static int _levelRank(String level) => switch (level) {
        EqLevelIds.emerging => 0,
        EqLevelIds.moderate => 1,
        EqLevelIds.strong => 2,
        _ => 1,
      };

  static String _levelForTheme(String theme, String a, String b, String c) =>
      switch (theme) {
        'a' => a,
        'b' => b,
        _ => c,
      };

  /// Opening: dominant strength (balanced when all three bands match).
  static String _openingKey(String a, String b, String c) {
    if (a == b && b == c) {
      return 'eq_summary_opening_balanced_$a';
    }
    final dominant = _dominantTheme(a, b, c);
    return 'eq_summary_opening_${dominant}_${_levelForTheme(dominant, a, b, c)}';
  }

  /// Contrast: weakest theme band.
  static String _contrastKey(String a, String b, String c) {
    final weakest = _weakestTheme(a, b, c);
    return 'eq_summary_contrast_${weakest}_${_levelForTheme(weakest, a, b, c)}';
  }

  /// Closing: overall weave keyed by weakest level across themes.
  static String _closingKey(String a, String b, String c) {
    return 'eq_summary_closing_${_weakestLevel(a, b, c)}';
  }

  static String _weakestLevel(String a, String b, String c) {
    var weakest = a;
    if (_levelRank(b) < _levelRank(weakest)) weakest = b;
    if (_levelRank(c) < _levelRank(weakest)) weakest = c;
    return weakest;
  }

  /// Tie-break for dominant: C > B > A.
  static String _dominantTheme(String a, String b, String c) {
    final ranked = [
      ('a', a, 1),
      ('b', b, 2),
      ('c', c, 3),
    ]..sort((x, y) {
        final byLevel = _levelRank(y.$2).compareTo(_levelRank(x.$2));
        return byLevel != 0 ? byLevel : y.$3.compareTo(x.$3);
      });
    return ranked.first.$1;
  }

  /// Tie-break for weakest: A > C > B.
  static String _weakestTheme(String a, String b, String c) {
    final ranked = [
      ('a', a, 1),
      ('c', c, 2),
      ('b', b, 3),
    ]..sort((x, y) {
        final byLevel = _levelRank(x.$2).compareTo(_levelRank(y.$2));
        return byLevel != 0 ? byLevel : x.$3.compareTo(y.$3);
      });
    return ranked.first.$1;
  }
}
