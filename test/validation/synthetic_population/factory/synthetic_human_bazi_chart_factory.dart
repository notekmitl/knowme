import 'package:knowme/data/models/bazi_chart_model.dart';

/// Builds coherent BaZi charts for synthetic population profiles.
abstract final class SyntheticHumanBaziChartFactory {
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

  static const _dayMasters = [
    _DayMasterSpec(
      label: 'yin_fire',
      stem: '丁',
      stemRoman: 'ding',
      element: 'fire',
      polarity: 'yin',
      pillarLabel: '丁丑',
      dominantElement: 'fire',
      balance: {'wood': 0, 'fire': 3, 'earth': 2, 'metal': 3, 'water': 0},
    ),
    _DayMasterSpec(
      label: 'yang_wood',
      stem: '甲',
      stemRoman: 'jia',
      element: 'wood',
      polarity: 'yang',
      pillarLabel: '甲子',
      dominantElement: 'wood',
      balance: {'wood': 3, 'fire': 1, 'earth': 1, 'metal': 1, 'water': 2},
    ),
    _DayMasterSpec(
      label: 'yang_metal',
      stem: '庚',
      stemRoman: 'geng',
      element: 'metal',
      polarity: 'yang',
      pillarLabel: '庚申',
      dominantElement: 'metal',
      balance: {'wood': 1, 'fire': 0, 'earth': 2, 'metal': 4, 'water': 1},
    ),
    _DayMasterSpec(
      label: 'yin_water',
      stem: '癸',
      stemRoman: 'gui',
      element: 'water',
      polarity: 'yin',
      pillarLabel: '癸亥',
      dominantElement: 'water',
      balance: {'wood': 1, 'fire': 0, 'earth': 1, 'metal': 1, 'water': 5},
    ),
  ];

  static BaziChartModel build({
    required String profileId,
    required int animalIndex,
    required int dayMasterSpecIndex,
    required int animalShift,
  }) {
    final animal = _animals[(animalIndex + animalShift) % _animals.length];
    final spec = _dayMasters[dayMasterSpecIndex % _dayMasters.length];

    return BaziChartModel.fromMap({
      'version': 'bazi_v1',
      'engine_version': 'lunar_python@1.4.8',
      'generated_at': '2026-06-21T00:00:00.000Z',
      'input_hash': 'synthetic_population_$profileId',
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

  static String animalKey(int animalIndex, {int shift = 0}) {
    return _animals[(animalIndex + shift) % _animals.length].$1;
  }

  static String dayMasterLabel(int dayMasterSpecIndex) {
    return _dayMasters[dayMasterSpecIndex % _dayMasters.length].label;
  }

  static String dominantElement(int dayMasterSpecIndex) {
    return _dayMasters[dayMasterSpecIndex % _dayMasters.length].dominantElement;
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
    required this.label,
    required this.stem,
    required this.stemRoman,
    required this.element,
    required this.polarity,
    required this.pillarLabel,
    required this.dominantElement,
    required this.balance,
  });

  final String label;
  final String stem;
  final String stemRoman;
  final String element;
  final String polarity;
  final String pillarLabel;
  final String dominantElement;
  final Map<String, int> balance;
}
