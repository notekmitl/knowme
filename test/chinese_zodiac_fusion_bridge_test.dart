import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_fusion_bridge_audit.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_fusion_bridge_resolver.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_theme_calibration_resolver.dart';
import 'package:knowme/features/astrology/chinese_zodiac/data/zodiac_fusion_bridge_catalog.dart';
import 'package:knowme/features/astrology/chinese_zodiac/data/zodiac_theme_calibration_catalog.dart';
import 'package:knowme/features/astrology/chinese_zodiac/domain/zodiac_fusion_signal_weight.dart';
import 'package:knowme/features/astrology/chinese_zodiac/domain/zodiac_theme_weight_tier.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart'
    as fusion;

void main() {
  group('ZodiacFusionBridgeCatalog', () {
    test('maps every calibrated foundation theme to fusion registry ids', () {
      final foundationUsed = <String>{};
      for (final model in ZodiacThemeCalibrationCatalog.byAnimal.values) {
        for (final tier in ZodiacThemeWeightTier.values) {
          foundationUsed.addAll(model.themesForTier(tier));
        }
      }

      for (final foundationId in foundationUsed) {
        expect(
          ThemeRegistry.contains(foundationId),
          isTrue,
          reason: '$foundationId missing from Theme Foundation',
        );

        final fusionIds =
            ZodiacFusionBridgeCatalog.fusionThemesForFoundation(foundationId);
        expect(
          fusionIds,
          isNotEmpty,
          reason: '$foundationId has no bridge mapping',
        );

        for (final fusionId in fusionIds) {
          expect(
            fusion.FusionThemeRegistry.contains(fusionId),
            isTrue,
            reason: '$foundationId→$fusionId invalid',
          );
        }
      }
    });

    test('has no duplicate foundation keys', () {
      final keys = ZodiacFusionBridgeCatalog.foundationToFusion.keys.toList();
      expect(keys.length, keys.toSet().length);
    });
  });

  group('ZodiacFusionBridgeResolver', () {
    test('translates ox primary themes with full weight', () {
      final bundle = ZodiacFusionBridgeResolver.bundleForAnimal('ox');
      expect(bundle.isEmpty, isFalse);

      final disciplined = bundle.signals
          .where((signal) => signal.foundationThemeId == 'disciplined')
          .toList();
      expect(disciplined, isNotEmpty);
      expect(
        disciplined.every((signal) => signal.weight == ZodiacFusionSignalWeight.full),
        isTrue,
      );
      expect(
        disciplined.map((signal) => signal.fusionThemeId),
        containsAll(['structured', 'responsible']),
      );
    });

    test('applies reduced weight to secondary tier', () {
      final bundle = ZodiacFusionBridgeResolver.bundleForAnimal('rat');
      final overthinking = bundle.signals
          .firstWhere((signal) => signal.fusionThemeId == 'overthinking');
      expect(overthinking.weight, ZodiacFusionSignalWeight.reduced);
      expect(overthinking.sourceTier, ZodiacThemeWeightTier.secondary);
    });

    test('weak tier emits growth fusion themes only', () {
      final bundle = ZodiacFusionBridgeResolver.bundleForAnimal('ox');
      final weakSignals = bundle.signals
          .where((signal) => signal.sourceTier == ZodiacThemeWeightTier.weak)
          .toList();

      for (final signal in weakSignals) {
        expect(signal.weight, ZodiacFusionSignalWeight.growthOnly);
        final fusionTheme =
            fusion.FusionThemeRegistry.getById(signal.fusionThemeId);
        expect(fusionTheme, isNotNull);
        expect(
          fusionTheme!.category == FusionCategory.growthAreas ||
              fusionTheme.category == FusionCategory.growthPath,
          isTrue,
        );
      }
    });

    test('prefers full weight when same fusion id appears in multiple tiers', () {
      final bundle = ZodiacFusionBridgeResolver.bundleForAnimal('monkey');
      final adaptable = bundle.signals
          .firstWhere((signal) => signal.fusionThemeId == 'adaptable');
      expect(adaptable.weight, ZodiacFusionSignalWeight.full);
    });

    test('every animal produces fusion dimension coverage', () {
      for (final animal in ZodiacThemeCalibrationResolver.supportedAnimals) {
        final dimensions =
            ZodiacFusionBridgeResolver.bundleForAnimal(animal).toDimensionBundle();
        expect(
          dimensions.isFullyCovered,
          isTrue,
          reason: '$animal missing fusion dimension coverage',
        );
      }
    });
  });

  group('ZodiacFusionBridgeAudit', () {
    test('passes full bridge compatibility audit', () {
      final report = ZodiacFusionBridgeAudit.run();
      expect(report.isValid, isTrue, reason: report.toString());
      expect(report.unmappedFoundationThemes, isEmpty);
      expect(report.invalidFusionThemeIds, isEmpty);
      expect(report.duplicateBridgeRules, isEmpty);
      expect(report.emptySignalAnimals, isEmpty);
      expect(report.dimensionCoverageGaps, isEmpty);
      expect(report.weakTierViolations, isEmpty);
    });
  });
}
