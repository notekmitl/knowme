import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/adapters/bazi_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/adapters/mapping/bazi_fusion_theme_mapping.dart';
import 'package:knowme/features/astrology/fusion/adapters/mapping/western_sign_theme_mapping.dart';
import 'package:knowme/features/astrology/fusion/adapters/thai_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/adapters/western_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_lens.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_type.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_input.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_evidence.dart';

AstrologyChartModel _ariesWesternChart() {
  return AstrologyChartModel.fromMap({
    'big3': {
      'sun': 'Aries',
      'moon': 'Cancer',
      'rising': 'Leo',
    },
    'planets': {},
    'insight': {},
    'overall_summary': {},
  });
}

BaziChartModel _sampleBaziChart() {
  return BaziChartModel.fromMap({
    'version': 'bazi_v1',
    'engine_version': 'lunar_python@1.4.8',
    'generated_at': '2026-06-07T07:22:13.583812+00:00',
    'input_hash': 'abc',
    'completeness': 'four_pillars',
    'dominant_element': 'fire',
    'day_master': {
      'stem': '丁',
      'stem_roman': 'ding',
      'element': 'fire',
      'polarity': 'yin',
      'pillar_label': '丁丑',
    },
    'year_animal': {'zh': '马', 'roman': 'horse', 'en': 'Horse'},
    'element_balance': {
      'wood': 0,
      'fire': 3,
      'earth': 2,
      'metal': 3,
      'water': 0,
      'total_slots': 8,
      'method': 'surface_stem_branch_v1',
    },
    'pillars': {
      'year': {
        'stem': '庚',
        'branch': '午',
        'stem_roman': 'geng',
        'branch_roman': 'wu',
        'stem_element': 'metal',
        'branch_element': 'fire',
        'pillar_label': '庚午',
      },
      'month': {
        'stem': '辛',
        'branch': '巳',
        'stem_roman': 'xin',
        'branch_roman': 'si',
        'stem_element': 'metal',
        'branch_element': 'fire',
        'pillar_label': '辛巳',
      },
      'day': {
        'stem': '丁',
        'branch': '丑',
        'stem_roman': 'ding',
        'branch_roman': 'chou',
        'stem_element': 'fire',
        'branch_element': 'earth',
        'pillar_label': '丁丑',
      },
      'hour': {
        'stem': '戊',
        'branch': '申',
        'stem_roman': 'wu',
        'branch_roman': 'shen',
        'stem_element': 'earth',
        'branch_element': 'metal',
        'pillar_label': '戊申',
      },
    },
  });
}

ThaiPresentedTheme _thaiPresented({
  required String themeId,
  FusionCategory? fusionCategory,
  ThemeCategory? category,
  required List<ThaiThemeEvidence> evidence,
}) {
  final fusionTheme = FusionThemeRegistry.getById(themeId)!;
  final resolvedCategory = category ??
      _coreCategoryForFusion(fusionTheme.category);

  return ThaiPresentedTheme(
    themeId: themeId,
    themeName: fusionTheme.name,
    category: resolvedCategory.displayName,
    description: fusionTheme.description,
    score: 8,
    confidence: ThaiThemeConfidenceLevel.high,
    evidence: evidence,
  );
}

ThemeCategory _coreCategoryForFusion(FusionCategory category) {
  return switch (category) {
    FusionCategory.coreSelf => ThemeCategory.coreSelf,
    FusionCategory.thinkingStyle => ThemeCategory.thinkingStyle,
    FusionCategory.emotionalWorld => ThemeCategory.emotionalWorld,
    FusionCategory.relationships => ThemeCategory.relationships,
    FusionCategory.workAndAmbition => ThemeCategory.workAndAmbition,
    FusionCategory.strengths => ThemeCategory.strengths,
    FusionCategory.growthAreas => ThemeCategory.growthAreas,
    FusionCategory.growthPath => ThemeCategory.growthPath,
  };
}

void main() {
  group('WesternRealAdapter', () {
    test('maps Aries Sun to registry themes with real evidence', () {
      final outputs = WesternRealAdapter.adapt(_ariesWesternChart());
      final themeIds = outputs.map((output) => output.themeId).toSet();

      expect(themeIds, containsAll(['independent', 'driven']));
      expect(
        outputs.every(
          (output) => output.lensId == AstrologyLens.westernNatal.lensId,
        ),
        isTrue,
      );

      final sunThemes = outputs.where(
        (output) => output.evidence.any((e) => e.startsWith('Sun Sign:')),
      );
      expect(
        sunThemes.map((output) => output.themeId).toSet(),
        containsAll(WesternSignThemeMapping.themesForSign('Aries')),
      );
      expect(
        outputs.every((output) => FusionThemeRegistry.contains(output.themeId)),
        isTrue,
      );
    });

    test('skips unknown signs without inventing themes', () {
      final chart = AstrologyChartModel.fromMap({
        'big3': {'sun': 'NotAZodiac'},
        'planets': {},
        'insight': {},
        'overall_summary': {},
      });

      final outputs = WesternRealAdapter.adapt(chart);
      expect(outputs, isEmpty);
    });
  });

  group('BaziRealAdapter', () {
    test('maps day master and engine fields to registry themes', () {
      final chart = _sampleBaziChart();
      final outputs = BaziRealAdapter.adapt(chart);
      final themeIds = outputs.map((output) => output.themeId).toSet();

      for (final themeId
          in BaziFusionThemeMapping.themesForDayMaster(
            polarity: chart.dayMaster.polarity,
            element: chart.dayMaster.element,
          )) {
        expect(themeIds, contains(themeId));
      }

      expect(themeIds, contains('driven'));

      final dayMasterOutputs = outputs.where(
        (output) => output.evidence.any((e) => e.startsWith('Day Master:')),
      );
      expect(dayMasterOutputs, isNotEmpty);
      expect(
        outputs.every((output) => FusionThemeRegistry.contains(output.themeId)),
        isTrue,
      );
    });
  });

  group('ThaiRealAdapter', () {
    test('maps Thai Mirror themes with traceable evidence only', () {
      const contentKey = ThaiContentKeys.lagnaTaurus;
      final mirror = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(lagnaKey: contentKey),
          presentedThemes: [
            _thaiPresented(
              themeId: 'grounded',
              category: ThemeCategory.coreSelf,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: contentKey,
                  sourceType: ThaiContentType.lagna,
                  contribution: 0.9,
                ),
              ],
            ),
            _thaiPresented(
              themeId: 'analytical',
              category: ThemeCategory.thinkingStyle,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: contentKey,
                  sourceType: ThaiContentType.lagna,
                  contribution: 0.8,
                ),
              ],
            ),
          ],
        ),
      );

      final outputs = ThaiRealAdapter.adapt(mirror);

      expect(
        outputs.map((output) => output.themeId).toSet(),
        {'grounded', 'analytical'},
      );
      expect(
        outputs.every(
          (output) => output.lensId == AstrologyLens.thaiAstrology.lensId,
        ),
        isTrue,
      );
      expect(
        outputs.every((output) => output.evidence.isNotEmpty),
        isTrue,
      );
      expect(
        outputs.first.evidence.first,
        'Lagna: $contentKey',
      );
    });

    test('skips themes not in FusionThemeRegistry', () {
      final mirror = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(),
          presentedThemes: [
            ThaiPresentedTheme(
              themeId: 'builder',
              themeName: 'Builder',
              category: ThemeCategory.workAndAmbition.displayName,
              description: ThemeRegistry.getById('builder')!.description,
              score: 8,
              confidence: ThaiThemeConfidenceLevel.high,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: ThaiContentKeys.lagnaTaurus,
                  sourceType: ThaiContentType.lagna,
                  contribution: 0.9,
                ),
              ],
            ),
          ],
        ),
      );

      final outputs = ThaiRealAdapter.adapt(mirror);
      expect(outputs, isEmpty);
    });
  });

  group('Full real-data pipeline', () {
    test('generateFromRealData produces complete fusion intelligence', () {
      const contentKey = ThaiContentKeys.lagnaTaurus;
      final thaiMirror = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(lagnaKey: contentKey),
          presentedThemes: [
            _thaiPresented(
              themeId: 'persistent',
              fusionCategory: FusionCategory.strengths,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: contentKey,
                  sourceType: ThaiContentType.lagna,
                  contribution: 0.85,
                ),
              ],
            ),
            _thaiPresented(
              themeId: 'supportive',
              fusionCategory: FusionCategory.relationships,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: ThaiContentKeys.lagnaLordSun,
                  sourceType: ThaiContentType.lagnaLord,
                  contribution: 0.8,
                ),
              ],
            ),
          ],
        ),
      );

      final thaiOutputs = ThaiRealAdapter.adapt(thaiMirror);
      expect(thaiOutputs, isNotEmpty);

      final result = AstrologyFusionGenerator.generateFromRealData(
        AstrologyFusionRealInput(
          western: _ariesWesternChart(),
          bazi: _sampleBaziChart(),
          thai: thaiMirror,
        ),
        generatedAt: DateTime.utc(2026, 6, 11),
      );

      expect(result.topThemes, isNotEmpty);
      expect(result.signals, isNotEmpty);
      expect(result.reflection.summary, isNotEmpty);
      expect(result.reflection.summary, contains('หลายศาสตร์สะท้อน'));
    });

    test('supports partial lens availability', () {
      final result = AstrologyFusionGenerator.generateFromRealData(
        AstrologyFusionRealInput(western: _ariesWesternChart()),
        generatedAt: DateTime.utc(2026, 6, 11),
      );

      expect(result.topThemes, isNotEmpty);
      expect(result.reflection.summary, isNotEmpty);
    });
  });
}
