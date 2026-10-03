import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/config/api_config.dart';

/// Run with KNOWME_OVERALL_TRIAL=true and a separate calculator URL.
void main() {
  test('normal release separates anonymous calculations from saved charts', () {
    expect(ApiConfig.isOverallTrial, isTrue);
    expect(ApiConfig.isOverallPreview, isFalse);
    expect(ApiConfig.astrologyGenerateChartUri().host,
        'knowme-astrology-api-avbyttircq-as.a.run.app');
    expect(ApiConfig.baziGenerateUri().host,
        'knowme-astrology-api-avbyttircq-as.a.run.app');
    expect(ApiConfig.astrologyCalculateChartUri().host,
        'calculator.example.invalid');
    expect(ApiConfig.baziCalculateUri().host,
        'calculator.example.invalid');
  }, skip: !ApiConfig.isOverallTrial || ApiConfig.isOverallPreview);
}
