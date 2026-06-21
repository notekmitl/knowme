import 'fusion_category.dart';

/// One lens perspective inside a category-level tension cluster.
class FusionTensionPerspective {
  const FusionTensionPerspective({
    required this.lensId,
    required this.themeId,
  });

  final String lensId;
  final String themeId;
}

/// Divergent themes within the same fusion category across lenses.
class FusionTension {
  const FusionTension({
    required this.category,
    required this.perspectives,
  });

  final FusionCategory category;
  final List<FusionTensionPerspective> perspectives;
}
