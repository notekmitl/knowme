import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/services/astrology_api_service.dart';
import 'package:knowme/services/bazi_api_service.dart';

void main() {
  test('overall BaZi request has no Firebase identity or profile', () async {
    final chart = await BaziApiService.calculateBazi(
      birthDate: '2001-01-15',
      birthTime: '12:34',
      timezone: 'Asia/Bangkok',
      latitude: 13.7563,
      longitude: 100.5018,
      gender: 'female',
      postJson:
          ({
            required endpoint,
            required body,
            required failureLabel,
            required headers,
          }) async {
            expect(endpoint.path, '/v1/calculate-bazi');
            expect(headers, isEmpty);
            expect(body.keys, isNot(contains('uid')));
            expect(body.keys, isNot(contains('profile')));
            expect(body['birth_time'], '12:34');
            return {'chart': _baziChart};
          },
    );
    expect(chart.inputHash, 'qa-input');
  });

  test('overall Western request has no Firebase identity or profile', () async {
    final chart = await AstrologyApiService.calculateChart(
      birthDate: '2001-01-15',
      birthTime: '12:34',
      timezone: 'Asia/Bangkok',
      latitude: 13.7563,
      longitude: 100.5018,
      postJson:
          ({
            required endpoint,
            required body,
            required failureLabel,
            required headers,
          }) async {
            expect(endpoint.path, '/v1/calculate-chart');
            expect(headers, isEmpty);
            expect(body.keys, isNot(contains('uid')));
            expect(body.keys, isNot(contains('profile')));
            expect(body['birth_time'], '12:34');
            return {'chart': _westernChart};
          },
    );
    expect(chart.inputHash, 'qa-input');
  });
}

const _baziChart = <String, dynamic>{
  'version': 'knowme_bazi_reader_v3',
  'engine_version': 'test',
  'generated_at': '2026-09-24T00:00:00Z',
  'input_hash': 'qa-input',
  'completeness': 'four_pillars',
  'day_master': <String, dynamic>{},
  'year_animal': <String, dynamic>{},
  'pillars': <String, dynamic>{},
  'element_balance': <String, dynamic>{},
};

const _westernChart = <String, dynamic>{
  'version': 'western_natal_v2',
  'contract_id': 'knowme_western_reader_v2',
  'engine_version': 'test',
  'input_hash': 'qa-input',
  'big3': <String, dynamic>{
    'sun': 'Capricorn',
    'moon': 'Libra',
    'rising': 'Taurus',
  },
  'planets': <String, dynamic>{},
  'insight': <String, dynamic>{},
  'overall_summary': <String, dynamic>{},
};
