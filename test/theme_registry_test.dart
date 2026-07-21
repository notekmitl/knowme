import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_catalog_v1.dart';
import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_definition.dart';
import 'package:knowme/core/themes/theme_registry.dart';

void main() {
  group('ThemeCatalogV1', () {
    test('has unique theme ids', () {
      final ids = ThemeCatalogV1.all.map((t) => t.id).toList();
      expect(ids.length, equals(ids.toSet().length));
    });

    test('theme count is within V1 target range', () {
      expect(ThemeCatalogV1.all.length, greaterThanOrEqualTo(40));
      expect(ThemeCatalogV1.all.length, lessThanOrEqualTo(60));
    });
  });

  group('ThemeRegistry', () {
    test('getAll returns full catalog', () {
      expect(ThemeRegistry.getAll().length, ThemeCatalogV1.all.length);
    });

    test('getById resolves canonical theme', () {
      final theme = ThemeRegistry.getById('independent');
      expect(theme, isNotNull);
      expect(theme!.name, 'Independent');
      expect(theme.category, ThemeCategory.coreSelf);
    });

    test('getById is case-insensitive', () {
      expect(ThemeRegistry.getById('INDEPENDENT'), isNotNull);
    });

    test('getById returns null for unknown theme', () {
      expect(ThemeRegistry.getById('unknown_theme'), isNull);
    });

    test('getByCategory returns only matching themes', () {
      final themes = ThemeRegistry.getByCategory(ThemeCategory.thinkingStyle);
      expect(themes, isNotEmpty);
      expect(themes.every((t) => t.category == ThemeCategory.thinkingStyle), isTrue);
    });

    test('getByCategoryId resolves by category id string', () {
      final themes = ThemeRegistry.getByCategoryId('growth_path');
      expect(themes, isNotEmpty);
      expect(themes.every((t) => t.category == ThemeCategory.growthPath), isTrue);
    });

    test('every category has at least one theme', () {
      for (final category in ThemeCategory.values) {
        expect(
          ThemeRegistry.getByCategory(category),
          isNotEmpty,
          reason: 'Missing themes for ${category.id}',
        );
      }
    });

    test('version is v1', () {
      expect(ThemeRegistry.version, 'v1');
    });
  });

  group('ThemeDefinition', () {
    test('fromMap and toMap round-trip', () {
      const original = ThemeDefinition(
        id: 'disciplined',
        name: 'Disciplined',
        category: ThemeCategory.coreSelf,
        description: 'Tends to rely on structure.',
      );

      final restored = ThemeDefinition.fromMap(original.toMap());
      expect(restored, original);
    });
  });
}
