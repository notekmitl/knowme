import 'package:knowme/core/themes/theme_registry.dart';

import '../data/zodiac_personality_library.dart';
import '../data/zodiac_theme_calibration_catalog.dart';
import '../domain/zodiac_fusion_readiness_signals.dart';
import '../domain/zodiac_theme_weight_tier.dart';
import 'zodiac_theme_calibration_resolver.dart';

/// Result of a deterministic theme calibration audit.
class ZodiacThemeCalibrationAuditReport {
  const ZodiacThemeCalibrationAuditReport({
    required this.isValid,
    required this.missingAnimals,
    required this.unknownThemeIds,
    required this.tierCollisions,
    required this.primaryOverlapWarnings,
    required this.fusionCoverageGaps,
    required this.themeImbalanceWarnings,
  });

  final bool isValid;
  final List<String> missingAnimals;
  final List<String> unknownThemeIds;
  final List<String> tierCollisions;
  final List<String> primaryOverlapWarnings;
  final List<String> fusionCoverageGaps;
  final List<String> themeImbalanceWarnings;
}

/// Checks calibration quality: coverage, validity, overlap, fusion readiness.
abstract final class ZodiacThemeCalibrationAudit {
  static const int primaryOverlapThreshold = 6;

  static ZodiacThemeCalibrationAuditReport run() {
    final missingAnimals = <String>[];
    final unknownThemeIds = <String>[];
    final tierCollisions = <String>[];
    final fusionCoverageGaps = <String>[];
    final themeImbalanceWarnings = <String>[];

    for (final animal in ZodiacPersonalityLibrary.supportedAnimals) {
      final model = ZodiacThemeCalibrationCatalog.byAnimal[animal];
      if (model == null) {
        missingAnimals.add(animal);
        continue;
      }

      if (model.primary.length < 2) {
        themeImbalanceWarnings.add('$animal: fewer than 2 primary themes');
      }
      if (model.secondary.isEmpty) {
        themeImbalanceWarnings.add('$animal: no secondary themes');
      }
      if (model.weak.isEmpty) {
        themeImbalanceWarnings.add('$animal: no weak themes');
      }

      final seen = <String, ZodiacThemeWeightTier>{};
      for (final tier in ZodiacThemeWeightTier.values) {
        for (final id in model.themesForTier(tier)) {
          if (!ThemeRegistry.contains(id)) {
            unknownThemeIds.add('$animal:$id');
          }
          if (seen.containsKey(id)) {
            tierCollisions.add('$animal:$id (${seen[id]} + $tier)');
          } else {
            seen[id] = tier;
          }
        }
      }

      final readiness =
          ZodiacThemeCalibrationResolver.fusionReadinessForAnimal(animal);
      if (!readiness.isFullyReady) {
        final gaps = <String>[];
        if (!readiness.hasCoreSelfCoverage) gaps.add('Core Self');
        if (!readiness.hasRelationshipsCoverage) gaps.add('Relationships');
        if (!readiness.hasWorkAndAmbitionCoverage) {
          gaps.add('Work & Ambition');
        }
        if (!readiness.hasStrengthsCoverage) gaps.add('Strengths');
        if (!readiness.hasGrowthAreasCoverage) gaps.add('Growth Areas');
        fusionCoverageGaps.add('$animal: missing ${gaps.join(', ')}');
      }
    }

    final primaryCounts = <String, int>{};
    for (final entry in ZodiacThemeCalibrationCatalog.byAnimal.entries) {
      for (final id in entry.value.primary) {
        primaryCounts[id] = (primaryCounts[id] ?? 0) + 1;
      }
    }

    final primaryOverlapWarnings = <String>[];
    for (final entry in primaryCounts.entries) {
      if (entry.value >= primaryOverlapThreshold) {
        primaryOverlapWarnings.add(
          '${entry.key}: primary in ${entry.value} animals (threshold $primaryOverlapThreshold)',
        );
      }
    }

    // Flag harmonizer cluster: rabbit/goat/pig share empathetic primary
    final empatheticPrimary = ZodiacThemeCalibrationCatalog.byAnimal.entries
        .where((e) => e.value.primary.contains('empathetic'))
        .map((e) => e.key)
        .toList();
    if (empatheticPrimary.length >= 3) {
      themeImbalanceWarnings.add(
        'empathetic primary shared by ${empatheticPrimary.join(', ')} — distinguish in Fusion weighting',
      );
    }

    final isValid = missingAnimals.isEmpty &&
        unknownThemeIds.isEmpty &&
        tierCollisions.isEmpty &&
        fusionCoverageGaps.isEmpty;

    return ZodiacThemeCalibrationAuditReport(
      isValid: isValid,
      missingAnimals: List<String>.unmodifiable(missingAnimals),
      unknownThemeIds: List<String>.unmodifiable(unknownThemeIds),
      tierCollisions: List<String>.unmodifiable(tierCollisions),
      primaryOverlapWarnings: List<String>.unmodifiable(primaryOverlapWarnings),
      fusionCoverageGaps: List<String>.unmodifiable(fusionCoverageGaps),
      themeImbalanceWarnings: List<String>.unmodifiable(themeImbalanceWarnings),
    );
  }
}