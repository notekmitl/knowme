import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';

import '../data/zodiac_personality_library.dart';
import '../data/zodiac_theme_calibration_catalog.dart';
import '../domain/zodiac_fusion_readiness_signals.dart';
import '../domain/zodiac_theme_weight_model.dart';
import '../domain/zodiac_theme_weight_tier.dart';

/// Resolves Year Animal theme calibration from Theme Foundation ids.
abstract final class ZodiacThemeCalibrationResolver {
  static ZodiacThemeWeightModel? forAnimal(String animalKey) {
    return ZodiacThemeCalibrationCatalog.byAnimal[animalKey.trim().toLowerCase()];
  }

  static List<String> themesForAnimal(
    String animalKey, {
    ZodiacThemeWeightTier? tier,
    bool includeWeak = true,
  }) {
    final model = forAnimal(animalKey);
    if (model == null) return const [];

    if (tier != null) {
      return List<String>.unmodifiable(model.themesForTier(tier));
    }

    return model.allThemes(includeWeak: includeWeak);
  }

  static ZodiacFusionReadinessSignals fusionReadinessForAnimal(String animalKey) {
    final model = forAnimal(animalKey);
    if (model == null) {
      return const ZodiacFusionReadinessSignals(
        coreSelf: [],
        relationships: [],
        workAndAmbition: [],
        strengths: [],
        growthAreas: [],
      );
    }

    return _buildFusionSignals(model);
  }

  static ZodiacFusionReadinessSignals _buildFusionSignals(
    ZodiacThemeWeightModel model,
  ) {
    final coreSelf = <String>[];
    final relationships = <String>[];
    final workAndAmbition = <String>[];
    final strengths = <String>[];
    final growthAreas = <String>[];

    void collect(Iterable<String> themeIds) {
      for (final id in themeIds) {
        final theme = ThemeRegistry.getById(id);
        if (theme == null) continue;

        switch (theme.category) {
          case ThemeCategory.coreSelf:
          case ThemeCategory.emotionalWorld:
            coreSelf.add(id);
          case ThemeCategory.relationships:
            relationships.add(id);
          case ThemeCategory.workAndAmbition:
          case ThemeCategory.thinkingStyle:
            workAndAmbition.add(id);
          case ThemeCategory.strengths:
            strengths.add(id);
          case ThemeCategory.growthAreas:
          case ThemeCategory.growthPath:
            growthAreas.add(id);
        }
      }
    }

    collect(model.primary);
    collect(model.secondary);

    // Growth shadow signals: include weak-tier growth-related themes only.
    for (final id in model.weak) {
      final theme = ThemeRegistry.getById(id);
      if (theme == null) continue;
      if (theme.category == ThemeCategory.growthAreas ||
          theme.category == ThemeCategory.growthPath) {
        growthAreas.add(id);
      }
    }

    return ZodiacFusionReadinessSignals(
      coreSelf: List<String>.unmodifiable(coreSelf),
      relationships: List<String>.unmodifiable(relationships),
      workAndAmbition: List<String>.unmodifiable(workAndAmbition),
      strengths: List<String>.unmodifiable(strengths),
      growthAreas: List<String>.unmodifiable(growthAreas),
    );
  }

  static bool isCalibrated(String animalKey) {
    return forAnimal(animalKey) != null;
  }

  static Iterable<String> get supportedAnimals =>
      ZodiacPersonalityLibrary.supportedAnimals;
}
