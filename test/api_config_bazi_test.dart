import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/config/api_config.dart';

void main() {
  test('new astrology clients use authenticated versioned endpoints', () {
    expect(
      ApiConfig.baziGenerateUri().toString(),
      '${ApiConfig.astrologyBaseUrl}/v1/generate-bazi',
    );
    expect(
      ApiConfig.astrologyGenerateChartUri().toString(),
      '${ApiConfig.astrologyBaseUrl}/v1/generate-chart',
    );
  });

  test('legacy endpoint identities stay explicit during adoption', () {
    expect(
      ApiConfig.legacyBaziGenerateUri().toString(),
      '${ApiConfig.astrologyBaseUrl}/generate-bazi',
    );
    expect(
      ApiConfig.legacyAstrologyGenerateChartUri().toString(),
      '${ApiConfig.astrologyBaseUrl}/generate-chart',
    );
  });
}
