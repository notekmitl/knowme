import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_bazi_adapter_bridge.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_fusion_bridge_resolver.dart';
import 'package:knowme/features/astrology/chinese_zodiac/domain/zodiac_fusion_signal_weight.dart';
import 'package:knowme/features/astrology/fusion/adapters/bazi_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/adapters/mapping/bazi_fusion_theme_mapping.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';

BaziChartModel _sampleChart({String yearAnimalEn = 'Horse'}) {
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
    'year_animal': {'zh': '马', 'roman': 'horse', 'en': yearAnimalEn},
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
      'year': _pillar(),
      'month': _pillar(),
      'day': _pillar(),
      'hour': _pillar(),
    },
  });
}

Map<String, dynamic> _pillar() => {
      'stem': '甲',
      'branch': '子',
      'stem_roman': 'jia',
      'branch_roman': 'zi',
      'stem_element': 'wood',
      'branch_element': 'water',
      'pillar_label': '甲子',
    };

List<String> _coreBaziThemeIds(BaziChartModel chart) {
  final ids = <String>{};

  ids.addAll(
    BaziFusionThemeMapping.themesForDayMaster(
      polarity: chart.dayMaster.polarity,
      element: chart.dayMaster.element,
    ),
  );

  final dominant = chart.dominantElement?.trim().toLowerCase();
  if (dominant != null) {
    final themeId = BaziFusionThemeMapping.dominantElementTheme[dominant];
    if (themeId != null) ids.add(themeId);
  }

  final counts = {
    'wood': chart.elementBalance.wood,
    'fire': chart.elementBalance.fire,
    'earth': chart.elementBalance.earth,
    'metal': chart.elementBalance.metal,
    'water': chart.elementBalance.water,
  };
  for (final entry in counts.entries) {
    if (entry.value < 2) continue;
    final themeId = BaziFusionThemeMapping.balanceStrengthTheme[entry.key];
    if (themeId != null) ids.add(themeId);
  }

  return ids.toList();
}

void main() {
  group('ZodiacBaziAdapterBridge', () {
    test('generates Year Animal signals for horse', () {
      final outputs = ZodiacBaziAdapterBridge.adapt(
        _sampleChart().yearAnimal,
      );

      expect(outputs, isNotEmpty);
      expect(
        outputs.every(
          (output) => output.evidence.any(
            (evidence) => evidence.startsWith('Year Animal: Horse'),
          ),
        ),
        isTrue,
      );
      expect(
        outputs.every((output) => FusionThemeRegistry.contains(output.themeId)),
        isTrue,
      );
    });

    test('preserves bridge weight tiers as confidence values', () {
      final bundle = ZodiacFusionBridgeResolver.bundleForAnimal('horse');
      final outputs = ZodiacBaziAdapterBridge.adapt(_sampleChart().yearAnimal);

      for (final signal in bundle.signals) {
        final output = outputs.firstWhere(
          (item) => item.themeId == signal.fusionThemeId,
        );
        expect(
          output.confidence,
          ZodiacBaziAdapterBridge.confidenceForWeight(signal.weight),
        );
      }
    });

    test('returns empty for unknown year animal', () {
      final outputs = ZodiacBaziAdapterBridge.adapt(
        const BaziYearAnimal(zh: '', roman: 'unicorn', en: 'Unicorn'),
      );
      expect(outputs, isEmpty);
    });
  });

  group('BaziRealAdapter zodiac runtime integration', () {
    test('adds fusion-ready zodiac themes without removing core BaZi themes', () {
      final chart = _sampleChart();
      final outputs = BaziRealAdapter.adapt(chart);
      final themeIds = outputs.map((output) => output.themeId).toSet();

      for (final themeId in _coreBaziThemeIds(chart)) {
        expect(themeIds, contains(themeId));
      }

      final zodiacOutputs = outputs.where(
        (output) => output.evidence.any(
          (evidence) => evidence.startsWith('Year Animal:'),
        ),
      );
      expect(zodiacOutputs, isNotEmpty);
    });

    test('dedupes to one output per theme and preserves higher core confidence', () {
      final chart = _sampleChart();
      final outputs = BaziRealAdapter.adapt(chart);

      final byTheme = <String, List<double>>{};
      for (final output in outputs) {
        byTheme.putIfAbsent(output.themeId, () => []).add(output.confidence);
      }

      for (final confidences in byTheme.values) {
        expect(confidences.length, 1);
      }

      final driven = outputs.firstWhere((output) => output.themeId == 'driven');
      expect(driven.confidence, greaterThan(ZodiacBaziAdapterBridge.fullConfidence));
      expect(
        driven.evidence.any((evidence) => evidence.startsWith('Dominant Element:')),
        isTrue,
      );
    });

    test('day master outputs keep primary confidence when overlapping zodiac themes exist', () {
      final chart = _sampleChart();
      final outputs = BaziRealAdapter.adapt(chart);

      final dayMasterOutputs = outputs.where(
        (output) => BaziFusionThemeMapping.themesForDayMaster(
          polarity: chart.dayMaster.polarity,
          element: chart.dayMaster.element,
        ).contains(output.themeId),
      );

      expect(dayMasterOutputs, isNotEmpty);
      expect(
        dayMasterOutputs.every((output) => output.confidence == 0.85),
        isTrue,
      );
    });

    test('integrated adapter covers all five fusion dimensions', () {
      final outputs = BaziRealAdapter.adapt(_sampleChart());
      final categories = outputs.map((output) => output.category).toSet();

      expect(
        categories.any(
          (category) =>
              category == FusionCategory.coreSelf ||
              category == FusionCategory.emotionalWorld,
        ),
        isTrue,
      );
      expect(categories, contains(FusionCategory.relationships));
      expect(
        categories.any(
          (category) =>
              category == FusionCategory.workAndAmbition ||
              category == FusionCategory.thinkingStyle,
        ),
        isTrue,
      );
      expect(categories, contains(FusionCategory.strengths));
      expect(
        categories.any(
          (category) =>
              category == FusionCategory.growthAreas ||
              category == FusionCategory.growthPath,
        ),
        isTrue,
      );
    });

    test('zodiac adds themes beyond core BaZi overlap', () {
      final chart = _sampleChart();
      final coreIds = _coreBaziThemeIds(chart).toSet();
      final zodiacOutputs = ZodiacBaziAdapterBridge.adapt(chart.yearAnimal);
      final zodiacOnlyIds = zodiacOutputs
          .map((output) => output.themeId)
          .where((id) => !coreIds.contains(id))
          .toSet();

      expect(zodiacOnlyIds.length, greaterThanOrEqualTo(5));
    });

    test('coverage audit: integration increases emitted fusion themes', () {
      final chart = _sampleChart();
      final coreOnlyCount = _coreBaziThemeIds(chart).length;
      final integratedCount = BaziRealAdapter.adapt(chart).length;
      final zodiacOnlyCount = ZodiacBaziAdapterBridge.adapt(chart.yearAnimal).length;

      expect(integratedCount, greaterThan(coreOnlyCount));
      expect(integratedCount, greaterThanOrEqualTo(coreOnlyCount + 1));
      expect(zodiacOnlyCount, greaterThanOrEqualTo(10));
    });

    test('weight tiers remain distinguishable after dedupe among zodiac-only themes', () {
      final zodiacOutputs = ZodiacBaziAdapterBridge.adapt(_sampleChart().yearAnimal);
      final fullCount = zodiacOutputs
          .where((output) => output.confidence == ZodiacBaziAdapterBridge.fullConfidence)
          .length;
      final reducedCount = zodiacOutputs
          .where(
            (output) => output.confidence == ZodiacBaziAdapterBridge.reducedConfidence,
          )
          .length;
      final growthCount = zodiacOutputs
          .where(
            (output) =>
                output.confidence == ZodiacBaziAdapterBridge.growthOnlyConfidence,
          )
          .length;

      expect(fullCount, greaterThan(0));
      expect(reducedCount, greaterThan(0));
      expect(growthCount, greaterThanOrEqualTo(0));
    });
  });
}
