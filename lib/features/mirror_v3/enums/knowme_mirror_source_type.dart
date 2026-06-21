/// Theme source class for mirror evidence.
enum KnowMeMirrorSourceType {
  astrologyTheme,
  mbtiTheme,
  bigFiveTheme,
  eqTheme,
  compositeTheme,
}

extension KnowMeMirrorSourceTypeLabels on KnowMeMirrorSourceType {
  String get id {
    return switch (this) {
      KnowMeMirrorSourceType.astrologyTheme => 'astrology_theme',
      KnowMeMirrorSourceType.mbtiTheme => 'mbti_theme',
      KnowMeMirrorSourceType.bigFiveTheme => 'big_five_theme',
      KnowMeMirrorSourceType.eqTheme => 'eq_theme',
      KnowMeMirrorSourceType.compositeTheme => 'composite_theme',
    };
  }
}

KnowMeMirrorSourceType? parseKnowMeMirrorSourceType(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final sourceType in KnowMeMirrorSourceType.values) {
    if (sourceType.id == normalized) {
      return sourceType;
    }
  }
  return null;
}
