import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';

/// Fixture aligned with backend runtime verification (1990-05-12 15:30 Bangkok).
Map<String, dynamic> _sampleChineseBaziDoc() {
  return {
    'version': 'bazi_v1',
    'engine_version': 'lunar_python@1.4.8',
    'generated_at': '2026-06-07T07:22:13.583812+00:00',
    'input_hash':
        '9e3e1aff9b78a1df65669b89e8cf51718af102d597af31b60e88b82191e6cd66',
    'completeness': 'four_pillars',
    'dominant_element': 'fire',
    'day_master': {
      'stem': '丁',
      'stem_roman': 'ding',
      'element': 'fire',
      'polarity': 'yin',
      'pillar_label': '丁丑',
    },
    'year_animal': {
      'zh': '马',
      'roman': 'horse',
      'en': 'Horse',
    },
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
      'year': _pillar(
        stem: '庚',
        branch: '午',
        stemRoman: 'geng',
        branchRoman: 'wu',
        stemElement: 'metal',
        branchElement: 'fire',
        pillarLabel: '庚午',
      ),
      'month': _pillar(
        stem: '辛',
        branch: '巳',
        stemRoman: 'xin',
        branchRoman: 'si',
        stemElement: 'metal',
        branchElement: 'fire',
        pillarLabel: '辛巳',
      ),
      'day': _pillar(
        stem: '丁',
        branch: '丑',
        stemRoman: 'ding',
        branchRoman: 'chou',
        stemElement: 'fire',
        branchElement: 'earth',
        pillarLabel: '丁丑',
      ),
      'hour': _pillar(
        stem: '戊',
        branch: '申',
        stemRoman: 'wu',
        branchRoman: 'shen',
        stemElement: 'earth',
        branchElement: 'metal',
        pillarLabel: '戊申',
      ),
    },
  };
}

Map<String, dynamic> _pillar({
  required String stem,
  required String branch,
  required String stemRoman,
  required String branchRoman,
  required String stemElement,
  required String branchElement,
  required String pillarLabel,
}) {
  return {
    'stem': stem,
    'branch': branch,
    'stem_roman': stemRoman,
    'branch_roman': branchRoman,
    'stem_element': stemElement,
    'branch_element': branchElement,
    'pillar_label': pillarLabel,
  };
}

void main() {
  group('BaziChartModel.fromMap', () {
    late BaziChartModel chart;

    setUp(() {
      chart = BaziChartModel.fromMap(_sampleChineseBaziDoc());
    });

    test('parses day_master', () {
      expect(chart.dayMaster.stem, '丁');
      expect(chart.dayMaster.stemRoman, 'ding');
      expect(chart.dayMaster.element, 'fire');
      expect(chart.dayMaster.polarity, 'yin');
      expect(chart.dayMaster.pillarLabel, '丁丑');
    });

    test('parses year_animal', () {
      expect(chart.yearAnimal.zh, '马');
      expect(chart.yearAnimal.roman, 'horse');
      expect(chart.yearAnimal.en, 'Horse');
    });

    test('parses dominant_element', () {
      expect(chart.dominantElement, 'fire');
    });

    test('parses pillars', () {
      expect(chart.pillars.year.pillarLabel, '庚午');
      expect(chart.pillars.month.pillarLabel, '辛巳');
      expect(chart.pillars.day.pillarLabel, '丁丑');
      expect(chart.pillars.hour.pillarLabel, '戊申');
      expect(chart.pillars.day.stemElement, 'fire');
      expect(chart.pillars.hour.branchElement, 'metal');
    });

    test('parses element_balance', () {
      expect(chart.elementBalance.method, 'surface_stem_branch_v1');
      expect(chart.elementBalance.totalSlots, 8);
      expect(chart.elementBalance.wood, 0);
      expect(chart.elementBalance.fire, 3);
      expect(chart.elementBalance.earth, 2);
      expect(chart.elementBalance.metal, 3);
      expect(chart.elementBalance.water, 0);
    });

    test('parses metadata fields', () {
      expect(chart.version, 'bazi_v1');
      expect(chart.engineVersion, 'lunar_python@1.4.8');
      expect(chart.generatedAt, isNotEmpty);
      expect(chart.inputHash.length, 64);
      expect(chart.completeness, 'four_pillars');
    });
  });
}
