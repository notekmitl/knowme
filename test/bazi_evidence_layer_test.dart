import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi/application/bazi_evidence_layer.dart';

BaziChartModel _chartWithBalance(Map<String, int> counts, {String? dominant}) {
  return BaziChartModel.fromMap({
    'version': 'bazi_v1',
    'engine_version': 'test',
    'generated_at': '2026-01-01T00:00:00Z',
    'input_hash': 'x',
    'completeness': 'four_pillars',
    'dominant_element': dominant,
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
  test('dominant summary when fire and metal tie uses missing copy first', () {
    final chart = _chartWithBalance({
      'wood': 0,
      'fire': 3,
      'earth': 2,
      'metal': 3,
      'water': 0,
    }, dominant: 'fire');
    final summary = BaziEvidenceLayer.elementBalanceSummary(chart, 'th');
    expect(summary, contains('ไม่พบ'));
  });

  test('missing element summary for single absent water', () {
    final chart = _chartWithBalance({
      'wood': 2,
      'fire': 2,
      'earth': 2,
      'metal': 2,
      'water': 0,
    });
    final summary = BaziEvidenceLayer.elementBalanceSummary(chart, 'en');
    expect(summary, 'No Water in the main structure');
  });

  test('balanced summary when spread is narrow', () {
    final chart = _chartWithBalance({
      'wood': 2,
      'fire': 2,
      'earth': 2,
      'metal': 1,
      'water': 1,
    });
    final summary = BaziEvidenceLayer.elementBalanceSummary(chart, 'th');
    expect(summary, contains('สมดุล'));
  });

  test('dominant-only summary when one element leads', () {
    final chart = _chartWithBalance({
      'wood': 1,
      'fire': 4,
      'earth': 1,
      'metal': 1,
      'water': 1,
    });
    final summary = BaziEvidenceLayer.elementBalanceSummary(chart, 'en');
    expect(summary, 'Fire is fairly prominent');
  });

  test('balanced summary note appears only when spread is narrow', () {
    final chart = _chartWithBalance({
      'wood': 2,
      'fire': 2,
      'earth': 2,
      'metal': 1,
      'water': 1,
    });
    expect(
      BaziEvidenceLayer.elementBalanceSummaryNote(chart, 'th'),
      contains('ค่าใกล้เคียง'),
    );
    expect(
      BaziEvidenceLayer.elementBalanceSummaryNote(chart, 'en'),
      isNotNull,
    );
  });

  test('balanced summary note is null when one element leads', () {
    final chart = _chartWithBalance({
      'wood': 1,
      'fire': 4,
      'earth': 1,
      'metal': 1,
      'water': 1,
    });
    expect(BaziEvidenceLayer.elementBalanceSummaryNote(chart, 'th'), isNull);
  });

  test('element legend lists all five elements with icons', () {
    final lines = BaziEvidenceLayer.elementLegendLines('th');
    expect(lines.length, 5);
    expect(lines[0], contains('🌱'));
    expect(lines[0], contains('ไม้'));
    expect(lines[4], contains('🌊'));
    expect(lines[4], contains('น้ำ'));
  });

  test('formatPillarElements adds icons to stem and branch', () {
    expect(
      BaziEvidenceLayer.formatPillarElements('water', 'earth', 'en'),
      '🌊 Water / 🏔 Earth',
    );
  });

  test('formatHeavenlyStem maps stem character to element and polarity', () {
    final pillar = _chartWithBalance({}).pillars.day;
    expect(
      BaziEvidenceLayer.formatHeavenlyStem(pillar, 'th'),
      '丁 (ไฟหยิน)',
    );
    expect(
      BaziEvidenceLayer.formatHeavenlyStem(pillar, 'en'),
      '丁 (Yin Fire)',
    );
  });

  test('formatEarthlyBranch maps branch character to zodiac animal', () {
    final yearPillar = _chartWithBalance({}).pillars.year;
    expect(
      BaziEvidenceLayer.formatEarthlyBranch(yearPillar, 'th'),
      '午 (ม้า)',
    );
    expect(
      BaziEvidenceLayer.formatEarthlyBranch(
        _chartWithBalance({}).pillars.day,
        'en',
      ),
      '丑 (Ox)',
    );
  });

  test('pillar role labels include structural context', () {
    expect(
      BaziEvidenceLayer.pillarRoleLabel('day', 'th'),
      'วัน (แก่นตัวตน)',
    );
    expect(
      BaziEvidenceLayer.pillarRoleLabel('year', 'en'),
      'Year (foundation and environment)',
    );
  });

  test('element balance observations for dominant spread', () {
    final chart = _chartWithBalance({
      'wood': 1,
      'fire': 2,
      'earth': 1,
      'metal': 2,
      'water': 2,
    });
    final observations =
        BaziEvidenceLayer.elementBalanceObservations(chart, 'th');
    expect(observations.length, 3);
    expect(observations[0], contains('ไฟ'));
    expect(observations[0], contains('เด่น'));
    expect(observations[1], contains('ไม้'));
    expect(observations[2], contains('สมดุล'));
  });

  test('element balance observations for missing element', () {
    final chart = _chartWithBalance({
      'wood': 0,
      'fire': 3,
      'earth': 1,
      'metal': 2,
      'water': 2,
    });
    final observations =
        BaziEvidenceLayer.elementBalanceObservations(chart, 'th');
    expect(observations[0], contains('ไม่พบธาตุไม้'));
    expect(observations[1], contains('ไฟ'));
    expect(observations[2], contains('แตกต่าง'));
  });

  test('element balance observations for perfectly balanced chart', () {
    final chart = _chartWithBalance({
      'wood': 2,
      'fire': 2,
      'earth': 2,
      'metal': 2,
      'water': 2,
    });
    final observations =
        BaziEvidenceLayer.elementBalanceObservations(chart, 'th');
    expect(observations[0], contains('ใกล้เคียง'));
    expect(observations[1], contains('โดดเด่น'));
    expect(observations[2], contains('สมดุล'));
  });

  test('element balance how to read avoids judgment language', () {
    final text = BaziEvidenceLayer.elementBalanceHowToRead('th');
    expect(text, contains('ไม่ได้หมายถึงดีกว่า'));
    expect(text, isNot(contains('คุณ')));
  });
}
