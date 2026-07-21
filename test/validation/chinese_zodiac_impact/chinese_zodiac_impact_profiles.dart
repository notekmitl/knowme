import 'package:knowme/data/models/bazi_chart_model.dart';

/// One validation profile — fixed BaZi chart with a specific Year Animal.
class ChineseZodiacImpactProfile {
  const ChineseZodiacImpactProfile({
    required this.profileId,
    required this.animalKey,
    required this.animalEn,
    required this.animalZh,
    required this.variant,
    required this.dayMasterLabel,
    required this.dominantElement,
    required this.chart,
  });

  final String profileId;
  final String animalKey;
  final String animalEn;
  final String animalZh;
  final String variant;
  final String dayMasterLabel;
  final String dominantElement;
  final BaziChartModel chart;
}

/// 24 profiles — 12 animals × 2 Day Master / Element variants.
abstract final class ChineseZodiacImpactProfiles {
  static const _animals = [
    ('rat', 'Rat', '鼠'),
    ('ox', 'Ox', '牛'),
    ('tiger', 'Tiger', '虎'),
    ('rabbit', 'Rabbit', '兔'),
    ('dragon', 'Dragon', '龙'),
    ('snake', 'Snake', '蛇'),
    ('horse', 'Horse', '马'),
    ('goat', 'Goat', '羊'),
    ('monkey', 'Monkey', '猴'),
    ('rooster', 'Rooster', '鸡'),
    ('dog', 'Dog', '狗'),
    ('pig', 'Pig', '猪'),
  ];

  static const _variantA = _DayMasterSpec(
    variant: 'A',
    stem: '丁',
    stemRoman: 'ding',
    element: 'fire',
    polarity: 'yin',
    pillarLabel: '丁丑',
    dominantElement: 'fire',
    balance: {'wood': 0, 'fire': 3, 'earth': 2, 'metal': 3, 'water': 0},
    label: 'yin_fire',
  );

  static const _variantB = _DayMasterSpec(
    variant: 'B',
    stem: '甲',
    stemRoman: 'jia',
    element: 'wood',
    polarity: 'yang',
    pillarLabel: '甲子',
    dominantElement: 'wood',
    balance: {'wood': 3, 'fire': 1, 'earth': 1, 'metal': 1, 'water': 2},
    label: 'yang_wood',
  );

  static List<ChineseZodiacImpactProfile> all() {
    final profiles = <ChineseZodiacImpactProfile>[];
    for (final animal in _animals) {
      for (final spec in [_variantA, _variantB]) {
        profiles.add(
          ChineseZodiacImpactProfile(
            profileId: '${animal.$1}_${spec.variant.toLowerCase()}',
            animalKey: animal.$1,
            animalEn: animal.$2,
            animalZh: animal.$3,
            variant: spec.variant,
            dayMasterLabel: spec.label,
            dominantElement: spec.dominantElement,
            chart: _chart(animal: animal, spec: spec),
          ),
        );
      }
    }
    return profiles;
  }

  static BaziChartModel _chart({
    required (String, String, String) animal,
    required _DayMasterSpec spec,
  }) {
    return BaziChartModel.fromMap({
      'version': 'bazi_v1',
      'engine_version': 'lunar_python@1.4.8',
      'generated_at': '2026-06-21T00:00:00.000Z',
      'input_hash': 'zodiac_impact_${animal.$1}_${spec.variant}',
      'completeness': 'four_pillars',
      'dominant_element': spec.dominantElement,
      'day_master': {
        'stem': spec.stem,
        'stem_roman': spec.stemRoman,
        'element': spec.element,
        'polarity': spec.polarity,
        'pillar_label': spec.pillarLabel,
      },
      'year_animal': {
        'zh': animal.$3,
        'roman': animal.$1,
        'en': animal.$2,
      },
      'element_balance': {
        ...spec.balance,
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

  static Map<String, dynamic> _pillar() => {
        'stem': '甲',
        'branch': '子',
        'stem_roman': 'jia',
        'branch_roman': 'zi',
        'stem_element': 'wood',
        'branch_element': 'water',
        'pillar_label': '甲子',
      };
}

class _DayMasterSpec {
  const _DayMasterSpec({
    required this.variant,
    required this.stem,
    required this.stemRoman,
    required this.element,
    required this.polarity,
    required this.pillarLabel,
    required this.dominantElement,
    required this.balance,
    required this.label,
  });

  final String variant;
  final String stem;
  final String stemRoman;
  final String element;
  final String polarity;
  final String pillarLabel;
  final String dominantElement;
  final Map<String, int> balance;
  final String label;
}
