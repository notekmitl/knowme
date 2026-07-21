import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';
import 'package:knowme/features/global_fusion/application/theme_normalization/global_theme_mapping_policy.dart';
import 'package:knowme/features/global_fusion/application/theme_normalization/mirror_theme_mappings.dart';
import 'package:knowme/features/global_fusion/domain/global_core_themes.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_constants.dart';
import 'package:knowme/features/global_fusion/domain/global_theme_contract.dart';
import 'package:knowme/features/global_fusion/validation/global_theme_mapping_validator.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';

void main() {
  group('GlobalThemeContract v1', () {
    test('defines seven stabilized themes', () {
      expect(GlobalThemeIds.v1Themes, hasLength(7));
      expect(GlobalThemeRegistry.byId.length, 7);
    });

    test('every v1 theme has non-empty human intent', () {
      for (final theme in GlobalThemeRegistry.allV1) {
        expect(theme.intent.trim(), isNotEmpty);
        expect(theme.description.trim(), isNotEmpty);
      }
    });

    test('contract version is wired into GlobalFusionContract', () {
      expect(GlobalFusionContract.themeContractVersion, 'global_theme.v1');
    });
  });

  group('GlobalThemeMappingPolicy — theme families', () {
    test('covers all six theme families without rejection', () {
      for (final family in ThemeFamily.values) {
        final decision = GlobalThemeMappingPolicy.forFamily(family);
        expect(decision.isNormalized, isTrue, reason: family.id);
        expect(decision.globalThemeId, isNotNull);
      }
    });

    test('maps autonomy to autonomy global theme', () {
      expect(
        GlobalThemeMappingPolicy.forFamily(ThemeFamily.autonomy).globalThemeId,
        GlobalThemeIds.autonomy,
      );
    });

    test('maps expression to expression global theme (not growth)', () {
      expect(
        GlobalThemeMappingPolicy.forFamily(ThemeFamily.expression).globalThemeId,
        GlobalThemeIds.expression,
      );
    });
  });

  group('GlobalThemeMappingPolicy — fusion signal types', () {
    test('covers all signal types without rejection', () {
      for (final type in FusionSignalType.values) {
        final decision = GlobalThemeMappingPolicy.forSignalType(type);
        expect(decision.isNormalized, isTrue, reason: type.name);
      }
    });

    test('maps leadership signal to autonomy', () {
      expect(
        GlobalThemeMappingPolicy.forSignalType(FusionSignalType.leadership)
            .globalThemeId,
        GlobalThemeIds.autonomy,
      );
    });

    test('maps creativity signal to expression', () {
      expect(
        GlobalThemeMappingPolicy.forSignalType(FusionSignalType.creativity)
            .globalThemeId,
        GlobalThemeIds.expression,
      );
    });

    test('maps transformation signal to growth', () {
      expect(
        GlobalThemeMappingPolicy.forSignalType(FusionSignalType.transformation)
            .globalThemeId,
        GlobalThemeIds.growth,
      );
    });
  });

  group('GlobalThemeMappingPolicy — personality core themes', () {
    test('normalizes all 15 personality core themes', () {
      for (final themeId in PersonalityCoreThemeIds.all) {
        final decision =
            GlobalThemeMappingPolicy.forPersonalityCoreTheme(themeId);
        expect(decision.isNormalized, isTrue, reason: themeId);
      }
    });

    test('expressive maps to expression not growth', () {
      expect(
        PersonalityMirrorThemeMapping.globalThemeForCoreTheme(
          PersonalityCoreThemeIds.expressive,
        ),
        GlobalThemeIds.expression,
      );
    });

    test('creative maps to expression', () {
      expect(
        PersonalityMirrorThemeMapping.globalThemeForCoreTheme(
          PersonalityCoreThemeIds.creative,
        ),
        GlobalThemeIds.expression,
      );
    });

    test('rejects unknown personality theme ids explicitly', () {
      final decision =
          GlobalThemeMappingPolicy.forPersonalityCoreTheme('unknown_theme');
      expect(decision.isRejected, isTrue);
      expect(decision.reason, contains('Unknown personality'));
    });
  });

  group('GlobalThemeMappingPolicy — astrology registry themes', () {
    test('normalizes all 29 astrology fusion registry themes', () {
      for (final theme in FusionThemeRegistry.all) {
        final decision = GlobalThemeMappingPolicy.forAstrologyThemeId(theme.id);
        expect(decision.isNormalized, isTrue, reason: theme.id);
      }
    });

    test('independent maps to autonomy', () {
      expect(
        GlobalThemeMappingPolicy.forAstrologyThemeId('independent')
            .globalThemeId,
        GlobalThemeIds.autonomy,
      );
    });

    test('rejects unknown astrology theme ids explicitly', () {
      final decision =
          GlobalThemeMappingPolicy.forAstrologyThemeId('not_a_theme');
      expect(decision.isRejected, isTrue);
      expect(decision.reason, contains('Unknown astrology'));
    });
  });

  group('GlobalThemeCoverageMatrix', () {
    test('builds audit rows for families signals personality and registry', () {
      final rows = GlobalThemeCoverageMatrix.build();

      expect(
        rows.where((row) => row.sourceKind == 'theme_family').length,
        ThemeFamily.values.length,
      );
      expect(
        rows.where((row) => row.sourceKind == 'fusion_signal_type').length,
        FusionSignalType.values.length,
      );
      expect(
        rows.where((row) => row.sourceKind == 'personality_core_theme').length,
        PersonalityCoreThemeIds.all.length,
      );
      expect(
        rows.where((row) => row.sourceKind == 'fusion_theme_registry').length,
        FusionThemeRegistry.count,
      );
    });

    test('has zero rejected rows for known mirror sources', () {
      expect(GlobalThemeCoverageMatrix.rejectedCount, 0);
    });
  });

  group('GlobalThemeMappingValidator', () {
    test('contract completeness passes with zero issues', () {
      expect(GlobalThemeMappingValidator.isComplete, isTrue);
      expect(GlobalThemeMappingValidator.validateContractCompleteness(), isEmpty);
    });
  });
}
