class TraitEngine {
  static Map<String, double> mergeTraits(List<Map<String, double>> traitSets) {
    final Map<String, double> result = {};

    for (var set in traitSets) {
      set.forEach((trait, value) {
        result[trait] = (result[trait] ?? 0) + value;
      });
    }

    return result;
  }
}
