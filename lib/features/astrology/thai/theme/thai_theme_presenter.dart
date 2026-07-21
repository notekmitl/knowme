import '../../../../core/themes/theme_category.dart';
import '../../../../core/themes/theme_registry.dart';
import 'models/thai_presented_theme.dart';
import 'models/thai_theme_result.dart';

/// Presents engine results with human-readable labels from [ThemeRegistry].
abstract final class ThaiThemePresenter {
  static List<ThaiPresentedTheme> present(List<ThaiThemeResult> results) {
    final presented = <ThaiPresentedTheme>[];

    for (final result in results) {
      final definition = ThemeRegistry.getById(result.themeId);
      if (definition == null) continue;

      presented.add(
        ThaiPresentedTheme(
          themeId: result.themeId,
          themeName: definition.name,
          category: definition.category.displayName,
          description: definition.description,
          score: result.score,
          confidence: result.confidence,
          evidence: result.evidence,
        ),
      );
    }

    return presented;
  }
}
