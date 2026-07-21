/// Frequency table for population QA metrics.
class ThaiMirrorPopulationDistribution {
  const ThaiMirrorPopulationDistribution({
    required this.counts,
    required this.total,
    this.label = '',
  });

  final Map<String, int> counts;
  final int total;
  final String label;

  static const empty = ThaiMirrorPopulationDistribution(
    counts: {},
    total: 0,
  );

  List<MapEntry<String, int>> get sortedEntries {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  double share(String key) {
    if (total == 0) return 0;
    return (counts[key] ?? 0) / total;
  }

  double get concentrationIndex {
    if (total == 0) return 0;
    var hhi = 0.0;
    for (final count in counts.values) {
      final share = count / total;
      hhi += share * share;
    }
    return hhi;
  }

  String? get dominantKey {
    if (counts.isEmpty) return null;
    return sortedEntries.first.key;
  }

  double? get dominantShare {
    final key = dominantKey;
    if (key == null) return null;
    return share(key);
  }

  ThaiMirrorPopulationDistribution merge(
    ThaiMirrorPopulationDistribution other,
  ) {
    final merged = Map<String, int>.from(counts);
    for (final entry in other.counts.entries) {
      merged[entry.key] = (merged[entry.key] ?? 0) + entry.value;
    }
    return ThaiMirrorPopulationDistribution(
      counts: merged,
      total: total + other.total,
      label: label,
    );
  }
}
