import '../domain/human_dimension.dart';

/// Frozen canonical dimension catalog (HM2).
abstract final class HumanDimensionCatalog {
  static const dimensions = HumanDimensionId.values;

  static List<HumanDimensionId> allDimensions() {
    return List<HumanDimensionId>.unmodifiable(dimensions);
  }
}
