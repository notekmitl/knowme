/// Structural confidence tier for mirror dimensions and insights.
enum ThaiMirrorStructuralConfidence {
  low,
  medium,
  high;

  String get id {
    return switch (this) {
      ThaiMirrorStructuralConfidence.low => 'low',
      ThaiMirrorStructuralConfidence.medium => 'medium',
      ThaiMirrorStructuralConfidence.high => 'high',
    };
  }
}

ThaiMirrorStructuralConfidence? parseThaiMirrorStructuralConfidence(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final level in ThaiMirrorStructuralConfidence.values) {
    if (level.id == normalized) {
      return level;
    }
  }
  return null;
}
