/// Content families supported by the Thai Astrology content library.
enum ThaiContentType {
  lagna,
  lagnaLord,
  ramahabhuta,
  mahabhutaPosition,
  myanmarSeven,
}

extension ThaiContentTypeLabels on ThaiContentType {
  String get id {
    switch (this) {
      case ThaiContentType.lagna:
        return 'lagna';
      case ThaiContentType.lagnaLord:
        return 'lagna_lord';
      case ThaiContentType.ramahabhuta:
        return 'ramahabhuta';
      case ThaiContentType.mahabhutaPosition:
        return 'mahabhuta_position';
      case ThaiContentType.myanmarSeven:
        return 'myanmar_seven';
    }
  }

}

ThaiContentType? parseThaiContentType(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final type in ThaiContentType.values) {
    if (type.id == normalized) return type;
  }
  return null;
}
