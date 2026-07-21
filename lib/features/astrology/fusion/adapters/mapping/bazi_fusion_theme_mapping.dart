/// Deterministic BaZi engine fields → Fusion Theme Registry ids.
abstract final class BaziFusionThemeMapping {
  static const Map<String, List<String>> dayMasterThemes = {
    'yang_wood': ['growth_focused', 'leadership'],
    'yin_wood': ['adaptable', 'supportive'],
    'yang_fire': ['driven', 'passionate'],
    'yin_fire': ['expressive', 'responsive'],
    'yang_earth': ['responsible', 'reliable'],
    'yin_earth': ['grounded', 'persistent'],
    'yang_metal': ['structured', 'analytical'],
    'yin_metal': ['reserved', 'analytical'],
    'yang_water': ['intuitive', 'adaptable'],
    'yin_water': ['calm', 'reflection'],
  };

  static const Map<String, String> dominantElementTheme = {
    'wood': 'growth_focused',
    'fire': 'driven',
    'earth': 'grounded',
    'metal': 'structured',
    'water': 'intuitive',
  };

  static const Map<String, String> balanceStrengthTheme = {
    'wood': 'growth_focused',
    'fire': 'passionate',
    'earth': 'reliable',
    'metal': 'persistent',
    'water': 'calm',
  };

  static String dayMasterKey({
    required String polarity,
    required String element,
  }) {
    return '${polarity.trim().toLowerCase()}_${element.trim().toLowerCase()}';
  }

  static List<String> themesForDayMaster({
    required String polarity,
    required String element,
  }) {
    return List<String>.unmodifiable(
      dayMasterThemes[dayMasterKey(polarity: polarity, element: element)] ??
          const [],
    );
  }
}
