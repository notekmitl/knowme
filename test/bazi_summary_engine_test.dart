import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi/application/bazi_summary_engine.dart';

BaziChartModel _chartWithBalance(Map<String, int> counts) {
  return BaziChartModel.fromMap({
    'version': 'bazi_v1',
    'engine_version': 'test',
    'generated_at': '2026-01-01T00:00:00Z',
    'input_hash': 'x',
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
      'wood': counts['wood'] ?? 0,
      'fire': counts['fire'] ?? 0,
      'earth': counts['earth'] ?? 0,
      'metal': counts['metal'] ?? 0,
      'water': counts['water'] ?? 0,
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
  test('dominant spread summary translates visible energies', () {
    final summary = BaziSummaryEngine.build(
      _chartWithBalance({
        'wood': 1,
        'fire': 2,
        'earth': 1,
        'metal': 2,
        'water': 2,
      }),
      'th',
    );

    expect(summary.paragraph1, contains('ธาตุประจำตัว'));
    expect(summary.paragraph1, contains('ไฟหยิน'));
    expect(summary.paragraph1, contains('ดวงนี้มีองค์ประกอบของไฟ ทอง และน้ำ'));
    expect(summary.paragraph1, contains('ซึ่งในศาสตร์จีนมักถูกเชื่อมโยงกับ'));
    expect(summary.paragraph1, contains('การแสดงออก'));
    expect(summary.paragraph1, isNot(contains('\n\nพลังของ')));
    expect(summary.paragraph2, contains('ดวงลักษณะนี้มักให้ภาพของคนที่'));
    expect(summary.paragraph2, contains('กล้าแสดงออกในสิ่งที่คิด'));
    expect(summary.paragraph2, contains('พยายามมองสถานการณ์ให้ชัดก่อนตัดสินใจ'));
    expect(summary.paragraph2, isNot(contains('\n\n')));
    expect(summary.paragraph2, isNot(contains('คุณเป็นคน')));
    expect(summary.paragraph3, contains('ค่อนข้างสมดุล'));
  });

  test('balanced chart summary avoids personality language', () {
    final summary = BaziSummaryEngine.build(
      _chartWithBalance({
        'wood': 2,
        'fire': 2,
        'earth': 2,
        'metal': 2,
        'water': 2,
      }),
      'th',
    );

    expect(summary.paragraph1, contains('ธาตุประจำตัว'));
    expect(summary.paragraph1, contains('ธาตุทั้งห้าปรากฏกระจายตัว'));
    expect(summary.paragraph2, contains('ดวงลักษณะนี้มักให้ภาพของคนที่'));
    expect(summary.paragraph2, contains('ดึงจุดแข็งของแต่ละองค์ประกอบ'));
    expect(summary.paragraph3, isNotNull);
    expect(summary.paragraph1, isNot(contains('คุณเป็นคน')));
  });

  test('missing element summary omits broad balance paragraph', () {
    final summary = BaziSummaryEngine.build(
      _chartWithBalance({
        'wood': 0,
        'fire': 3,
        'earth': 1,
        'metal': 2,
        'water': 2,
      }),
      'th',
    );

    expect(summary.paragraph1, contains('ไฟ'));
    expect(summary.paragraph3, isNull);
  });

  test('summary is deterministic', () {
    final chart = _chartWithBalance({
      'wood': 1,
      'fire': 2,
      'earth': 1,
      'metal': 2,
      'water': 2,
    });
    final first = BaziSummaryEngine.build(chart, 'en');
    final second = BaziSummaryEngine.build(chart, 'en');
    expect(first.paragraph1, second.paragraph1);
    expect(first.paragraph2, second.paragraph2);
    expect(first.paragraph3, second.paragraph3);
  });
}
