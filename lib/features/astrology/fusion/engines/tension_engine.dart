import '../adapters/lens_theme_output.dart';
import '../domain/entities/fusion_category.dart';
import '../domain/entities/fusion_tension.dart';
import '../registry/theme_registry.dart';

/// Detects category-level divergent themes across lenses.
abstract final class TensionEngine {
  static List<FusionTension> detect(List<LensThemeOutput> outputs) {
    final known = outputs
        .where((output) => FusionThemeRegistry.contains(output.themeId))
        .toList();

    final byCategory = <FusionCategory, List<LensThemeOutput>>{};
    for (final output in known) {
      byCategory.putIfAbsent(output.category, () => []).add(output);
    }

    final tensions = <FusionTension>[];
    for (final entry in byCategory.entries) {
      final themes = entry.value
          .map((output) => output.themeId.trim().toLowerCase())
          .toSet();
      final lenses = entry.value.map((output) => output.lensId).toSet();

      if (themes.length < 2 || lenses.length < 2) continue;

      final perspectives = <FusionTensionPerspective>[];
      final seenLens = <String>{};

      for (final output in entry.value) {
        if (!seenLens.add(output.lensId)) continue;
        perspectives.add(
          FusionTensionPerspective(
            lensId: output.lensId,
            themeId: output.themeId.trim().toLowerCase(),
          ),
        );
      }

      if (perspectives.length < 2) continue;

      tensions.add(
        FusionTension(
          category: entry.key,
          perspectives: perspectives,
        ),
      );
    }

    return tensions;
  }
}
