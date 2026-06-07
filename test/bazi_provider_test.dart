import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/presentation/providers/bazi_provider.dart';

BaziChartModel _sampleChart() {
  return BaziChartModel.fromMap({
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

void main() {
  group('BaziProvider.loadChart', () {
    test('load success sets chart and clears error', () async {
      final sample = _sampleChart();
      final provider = BaziProvider(
        loadChartFn: (_) async => sample,
      );

      await provider.loadChart('uid-1');

      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.chart, same(sample));
      expect(provider.chart?.dayMaster.element, 'fire');
    });

    test('load empty leaves chart null without error', () async {
      final provider = BaziProvider(
        loadChartFn: (_) async => null,
      );

      await provider.loadChart('uid-empty');

      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.chart, isNull);
    });
  });

  group('BaziProvider.generateBazi', () {
    test('api error sets error and skips chart reload', () async {
      var loadCalls = 0;
      final provider = BaziProvider(
        loadChartFn: (_) async {
          loadCalls++;
          return _sampleChart();
        },
        generateBaziFn: ({
          required String uid,
          required String birthDate,
          required String birthTime,
          required String timezone,
          double? latitude,
          double? longitude,
        }) async {
          throw Exception('Failed to generate BaZi chart');
        },
      );

      await provider.generateBazi(
        uid: 'uid-1',
        birthDate: '1990-05-12',
        birthTime: '15:30',
        timezone: 'Asia/Bangkok',
      );

      expect(provider.isLoading, isFalse);
      expect(provider.error, contains('Failed to generate BaZi chart'));
      expect(provider.chart, isNull);
      expect(loadCalls, 0);
    });
  });
}
