import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/services/astrology_api_service.dart';

void main() {
  group('AstrologyApiService authentication', () {
    test('rejects a session uid that does not match the request uid', () async {
      expect(
        () => AstrologyApiService.generateChart(
          uid: 'victim',
          birthDate: '1990-05-12',
          birthTime: '15:30',
          latitude: 13.7563,
          longitude: 100.5018,
          loadAuthSession: () async =>
              const WesternAuthSession(uid: 'attacker', idToken: 'valid-token'),
          postJson: _unexpectedPost,
        ),
        throwsStateError,
      );
    });

    test('binds bearer token and uses the versioned endpoint', () async {
      Uri? capturedEndpoint;
      Map<String, dynamic>? capturedBody;
      Map<String, String>? capturedHeaders;

      await AstrologyApiService.generateChart(
        uid: 'uid-1',
        birthDate: '1990-05-12',
        birthTime: '15:30',
        latitude: 13.7563,
        longitude: 100.5018,
        loadAuthSession: () async => const WesternAuthSession(
          uid: 'uid-1',
          idToken: 'firebase-id-token',
        ),
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

      expect(capturedEndpoint?.path, '/v1/generate-chart');
      expect(capturedBody?['uid'], 'uid-1');
      expect(capturedBody?['birth_time'], '15:30');
      expect(capturedBody?['timezone'], 'Asia/Bangkok');
      expect(capturedHeaders, {'Authorization': 'Bearer firebase-id-token'});
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
  'chart': <String, dynamic>{
    'version': 'western_natal_v2',
    'contract_id': 'knowme_western_reader_v2',
    'engine_version': 'engine-v2',
    'input_hash': 'hash',
    'big3': {'sun': 'Taurus', 'moon': 'Sagittarius', 'rising': 'Libra'},
    'planets': <String, dynamic>{},
    'insight': <String, dynamic>{},
    'overall_summary': <String, dynamic>{},
  },
};
