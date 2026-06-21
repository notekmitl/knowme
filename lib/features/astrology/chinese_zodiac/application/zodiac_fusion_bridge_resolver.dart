import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';

import '../data/zodiac_fusion_bridge_catalog.dart';
import '../domain/zodiac_fusion_bridge_signal.dart';
import '../domain/zodiac_fusion_signal_bundle.dart';
import '../domain/zodiac_fusion_signal_weight.dart';
import '../domain/zodiac_theme_weight_tier.dart';
import 'zodiac_theme_calibration_resolver.dart';

/// Converts calibrated Year Animal themes into Fusion-ready signal bundles.
abstract final class ZodiacFusionBridgeResolver {
  static ZodiacFusionSignalWeight weightForTier(ZodiacThemeWeightTier tier) {
    return switch (tier) {
      ZodiacThemeWeightTier.primary => ZodiacFusionSignalWeight.full,
      ZodiacThemeWeightTier.secondary => ZodiacFusionSignalWeight.reduced,
      ZodiacThemeWeightTier.weak => ZodiacFusionSignalWeight.growthOnly,
    };
  }

  static ZodiacFusionSignalBundle bundleForAnimal(String animalKey) {
    final model = ZodiacThemeCalibrationResolver.forAnimal(animalKey);
    if (model == null) {
      return ZodiacFusionSignalBundle(animalKey: animalKey, signals: const []);
    }

    final merged = <String, ZodiacFusionBridgeSignal>{};

    void addFromTier(
      Iterable<String> foundationIds,
      ZodiacThemeWeightTier tier,
    ) {
      final weight = weightForTier(tier);

      for (final foundationId in foundationIds) {
        for (final fusionId in ZodiacFusionBridgeCatalog.fusionThemesForFoundation(
          foundationId,
        )) {
          if (!_isAllowedForTier(fusionId, tier)) continue;

          final signal = ZodiacFusionBridgeSignal(
            fusionThemeId: fusionId,
            foundationThemeId: foundationId,
            sourceTier: tier,
            weight: weight,
          );

          final existing = merged[fusionId];
          if (existing == null ||
              fusionWeightOutranks(signal.weight, existing.weight)) {
            merged[fusionId] = signal;
          }
        }
      }
    }

    addFromTier(model.primary, ZodiacThemeWeightTier.primary);
    addFromTier(model.secondary, ZodiacThemeWeightTier.secondary);
    addFromTier(model.weak, ZodiacThemeWeightTier.weak);

    return ZodiacFusionSignalBundle(
      animalKey: model.animalKey,
      signals: List<ZodiacFusionBridgeSignal>.unmodifiable(merged.values),
    );
  }

  static bool _isAllowedForTier(String fusionThemeId, ZodiacThemeWeightTier tier) {
    if (tier != ZodiacThemeWeightTier.weak) return true;

    final fusionTheme = FusionThemeRegistry.getById(fusionThemeId);
    if (fusionTheme == null) return false;

    return fusionTheme.category == FusionCategory.growthAreas ||
        fusionTheme.category == FusionCategory.growthPath;
  }

  static Map<String, ZodiacFusionSignalBundle> allBundles() {
    return Map<String, ZodiacFusionSignalBundle>.unmodifiable({
      for (final animal in ZodiacThemeCalibrationResolver.supportedAnimals)
        animal: bundleForAnimal(animal),
    });
  }

  static List<String> fusionIdsForAnimal(
    String animalKey, {
    ZodiacFusionSignalWeight? weight,
  }) {
    return bundleForAnimal(animalKey).fusionThemeIds(weight: weight);
  }
}

/// Grouped Fusion Registry ids by the five zodiac fusion readiness dimensions.
class ZodiacFusionBridgeDimensionBundle {
  const ZodiacFusionBridgeDimensionBundle({
    required this.coreSelf,
    required this.relationships,
    required this.workAndAmbition,
    required this.strengths,
    required this.growthAreas,
  });

  final List<ZodiacFusionBridgeSignal> coreSelf;
  final List<ZodiacFusionBridgeSignal> relationships;
  final List<ZodiacFusionBridgeSignal> workAndAmbition;
  final List<ZodiacFusionBridgeSignal> strengths;
  final List<ZodiacFusionBridgeSignal> growthAreas;

  bool get isFullyCovered =>
      coreSelf.isNotEmpty &&
      relationships.isNotEmpty &&
      workAndAmbition.isNotEmpty &&
      strengths.isNotEmpty &&
      growthAreas.isNotEmpty;
}

extension ZodiacFusionSignalBundleDimensions on ZodiacFusionSignalBundle {
  ZodiacFusionBridgeDimensionBundle toDimensionBundle() {
    final coreSelf = <ZodiacFusionBridgeSignal>[];
    final relationships = <ZodiacFusionBridgeSignal>[];
    final workAndAmbition = <ZodiacFusionBridgeSignal>[];
    final strengths = <ZodiacFusionBridgeSignal>[];
    final growthAreas = <ZodiacFusionBridgeSignal>[];

    for (final signal in signals) {
      final fusionTheme = FusionThemeRegistry.getById(signal.fusionThemeId);
      if (fusionTheme == null) continue;

      switch (fusionTheme.category) {
        case FusionCategory.coreSelf:
        case FusionCategory.emotionalWorld:
          coreSelf.add(signal);
        case FusionCategory.relationships:
          relationships.add(signal);
        case FusionCategory.workAndAmbition:
        case FusionCategory.thinkingStyle:
          workAndAmbition.add(signal);
        case FusionCategory.strengths:
          strengths.add(signal);
        case FusionCategory.growthAreas:
        case FusionCategory.growthPath:
          growthAreas.add(signal);
      }
    }

    return ZodiacFusionBridgeDimensionBundle(
      coreSelf: List<ZodiacFusionBridgeSignal>.unmodifiable(coreSelf),
      relationships: List<ZodiacFusionBridgeSignal>.unmodifiable(relationships),
      workAndAmbition:
          List<ZodiacFusionBridgeSignal>.unmodifiable(workAndAmbition),
      strengths: List<ZodiacFusionBridgeSignal>.unmodifiable(strengths),
      growthAreas: List<ZodiacFusionBridgeSignal>.unmodifiable(growthAreas),
    );
  }
}
