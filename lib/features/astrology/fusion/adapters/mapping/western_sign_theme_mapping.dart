/// Deterministic zodiac sign → Fusion Theme Registry ids (Western Natal).
abstract final class WesternSignThemeMapping {
  static const Map<String, List<String>> signThemes = {
    'Aries': ['independent', 'driven'],
    'Taurus': ['grounded', 'reliable'],
    'Gemini': ['adaptable', 'analytical'],
    'Cancer': ['supportive', 'responsive'],
    'Leo': ['leadership', 'expressive'],
    'Virgo': ['analytical', 'structured'],
    'Libra': ['diplomatic', 'balance'],
    'Scorpio': ['passionate', 'persistent'],
    'Sagittarius': ['growth_focused', 'independent'],
    'Capricorn': ['responsible', 'driven'],
    'Aquarius': ['independent', 'analytical'],
    'Pisces': ['intuitive', 'responsive'],
  };

  static const Map<String, List<String>> dominantElementThemes = {
    'fire': ['driven', 'passionate'],
    'earth': ['grounded', 'responsible'],
    'air': ['analytical', 'adaptable'],
    'water': ['responsive', 'intuitive'],
  };

  static const Map<String, List<String>> dominantModalityThemes = {
    'cardinal': ['leadership', 'driven'],
    'fixed': ['persistent', 'reliable'],
    'mutable': ['adaptable', 'flexible'],
  };

  static List<String> themesForSign(String sign) {
    return List<String>.unmodifiable(signThemes[sign] ?? const []);
  }
}
