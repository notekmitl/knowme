import 'package:knowme/features/human_model/domain/human_dimension.dart';

/// HP1 — canonical pattern taxonomy grouped by human dimension.
abstract final class HumanPatternTaxonomy {
  static const dimensionOrder = HumanDimensionId.values;

  static Map<HumanDimensionId, List<String>> groupByDimension(
    Iterable<String> patternIds,
    String? Function(String patternId) dimensionForPattern,
  ) {
    final grouped = <HumanDimensionId, List<String>>{
      for (final dimension in dimensionOrder) dimension: [],
    };

    for (final patternId in patternIds) {
      final dimensionKey = dimensionForPattern(patternId);
      if (dimensionKey == null) continue;
      final dimension = parseHumanDimensionId(dimensionKey);
      if (dimension == null) continue;
      grouped[dimension]!.add(patternId);
    }

    for (final entry in grouped.entries) {
      entry.value.sort();
    }

    return grouped;
  }
}
