/// Confidence tier for Thai Fusion V2 domain models.
enum ThaiFusionConfidenceLevel {
  low,
  medium,
  high;

  String get id {
    return switch (this) {
      ThaiFusionConfidenceLevel.low => 'low',
      ThaiFusionConfidenceLevel.medium => 'medium',
      ThaiFusionConfidenceLevel.high => 'high',
    };
  }
}

ThaiFusionConfidenceLevel? parseThaiFusionConfidenceLevel(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final level in ThaiFusionConfidenceLevel.values) {
    if (level.id == normalized) {
      return level;
    }
  }
  return null;
}
