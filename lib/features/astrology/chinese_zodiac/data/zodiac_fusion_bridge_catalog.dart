/// Theme Foundation id → Fusion Theme Registry id(s).
///
/// Deterministic semantic bridge — does not expand either registry.
abstract final class ZodiacFusionBridgeCatalog {
  static const Map<String, List<String>> foundationToFusion = {
    // --- Core Self ---
    'independent': ['independent'],
    'disciplined': ['structured', 'responsible'],
    'curious': ['adaptable', 'openness'],
    'practical': ['grounded', 'responsible'],
    'grounded': ['grounded'],
    'visionary': ['driven', 'growth_focused'],
    'protective': ['loyal', 'supportive'],
    'adaptable': ['adaptable'],
    'creative': ['creative'],
    'ambitious': ['driven', 'leadership'],

    // --- Thinking Style ---
    'analytical': ['analytical'],
    'strategic': ['analytical', 'structured'],
    'reflective': ['reflection', 'reserved'],
    'big_picture': ['intuitive', 'analytical'],
    'detail_oriented': ['structured', 'analytical', 'reliable'],
    'fast_moving': ['flexible', 'impatience'],
    'systematic': ['structured'],

    // --- Emotional World ---
    'empathetic': ['responsive', 'supportive', 'reliable'],
    'sensitive': ['responsive', 'passionate'],
    'stable': ['calm', 'grounded'],
    'expressive': ['expressive'],
    'reserved': ['reserved'],
    'calm_under_pressure': ['calm'],

    // --- Relationships ---
    'loyal': ['loyal'],
    'supportive': ['supportive'],
    'relationship_oriented': ['supportive', 'diplomatic'],
    'independent_in_relationships': ['independent_connection'],
    'protective_of_others': ['supportive', 'loyal'],
    'diplomatic': ['diplomatic'],

    // --- Work & Ambition ---
    'builder': ['responsible', 'reliable'],
    'leader': ['leadership'],
    'explorer': ['growth_focused', 'driven'],
    'specialist': ['structured', 'analytical'],
    'teacher': ['supportive', 'growth_focused'],
    'entrepreneurial': ['driven', 'growth_focused'],
    'innovator': ['creative', 'growth_focused'],

    // --- Strengths ---
    'persistence': ['persistent'],
    'communication': ['creative', 'expressive'],
    'adaptability': ['adaptable', 'creative'],
    'leadership': ['leadership'],
    'creativity': ['creative'],
    'empathy': ['supportive', 'responsive'],
    'reliability': ['reliable'],

    // --- Growth Areas ---
    'perfectionism': ['rigidity', 'overthinking'],
    'impulsiveness': ['impatience'],
    'overthinking': ['overthinking'],
    'avoidance': ['overthinking', 'rigidity'],
    'self_criticism': ['overthinking', 'rigidity'],
    'control': ['rigidity'],
    'people_pleasing': ['rigidity', 'balance'],

    // --- Growth Path ---
    'embrace_change': ['openness'],
    'develop_patience': ['reflection', 'balance'],
    'express_emotions_more_freely': ['expressive', 'openness'],
    'balance_structure_with_flexibility': ['balance', 'flexible'],
    'open_to_collaboration': ['openness', 'supportive'],
    'trust_yourself_more': ['reflection'],
  };

  static List<String> fusionThemesForFoundation(String foundationThemeId) {
    return List<String>.unmodifiable(
      foundationToFusion[foundationThemeId.trim().toLowerCase()] ?? const [],
    );
  }
}
