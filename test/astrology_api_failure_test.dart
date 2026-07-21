import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/network/astrology_api_failure.dart';

void main() {
  test('AstrologyApiFailure includes endpoint status and body', () {
    const failure = AstrologyApiFailure(
      endpoint: 'https://api.example.com/generate-bazi',
      message: 'Failed to generate BaZi chart',
      statusCode: 500,
      responseBody: '{"detail":"FIRESTORE_SAVE_FAILED"}',
    );

    expect(
      failure.toString(),
      contains('https://api.example.com/generate-bazi'),
    );
    expect(failure.toString(), contains('HTTP 500'));
    expect(failure.toString(), contains('FIRESTORE_SAVE_FAILED'));
  });
}
