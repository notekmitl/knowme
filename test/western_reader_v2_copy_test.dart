import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/presentation/pages/astrology/western_reader_v2_copy.dart';

void main() {
  final chart = AstrologyChartModel.fromMap({
    'version': 'western_natal_v2',
    'contract_id': 'knowme_western_reader_v2',
    'engine_version': 'swiss-v2',
    'input_hash': 'owner-hash',
    'big3': {'sun': 'Gemini', 'moon': 'Sagittarius', 'rising': 'Pisces'},
    'planets': <String, dynamic>{},
    'insight': <String, dynamic>{},
    'overall_summary': <String, dynamic>{},
    'analysis': {
      'elements': {
        'percentages': {'fire': 30, 'earth': 10, 'air': 40, 'water': 20},
        'dominant': 'air',
      },
      'dominant_planets': [
        {'planet': 'sun', 'score': 8},
      ],
    },
    'reader': {
      'version': 'western_reader_th_v2_r2',
      'overview': {'th': 'ภาพรวมดวงของคุณ'},
      'sections': [
        {
          'id': 'work',
          'title': 'การงาน',
          'body': 'อ่านเรื่องงาน',
          'basis': 'ดาวพุธราศีเมถุน',
        },
        {'id': 'money', 'title': 'การเงิน', 'body': 'อ่านเรื่องเงิน'},
      ],
      'method': 'Swiss Ephemeris',
      'disclaimer': 'เป็นแนวโน้ม ไม่ใช่คำยืนยัน',
    },
  });

  test('recognizes the current V2 reader revision and exposes basis', () {
    expect(WesternReaderV2Copy.isCurrent(chart), isTrue);
    expect(WesternReaderV2Copy.overview(chart), 'ภาพรวมดวงของคุณ');
    expect(WesternReaderV2Copy.sections(chart).map((section) => section.id), [
      'work',
      'money',
    ]);
    expect(WesternReaderV2Copy.sections(chart).first.basis, 'ดาวพุธราศีเมถุน');
    expect(WesternReaderV2Copy.sections(chart).last.basis, isEmpty);
    expect(WesternReaderV2Copy.method(chart), 'Swiss Ephemeris');
    expect(WesternReaderV2Copy.disclaimer(chart), 'เป็นแนวโน้ม ไม่ใช่คำยืนยัน');
  });

  test(
    'rejects the stale V2 reader revision while preserving the contract',
    () {
      final stale = AstrologyChartModel.fromMap({
        'version': WesternReaderV2Copy.chartVersion,
        'contract_id': WesternReaderV2Copy.contractId,
        'big3': <String, dynamic>{},
        'planets': <String, dynamic>{},
        'insight': <String, dynamic>{},
        'overall_summary': <String, dynamic>{},
        'reader': {'version': 'western_reader_th_v2'},
      });

      expect(WesternReaderV2Copy.isCurrent(stale), isFalse);
      expect(stale.version, WesternReaderV2Copy.chartVersion);
      expect(stale.contractId, WesternReaderV2Copy.contractId);
    },
  );

  test('parses percentages and Thai labels deterministically', () {
    expect(WesternReaderV2Copy.balance(chart, 'elements')['air'], 40);
    expect(WesternReaderV2Copy.dominant(chart, 'elements'), 'air');
    expect(WesternReaderV2Copy.signLabel('Pisces'), 'มีน');
    expect(WesternReaderV2Copy.planetLabel('saturn'), 'ดาวเสาร์');
    expect(WesternReaderV2Copy.houseLabel(10), 'อาชีพและชื่อเสียง');
  });
}
