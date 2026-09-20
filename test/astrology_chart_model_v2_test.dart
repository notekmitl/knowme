import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';

void main() {
  test('parses Western V2 metadata, analysis, aspects, and reader', () {
    final chart = AstrologyChartModel.fromMap({
      'version': 'western_natal_v2',
      'contract_id': 'knowme_western_reader_v2',
      'engine_version': 'swiss-v2',
      'input_hash': 'owner-hash',
      'big3': {'sun': 'Gemini', 'moon': 'Sagittarius', 'rising': 'Pisces'},
      'planets': {
        'sun': {'sign': 'Gemini', 'house': 3},
      },
      'houses': {'ascendant': 333.0, 'system': 'Placidus'},
      'aspects': [
        {
          'planet1': 'sun',
          'planet2': 'moon',
          'aspect': 'opposition',
          'orb': 1.2,
        },
      ],
      'analysis': {
        'elements': {
          'percentages': {'fire': 30, 'earth': 10, 'air': 40, 'water': 20},
          'dominant': 'air',
        },
      },
      'reader': {
        'version': 'western_reader_th_v2',
        'overview': {'th': 'ภาพรวม'},
      },
      'insight': <String, dynamic>{},
      'overall_summary': <String, dynamic>{},
    });

    expect(chart.version, 'western_natal_v2');
    expect(chart.contractId, 'knowme_western_reader_v2');
    expect(chart.engineVersion, 'swiss-v2');
    expect(chart.inputHash, 'owner-hash');
    expect(chart.houses['system'], 'Placidus');
    expect(chart.aspects.single['orb'], 1.2);
    expect(chart.analysis['elements'], isA<Map>());
    expect(chart.reader['version'], 'western_reader_th_v2');
  });
}
