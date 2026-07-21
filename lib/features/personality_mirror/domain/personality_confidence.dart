/// Normalized confidence score (0.0–1.0) for lens/theme activations.
typedef PersonalityConfidence = double;

abstract final class PersonalityConfidenceBands {
  static const lowMax = 0.39;
  static const mediumMax = 0.64;
  static const highMax = 0.84;

  static String bandLabel(PersonalityConfidence value) {
    if (value <= lowMax) return 'low';
    if (value <= mediumMax) return 'medium';
    if (value <= highMax) return 'high';
    return 'very_high';
  }

  static double clamp(double value) => value.clamp(0.0, 1.0);
}
