import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi/application/bazi_theme_engine.dart';

BaziChartModel _sampleChart() {
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

void main() {
  test('build is deterministic for same chart and language', () {
    final chart = _sampleChart();
    final a = BaziThemeEngine.build(chart, 'en');
    final b = BaziThemeEngine.build(chart, 'en');
    expect(a.coreSelf, b.coreSelf);
    expect(a.strengths, b.strengths);
    expect(a.growthAreas, b.growthAreas);
  });

  test('yin fire day master produces reflective core self', () {
    final theme = BaziThemeEngine.build(_sampleChart(), 'en');
    expect(theme.coreSelf.toLowerCase(), contains('inspiration'));
    expect(theme.strengths.length, greaterThanOrEqualTo(3));
    expect(theme.growthAreas.length, greaterThanOrEqualTo(3));
  });

  test('hero symbol narrative uses chinese astrology framing', () {
    final chart = _sampleChart();
    expect(
      BaziThemeEngine.heroSymbolNarrative(chart.dayMaster, 'en').toLowerCase(),
      contains('symbol'),
    );
    expect(
      BaziThemeEngine.heroContextLine('th'),
      'ในมุมมองของดวงจีน',
    );
  });

  test('dominant highlight maps fire element associations', () {
    final highlight = BaziThemeEngine.dominantHighlight(_sampleChart(), 'en');
    expect(highlight, isNotNull);
    expect(highlight!.headline, 'Prominent Fire');
    expect(highlight.associations.length, 4);
    expect(highlight.associations, contains('Drive'));
  });
}
