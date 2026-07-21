import '../domain/entities/astrology_lens.dart';
import '../registry/theme_registry.dart';
import 'lens_theme_output.dart';

/// Shared helpers for real lens adapters (Engine Truth Only).
abstract final class FusionAdapterHelpers {
  static final String westernLensId = AstrologyLens.westernNatal.lensId;
  static final String baziLensId = AstrologyLens.chineseBazi.lensId;
  static final String thaiLensId = AstrologyLens.thaiAstrology.lensId;

  static LensThemeOutput? buildRegistered({
    required String lensId,
    required String themeId,
    required double confidence,
    required List<String> evidence,
  }) {
    if (evidence.isEmpty) return null;

    final theme = FusionThemeRegistry.getById(themeId);
    if (theme == null) return null;

    return LensThemeOutput(
      lensId: lensId,
      themeId: theme.id,
      category: theme.category,
      family: theme.family,
      confidence: confidence,
      evidence: List<String>.unmodifiable(evidence),
    );
  }

  static List<LensThemeOutput> dedupeByTheme(List<LensThemeOutput> outputs) {
    final best = <String, LensThemeOutput>{};

    for (final output in outputs) {
      final key = '${output.lensId}|${output.themeId}';
      final existing = best[key];
      if (existing == null || output.confidence > existing.confidence) {
        best[key] = output;
      }
    }

    return best.values.toList();
  }
}
