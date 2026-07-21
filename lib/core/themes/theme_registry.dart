import 'theme_catalog_v1.dart';
import 'theme_category.dart';
import 'theme_definition.dart';

/// Read-only registry for Canonical Theme Dictionary V1.
abstract final class ThemeRegistry {
  static final Map<String, ThemeDefinition> _byId = {
    for (final theme in ThemeCatalogV1.all) theme.id: theme,
  };

  static final Map<ThemeCategory, List<ThemeDefinition>> _byCategory = {
    for (final category in ThemeCategory.values)
      category: ThemeCatalogV1.all
          .where((theme) => theme.category == category)
          .toList(),
  };

  /// Dictionary schema version for downstream consumers.
  static const String version = 'v1';

  static List<ThemeDefinition> getAll() {
    return List<ThemeDefinition>.unmodifiable(ThemeCatalogV1.all);
  }

  static ThemeDefinition? getById(String id) {
    return _byId[id.trim().toLowerCase()];
  }

  static List<ThemeDefinition> getByCategory(ThemeCategory category) {
    return List<ThemeDefinition>.unmodifiable(
      _byCategory[category] ?? const [],
    );
  }

  static List<ThemeDefinition> getByCategoryId(String categoryId) {
    final category = parseThemeCategory(categoryId);
    if (category == null) return const [];
    return getByCategory(category);
  }

  static bool contains(String id) => _byId.containsKey(id.trim().toLowerCase());

  static int get count => ThemeCatalogV1.all.length;
}
