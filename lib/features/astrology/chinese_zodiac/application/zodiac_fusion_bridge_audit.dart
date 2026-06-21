import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart'
    as fusion;

import '../data/zodiac_fusion_bridge_catalog.dart';
import '../data/zodiac_theme_calibration_catalog.dart';
import '../domain/zodiac_fusion_signal_weight.dart';
import '../domain/zodiac_theme_weight_tier.dart';
import 'zodiac_fusion_bridge_resolver.dart';
import 'zodiac_theme_calibration_resolver.dart';

/// Result of bridge completeness and fusion compatibility checks.
class ZodiacFusionBridgeAuditReport {
  const ZodiacFusionBridgeAuditReport({
    required this.isValid,
    required this.unmappedFoundationThemes,
    required this.invalidFusionThemeIds,
    required this.duplicateBridgeRules,
    required this.emptySignalAnimals,
    required this.dimensionCoverageGaps,
    required this.weakTierViolations,
  });

  final bool isValid;
  final List<String> unmappedFoundationThemes;
  final List<String> invalidFusionThemeIds;
  final List<String> duplicateBridgeRules;
  final List<String> emptySignalAnimals;
  final List<String> dimensionCoverageGaps;
  final List<String> weakTierViolations;
}

/// Validates Theme Foundation → Fusion Registry bridge integrity.
abstract final class ZodiacFusionBridgeAudit {
  static ZodiacFusionBridgeAuditReport run() {
    final unmappedFoundationThemes = <String>[];
    final invalidFusionThemeIds = <String>[];
    final duplicateBridgeRules = <String>[];
    final emptySignalAnimals = <String>[];
    final dimensionCoverageGaps = <String>[];
    final weakTierViolations = <String>[];

    final foundationUsed = <String>{};
    for (final model in ZodiacThemeCalibrationCatalog.byAnimal.values) {
      for (final tier in ZodiacThemeWeightTier.values) {
        foundationUsed.addAll(model.themesForTier(tier));
      }
    }

    for (final foundationId in foundationUsed) {
      if (!ThemeRegistry.contains(foundationId)) {
        unmappedFoundationThemes.add('$foundationId: unknown in Theme Foundation');
        continue;
      }

      final fusionIds =
          ZodiacFusionBridgeCatalog.fusionThemesForFoundation(foundationId);
      if (fusionIds.isEmpty) {
        unmappedFoundationThemes.add(foundationId);
      }

      for (final fusionId in fusionIds) {
        if (!fusion.FusionThemeRegistry.contains(fusionId)) {
          invalidFusionThemeIds.add('$foundationId→$fusionId');
        }
      }
    }

    final bridgeKeys = ZodiacFusionBridgeCatalog.foundationToFusion.keys.toList();
    final seenKeys = <String>{};
    for (final key in bridgeKeys) {
      if (!seenKeys.add(key)) {
        duplicateBridgeRules.add(key);
      }
    }

    for (final animal in ZodiacThemeCalibrationResolver.supportedAnimals) {
      final bundle = ZodiacFusionBridgeResolver.bundleForAnimal(animal);
      if (bundle.isEmpty) {
        emptySignalAnimals.add(animal);
      }

      final dimensions = bundle.toDimensionBundle();
      if (!dimensions.isFullyCovered) {
        final gaps = <String>[];
        if (dimensions.coreSelf.isEmpty) gaps.add('Core Self');
        if (dimensions.relationships.isEmpty) gaps.add('Relationships');
        if (dimensions.workAndAmbition.isEmpty) gaps.add('Work & Ambition');
        if (dimensions.strengths.isEmpty) gaps.add('Strengths');
        if (dimensions.growthAreas.isEmpty) gaps.add('Growth Areas');
        dimensionCoverageGaps.add('$animal: ${gaps.join(', ')}');
      }

      final model = ZodiacThemeCalibrationResolver.forAnimal(animal);
      if (model == null) continue;

      for (final signal in bundle.signals) {
        if (signal.weight != ZodiacFusionSignalWeight.growthOnly) continue;

        final fusionTheme =
            fusion.FusionThemeRegistry.getById(signal.fusionThemeId);
        if (fusionTheme == null) continue;

        final isGrowth =
            fusionTheme.category == FusionCategory.growthAreas ||
            fusionTheme.category == FusionCategory.growthPath;
        if (!isGrowth) {
          weakTierViolations.add(
            '$animal: growthOnly weight on non-growth ${signal.fusionThemeId}',
          );
        }
      }
    }

    final isValid = unmappedFoundationThemes.isEmpty &&
        invalidFusionThemeIds.isEmpty &&
        duplicateBridgeRules.isEmpty &&
        emptySignalAnimals.isEmpty &&
        dimensionCoverageGaps.isEmpty &&
        weakTierViolations.isEmpty;

    return ZodiacFusionBridgeAuditReport(
      isValid: isValid,
      unmappedFoundationThemes:
          List<String>.unmodifiable(unmappedFoundationThemes),
      invalidFusionThemeIds: List<String>.unmodifiable(invalidFusionThemeIds),
      duplicateBridgeRules: List<String>.unmodifiable(duplicateBridgeRules),
      emptySignalAnimals: List<String>.unmodifiable(emptySignalAnimals),
      dimensionCoverageGaps: List<String>.unmodifiable(dimensionCoverageGaps),
      weakTierViolations: List<String>.unmodifiable(weakTierViolations),
    );
  }
}
