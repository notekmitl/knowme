import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/global_fusion/application/theme_normalization/mirror_theme_mappings.dart';
import 'package:knowme/features/global_fusion/domain/global_core_themes.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_constants.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_golden_scenario.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_snapshot_inspector.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_validation_harness.dart';
import 'package:knowme/features/global_fusion/validation/global_theme_mapping_validator.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';

void main() {
  group('GlobalThemeRegistry', () {
    test('defines v1 theme contract with seven themes', () {
      expect(GlobalThemeIds.v1Themes.length, 7);
      for (final id in GlobalThemeIds.v1Themes) {
        expect(GlobalThemeRegistry.contains(id), isTrue);
      }
    });
  });

  group('Mirror theme mappings', () {
    test('maps astrology signal types to foundation subset', () {
      expect(
        AstrologyMirrorThemeMapping.globalThemeForSignalType(
          FusionSignalType.reflection,
        ),
        GlobalThemeIds.reflection,
      );
      expect(
        AstrologyMirrorThemeMapping.globalThemeForSignalType(
          FusionSignalType.structure,
        ),
        GlobalThemeIds.structure,
      );
    });

    test('maps expressive personality theme to expression', () {
      expect(
        PersonalityMirrorThemeMapping.globalThemeForCoreTheme(
          PersonalityCoreThemeIds.expressive,
        ),
        GlobalThemeIds.expression,
      );
      expect(
        PersonalityMirrorThemeMapping.globalThemeForCoreTheme(
          PersonalityCoreThemeIds.supportive,
        ),
        GlobalThemeIds.relationships,
      );
    });

    test('maps autonomy family via astrology signal type', () {
      expect(
        AstrologyMirrorThemeMapping.globalThemeForSignalType(
          FusionSignalType.autonomy,
        ),
        GlobalThemeIds.autonomy,
      );
    });
  });

  group('GlobalFusionContract', () {
    test('references frozen mirror versions only', () {
      expect(GlobalFusionContract.astrologyMirrorVersion, isNotEmpty);
      expect(GlobalFusionContract.personalityMirrorVersion, isNotEmpty);
    });
  });

  group('GlobalThemeMappingValidator', () {
    test('theme contract v1 is complete', () {
      expect(GlobalThemeMappingValidator.isComplete, isTrue);
    });
  });

  group('GlobalFusionValidationHarness', () {
    for (final scenario in GlobalFusionGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final result = GlobalFusionValidationHarness.run(scenario);

        if (!result.passed) {
          // ignore: avoid_print
          print(result.debugReport);
          // ignore: avoid_print
          print('issues: ${result.issues}');
        }

        expect(
          result.passed,
          isTrue,
          reason: '${scenario.name} failed: ${result.issues.join('; ')}',
        );
      });
    }

    test('runAllPassing returns true', () {
      expect(GlobalFusionValidationHarness.runAllPassing(), isTrue);
    });

    test('inspector produces structured json and debug report', () {
      final result = GlobalFusionValidationHarness.run(
        GlobalFusionGoldenScenario.scenarioC,
      );

      expect(result.inspectionJson['version'], isNotNull);
      expect(result.inspectionJson['normalizedThemes'], isA<List>());
      expect(result.inspectionJson['coverage'], isA<Map>());
      expect(result.debugReport, contains('Global Fusion Snapshot'));
    });
  });

  group('Scenario-specific behavior', () {
    test('scenarioA is astrology-only with no synthesis', () {
      final result = GlobalFusionValidationHarness.run(
        GlobalFusionGoldenScenario.scenarioA,
      );

      expect(result.snapshot.coverage.hasAstrology, isTrue);
      expect(result.snapshot.coverage.hasPersonality, isFalse);
      expect(result.snapshot.normalizedThemes, isNotEmpty);
      expect(result.snapshot.agreements, isEmpty);
      expect(result.snapshot.tensions, isEmpty);
    });

    test('scenarioB is personality-only with no synthesis', () {
      final result = GlobalFusionValidationHarness.run(
        GlobalFusionGoldenScenario.scenarioB,
      );

      expect(result.snapshot.coverage.hasAstrology, isFalse);
      expect(result.snapshot.coverage.hasPersonality, isTrue);
      expect(result.snapshot.agreements, isEmpty);
      expect(result.snapshot.tensions, isEmpty);
    });

    test('scenarioC has agreement-only synthesis', () {
      final result = GlobalFusionValidationHarness.run(
        GlobalFusionGoldenScenario.scenarioC,
      );

      expect(result.snapshot.coverage.hasBothMirrors, isTrue);
      expect(result.snapshot.agreements, isNotEmpty);
      expect(result.snapshot.tensions, isEmpty);
    });

    test('scenarioF has empty coverage themes agreements and tensions', () {
      final result = GlobalFusionValidationHarness.run(
        GlobalFusionGoldenScenario.scenarioF,
      );

      expect(result.snapshot.coverage.hasAnyMirror, isFalse);
      expect(result.snapshot.normalizedThemes, isEmpty);
      expect(result.snapshot.agreements, isEmpty);
      expect(result.snapshot.tensions, isEmpty);
      expect(result.snapshot.confidence.coverageScore, 0.0);
    });
  });
}
