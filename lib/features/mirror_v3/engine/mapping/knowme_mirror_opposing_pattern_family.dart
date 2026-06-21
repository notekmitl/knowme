/// Opposing pattern families for MV1 tension detection.
abstract final class KnowMeMirrorOpposingPatternFamily {
  static const opposingPairs = <(String, String)>[
    ('self_expression', 'self_identity'),
    ('thinking_pattern', 'emotional_pattern'),
    ('action_style', 'structure_pattern'),
    ('relational_pattern', 'support_pattern'),
  ];

  static bool areOpposing(String a, String b) {
    if (a == b) return false;
    for (final pair in opposingPairs) {
      if ((pair.$1 == a && pair.$2 == b) || (pair.$1 == b && pair.$2 == a)) {
        return true;
      }
    }
    return false;
  }

  static String? reasonCodeFor(String a, String b) {
    if (!areOpposing(a, b)) return null;
    final ids = [a, b]..sort();
    return 'opposing_pattern_families.${ids.join('_')}';
  }
}
