import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/services/bazi_api_service.dart';

void main() {
  group('BaziApiService authentication', () {
    test('rejects a session uid that does not match the request uid', () async {
      expect(
        () => BaziApiService.generateBazi(
          uid: 'victim',
          birthDate: '1990-05-12',
          birthTime: null,
          timezone: 'Asia/Bangkok',
          loadAuthSession: () async =>
              const BaziAuthSession(uid: 'attacker', idToken: 'valid-token'),
          postJson: _unexpectedPost,
        ),
        throwsStateError,
      );
    });

    test('binds Bearer token and uid and sends Unknown time as null', () async {
      Map<String, dynamic>? capturedBody;
      Map<String, String>? capturedHeaders;
      Uri? capturedEndpoint;

      final chart = await BaziApiService.generateBazi(
        uid: 'uid-1',
        birthDate: '1990-05-12',
        birthTime: null,
        timezone: 'Asia/Bangkok',
        gender: 'male',
        canonicalProfile: _profile,
        loadAuthSession: () async =>
            const BaziAuthSession(uid: 'uid-1', idToken: 'firebase-id-token'),
        postJson:
            ({
              required endpoint,
              required body,
              required failureLabel,
              required headers,
            }) async {
              capturedEndpoint = endpoint;
              capturedBody = body;
              capturedHeaders = headers;
              return _response;
            },
      );

      expect(capturedBody?['uid'], 'uid-1');
      expect(capturedBody?['birth_time'], isNull);
      expect(capturedBody?['gender'], 'male');
      expect(capturedBody?['profile'], _profile);
      expect(capturedEndpoint?.path, '/v1/generate-bazi');
      expect(capturedHeaders, {'Authorization': 'Bearer firebase-id-token'});
      expect(chart.inputHash, 'test-input-hash');
    });

    test(
      'sends all three QA locations to the versioned calculation API',
      () async {
        final cases = [
          (
            place: 'กรุงเทพมหานคร',
            date: '1990-12-05',
            time: '15:30',
            latitude: 13.7563,
            longitude: 100.5018,
          ),
          (
            place: 'เชียงใหม่',
            date: '1982-06-06',
            time: '00:35',
            latitude: 18.7883,
            longitude: 98.9853,
          ),
          (
            place: 'ภูเก็ต',
            date: '2001-03-03',
            time: '23:45',
            latitude: 7.8804,
            longitude: 98.3923,
          ),
        ];

        for (final fixture in cases) {
          Map<String, dynamic>? capturedBody;
          final profile = <String, dynamic>{
            'name': 'Owner QA',
            'gender': 'male',
            'birthDate': fixture.date,
            'birthTime': fixture.time,
            'birthPlace': fixture.place,
            'latitude': fixture.latitude,
            'longitude': fixture.longitude,
            'timezone': 'Asia/Bangkok',
          };

          await BaziApiService.generateBazi(
            uid: 'uid-1',
            birthDate: fixture.date,
            birthTime: fixture.time,
            timezone: 'Asia/Bangkok',
            gender: 'male',
            latitude: fixture.latitude,
            longitude: fixture.longitude,
            canonicalProfile: profile,
            loadAuthSession: () async =>
                const BaziAuthSession(uid: 'uid-1', idToken: 'token'),
            postJson:
                ({
                  required endpoint,
                  required body,
                  required failureLabel,
                  required headers,
                }) async {
                  capturedBody = body;
                  return _response;
                },
          );

          expect(capturedBody?['birth_date'], fixture.date);
          expect(capturedBody?['birth_time'], fixture.time);
          expect(capturedBody?['timezone'], 'Asia/Bangkok');
          expect(capturedBody?['latitude'], fixture.latitude);
          expect(capturedBody?['longitude'], fixture.longitude);
          expect(capturedBody?['profile'], profile);
          expect(
            (capturedBody?['profile'] as Map<String, dynamic>)['birthPlace'],
            fixture.place,
          );
        }
      },
    );

    test('fails closed when a successful response omits chart data', () async {
      await expectLater(
        BaziApiService.generateBazi(
          uid: 'uid-1',
          birthDate: '1990-05-12',
          birthTime: '15:00',
          timezone: 'Asia/Bangkok',
          loadAuthSession: () async =>
              const BaziAuthSession(uid: 'uid-1', idToken: 'token'),
          postJson:
              ({
                required endpoint,
                required body,
                required failureLabel,
                required headers,
              }) async => {'success': true},
        ),
        throwsFormatException,
      );
    });
  });
}

Future<Map<String, dynamic>> _unexpectedPost({
  required Uri endpoint,
  required Map<String, dynamic> body,
  required String failureLabel,
  required Map<String, String> headers,
}) async {
  fail('HTTP should not be called when uid binding fails');
}

final _response = <String, dynamic>{
  'success': true,
  'chart': {
    'version': 'knowme_bazi_reader_v3',
    'engine_version': 'test',
    'generated_at': '2026-09-19T00:00:00Z',
    'input_hash': 'test-input-hash',
    'completeness': 'four_pillars',
    'day_master': <String, dynamic>{},
    'year_animal': <String, dynamic>{},
    'pillars': <String, dynamic>{},
    'element_balance': <String, dynamic>{},
  },
};

final _profile = <String, dynamic>{
  'name': 'Test User',
  'gender': 'male',
  'birthDate': '1990-05-12',
  'birthTime': '',
  'birthPlace': 'Bangkok',
  'latitude': 13.7563,
  'longitude': 100.5018,
  'timezone': 'Asia/Bangkok',
};
