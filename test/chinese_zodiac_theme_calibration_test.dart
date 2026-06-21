import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_fusion_readiness_review.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_theme_calibration_audit.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_theme_calibration_resolver.dart';
import 'package:knowme/features/astrology/chinese_zodiac/data/zodiac_personality_library.dart';
import 'package:knowme/features/astrology/chinese_zodiac/data/zodiac_theme_calibration_catalog.dart';
import 'package:knowme/features/astrology/chinese_zodiac/domain/zodiac_theme_weight_tier.dart';

void main() {
  group('ZodiacThemeCalibrationCatalog', () {
    test('covers all 12 supported animals', () {
      expect(
        ZodiacThemeCalibrationCatalog.byAnimal.keys.toSet(),
        ZodiacPersonalityLibrary.supportedAnimals.toSet(),
      );
    });

    test('all theme ids exist in Theme Foundation registry', () {
      for (final entry in ZodiacThemeCalibrationCatalog.byAnimal.entries) {
        for (final tier in ZodiacThemeWeightTier.values) {
          for (final id in entry.value.themesForTier(tier)) {
            expect(
              ThemeRegistry.contains(id),
              isTrue,
              reason: '${entry.key} references unknown theme $id',
            );
          }
        }
      }
    });

    test('no theme appears in multiple tiers for same animal', () {
      for (final entry in ZodiacThemeCalibrationCatalog.byAnimal.entries) {
        final seen = <String>{};
        for (final tier in ZodiacThemeWeightTier.values) {
          for (final id in entry.value.themesForTier(tier)) {
            expect(
              seen.add(id),
              isTrue,
              reason: '${entry.key}: $id duplicated across tiers',
            );
          }
        }
      }
    });
  });

  group('ZodiacThemeCalibrationResolver', () {
    test('returns tiered themes for ox', () {
      final primary = ZodiacThemeCalibrationResolver.themesForAnimal(
        'ox',
        tier: ZodiacThemeWeightTier.primary,
      );
      expect(primary, contains('disciplined'));
      expect(primary, contains('builder'));
      expect(primary, isNot(contains('explorer')));
    });

    test('fusion readiness signals cover all five dimensions per animal', () {
      for (final animal in ZodiacPersonalityLibrary.supportedAnimals) {
        final signals =
            ZodiacThemeCalibrationResolver.fusionReadinessForAnimal(animal);
        expect(
          signals.isFullyReady,
          isTrue,
          reason: '$animal fusion readiness incomplete',
        );
      }
    });
  });

  group('ZodiacThemeCalibrationAudit', () {
    test('passes full calibration audit', () {
      final report = ZodiacThemeCalibrationAudit.run();
      expect(report.isValid, isTrue, reason: report.toString());
      expect(report.missingAnimals, isEmpty);
      expect(report.unknownThemeIds, isEmpty);
      expect(report.tierCollisions, isEmpty);
      expect(report.fusionCoverageGaps, isEmpty);
    });
  });

  group('ZodiacFusionReadinessReview', () {
    test('all animals fusion ready', () {
      expect(ZodiacFusionReadinessReview.allAnimalsFusionReady(), isTrue);
    });
  });
}
