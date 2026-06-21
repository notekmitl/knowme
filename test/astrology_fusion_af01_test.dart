import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/domain/contracts/astrology_fusion_contract.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';
import 'package:knowme/features/astrology/fusion/registry/family_registry.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';

void main() {
  group('FusionThemeRegistry', () {
    test('contains exactly 29 themes', () {
      expect(FusionThemeRegistry.count, 29);
      expect(FusionThemeRegistry.getAll().length, 29);
    });

    test('theme ids are unique', () {
      final ids = FusionThemeRegistry.getAll().map((theme) => theme.id).toList();
      expect(ids.length, ids.toSet().length);
    });

    test('getById resolves canonical theme', () {
      final theme = FusionThemeRegistry.getById('independent');
      expect(theme, isNotNull);
      expect(theme!.name, 'Independent');
      expect(theme.category, FusionCategory.coreSelf);
      expect(theme.family, ThemeFamily.autonomy);
    });

    test('getByCategory returns only matching themes', () {
      final themes =
          FusionThemeRegistry.getByCategory(FusionCategory.relationships);
      expect(themes.length, 4);
      expect(
        themes.every((theme) => theme.category == FusionCategory.relationships),
        isTrue,
      );
    });

    test('category counts match V1 catalog', () {
      expect(
        FusionThemeRegistry.getByCategory(FusionCategory.coreSelf).length,
        5,
      );
      expect(
        FusionThemeRegistry.getByCategory(FusionCategory.thinkingStyle).length,
        4,
      );
      expect(
        FusionThemeRegistry.getByCategory(FusionCategory.emotionalWorld).length,
        3,
      );
      expect(
        FusionThemeRegistry.getByCategory(FusionCategory.workAndAmbition).length,
        4,
      );
      expect(
        FusionThemeRegistry.getByCategory(FusionCategory.strengths).length,
        3,
      );
      expect(
        FusionThemeRegistry.getByCategory(FusionCategory.growthAreas).length,
        3,
      );
      expect(
        FusionThemeRegistry.getByCategory(FusionCategory.growthPath).length,
        3,
      );
    });
  });

  group('FusionFamilyRegistry', () {
    test('maps autonomy family themes', () {
      expect(
        FusionFamilyRegistry.getThemeIds(ThemeFamily.autonomy),
        ['independent', 'leadership', 'driven'],
      );
    });

    test('maps structure family themes', () {
      expect(
        FusionFamilyRegistry.getThemeIds(ThemeFamily.structure),
        ['structured', 'responsible', 'reliable', 'persistent'],
      );
    });

    test('maps adaptation family themes', () {
      expect(
        FusionFamilyRegistry.getThemeIds(ThemeFamily.adaptation),
        ['adaptable', 'flexible', 'openness'],
      );
    });

    test('maps reflection family themes', () {
      expect(
        FusionFamilyRegistry.getThemeIds(ThemeFamily.reflection),
        ['analytical', 'reflection', 'overthinking'],
      );
    });

    test('maps connection family themes', () {
      expect(
        FusionFamilyRegistry.getThemeIds(ThemeFamily.connection),
        [
          'supportive',
          'diplomatic',
          'loyal',
          'independent_connection',
        ],
      );
    });

    test('maps expression family themes', () {
      expect(
        FusionFamilyRegistry.getThemeIds(ThemeFamily.expression),
        ['expressive', 'responsive', 'passionate', 'creative'],
      );
    });

    test('familyForThemeId resolves registry-backed themes', () {
      expect(
        FusionFamilyRegistry.familyForThemeId('responsible'),
        ThemeFamily.structure,
      );
      expect(
        FusionFamilyRegistry.familyForThemeId('grounded'),
        ThemeFamily.structure,
      );
    });

    test('getThemes returns resolved FusionTheme entries', () {
      final themes = FusionFamilyRegistry.getThemes(ThemeFamily.autonomy);
      expect(themes.length, 3);
      expect(themes.every((theme) => theme.family == ThemeFamily.autonomy), isTrue);
    });
  });

  group('Mock lens outputs', () {
    test('westernMock returns expected themes', () {
      final outputs = westernMock();
      expect(outputs.length, 3);
      expect(
        outputs.map((output) => output.themeId).toList(),
        ['independent', 'structured', 'leadership'],
      );
      expect(
        outputs.every(
          (output) => output.lensId == AstrologyLens.westernNatal.lensId,
        ),
        isTrue,
      );
    });

    test('baziMock returns expected themes', () {
      final outputs = baziMock();
      expect(outputs.length, 3);
      expect(
        outputs.map((output) => output.themeId).toList(),
        ['responsible', 'reliable', 'growth_focused'],
      );
    });

    test('thaiMock returns expected themes', () {
      final outputs = thaiMock();
      expect(outputs.length, 3);
      expect(
        outputs.map((output) => output.themeId).toList(),
        ['supportive', 'persistent', 'adaptable'],
      );
    });

    test('mock outputs include evidence and confidence', () {
      for (final output in allMockLenses()) {
        expect(output.evidence, isNotEmpty);
        expect(output.confidence, greaterThan(0));
        expect(output.confidence, lessThanOrEqualTo(1));
        expect(FusionThemeRegistry.contains(output.themeId), isTrue);
      }
    });
  });

  group('AstrologyFusionGenerator', () {
    test('generates result from all mock lenses', () {
      final result = AstrologyFusionGenerator.generate(
        allMockLenses(),
        generatedAt: DateTime.utc(2026, 6, 11),
      );

      expect(result.version, AstrologyFusionContract.version);
      expect(result.generatedAt, DateTime.utc(2026, 6, 11));
      expect(result.topThemes, isNotEmpty);
      expect(result.topThemes.length, lessThanOrEqualTo(5));
      expect(result.signals, isNotEmpty);
      expect(result.reflection.summary, isNotEmpty);
    });

    test('ranks themes by occurrence count', () {
      final outputs = [
        ...westernMock(),
        ...baziMock(),
        ...thaiMock(),
        ...westernMock(),
      ];

      final result = AstrologyFusionGenerator.generate(
        outputs,
        topThemeLimit: 9,
        generatedAt: DateTime.utc(2026, 6, 11),
      );

      expect(result.topThemes.first, 'independent');
      expect(result.topThemes, contains('structured'));
      expect(result.topThemes, contains('leadership'));
    });

    test('ignores unknown theme ids', () {
      final outputs = westernMock();
      final tampered = [
        ...outputs,
        outputs.first.copyWith(themeId: 'unknown_theme'),
      ];

      final result = AstrologyFusionGenerator.generate(
        tampered,
        generatedAt: DateTime.utc(2026, 6, 11),
      );

      expect(result.topThemes.every(FusionThemeRegistry.contains), isTrue);
    });

    test('supports arbitrary lens count', () {
      final singleLens = westernMock();
      final result = AstrologyFusionGenerator.generate(
        singleLens,
        generatedAt: DateTime.utc(2026, 6, 11),
      );

      expect(result.topThemes.length, 3);
    });
  });
}

extension on LensThemeOutput {
  LensThemeOutput copyWith({String? themeId}) {
    return LensThemeOutput(
      lensId: lensId,
      themeId: themeId ?? this.themeId,
      category: category,
      family: family,
      confidence: confidence,
      evidence: evidence,
    );
  }
}
