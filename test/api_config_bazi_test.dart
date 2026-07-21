import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/config/api_config.dart';

void main() {
  test('baziGenerateUri points to generate-bazi endpoint', () {
    expect(
      ApiConfig.baziGenerateUri().toString(),
      '${ApiConfig.astrologyBaseUrl}/generate-bazi',
    );
  });
}
