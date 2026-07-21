import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

/// Opposing family pairs for tension detection.
abstract final class PersonalityOpposingFamily {
  static const opposingPairs = <(ThemeFamily, ThemeFamily)>[
    (ThemeFamily.expression, ThemeFamily.reflection),
    (ThemeFamily.structure, ThemeFamily.adaptation),
  ];

  static bool areOpposing(ThemeFamily a, ThemeFamily b) {
    if (a == b) return false;
    for (final pair in opposingPairs) {
      if ((pair.$1 == a && pair.$2 == b) || (pair.$1 == b && pair.$2 == a)) {
        return true;
      }
    }
    return false;
  }

  static bool hasOpposingPair(Set<ThemeFamily> families) {
    final list = families.toList();
    for (var i = 0; i < list.length; i++) {
      for (var j = i + 1; j < list.length; j++) {
        if (areOpposing(list[i], list[j])) return true;
      }
    }
    return false;
  }

  static String? reasonCodeFor(ThemeFamily a, ThemeFamily b) {
    if (!areOpposing(a, b)) return null;
    final ids = [a, b].map((f) => _familyId(f)).toList()..sort();
    return 'opposing_families.${ids.join('_')}';
  }

  static String _familyId(ThemeFamily family) => switch (family) {
        ThemeFamily.expression => 'expression',
        ThemeFamily.reflection => 'reflection',
        ThemeFamily.structure => 'structure',
        ThemeFamily.adaptation => 'adaptation',
        ThemeFamily.autonomy => 'autonomy',
        ThemeFamily.connection => 'connection',
      };
}
