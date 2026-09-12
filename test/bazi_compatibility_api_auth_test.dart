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

      await BaziApiService.generateBazi(
        uid: 'uid-1',
        birthDate: '1990-05-12',
        birthTime: null,
        timezone: 'Asia/Bangkok',
        loadAuthSession: () async =>
            const BaziAuthSession(uid: 'uid-1', idToken: 'firebase-id-token'),
        postJson:
            ({
              required endpoint,
              required body,
              required failureLabel,
              required headers,
            }) async {
              capturedBody = body;
              capturedHeaders = headers;
            },
      );

      expect(capturedBody?['uid'], 'uid-1');
      expect(capturedBody?['birth_time'], isNull);
      expect(capturedHeaders, {'Authorization': 'Bearer firebase-id-token'});
    });
  });
}

Future<void> _unexpectedPost({
  required Uri endpoint,
  required Map<String, dynamic> body,
  required String failureLabel,
  required Map<String, String> headers,
}) async {
  fail('HTTP should not be called when uid binding fails');
}
