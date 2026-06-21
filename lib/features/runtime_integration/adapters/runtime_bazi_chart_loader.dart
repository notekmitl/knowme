import 'package:knowme/data/models/bazi_chart_model.dart';

/// RT2 — loads BaZi chart for runtime mirror integration.
abstract final class RuntimeBaziChartLoader {
  /// QA profile aligned with Thai runtime sample (1972-04-04 Bangkok).
  /// Horse year · Yin Fire Day Master · fire-dominant balance.
  static BaziChartModel loadQaProfile() {
    return BaziChartModel.fromMap({
      'version': 'bazi_v1',
      'engine_version': 'lunar_python@1.4.8',
      'generated_at': '2026-06-21T00:00:00.000Z',
      'input_hash': 'runtime_qa_1972_04_04',
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
          'stem': '壬',
          'branch': '子',
          'stem_roman': 'ren',
          'branch_roman': 'zi',
          'stem_element': 'water',
          'branch_element': 'water',
          'pillar_label': '壬子',
        },
        'month': {
          'stem': '癸',
          'branch': '卯',
          'stem_roman': 'gui',
          'branch_roman': 'mao',
          'stem_element': 'water',
          'branch_element': 'wood',
          'pillar_label': '癸卯',
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
          'stem': '辛',
          'branch': '丑',
          'stem_roman': 'xin',
          'branch_roman': 'chou',
          'stem_element': 'metal',
          'branch_element': 'earth',
          'pillar_label': '辛丑',
        },
      },
    });
  }
}
