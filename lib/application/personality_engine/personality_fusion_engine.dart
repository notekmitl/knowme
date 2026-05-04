class PersonalityFusionEngine {
  static Map<String, double> normalizeTraits(Map<String, double> traits) {
    double maxValue = traits.values.fold(0, (a, b) => a > b ? a : b);

    if (maxValue == 0) return traits;

    final Map<String, double> normalized = {};

    traits.forEach((trait, value) {
      normalized[trait] = value / maxValue;
    });

    return normalized;
  }
}
