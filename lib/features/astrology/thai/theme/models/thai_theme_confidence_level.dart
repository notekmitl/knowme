/// Deterministic confidence tier for a [ThaiThemeResult].
enum ThaiThemeConfidenceLevel {
  low,
  medium,
  high;

  String get id {
    return switch (this) {
      ThaiThemeConfidenceLevel.low => 'low',
      ThaiThemeConfidenceLevel.medium => 'medium',
      ThaiThemeConfidenceLevel.high => 'high',
    };
  }
}
