import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/presentation/providers/astrology_provider.dart';

void main() {
  test('uses API chart directly without Firestore freshness reload', () async {
    var loadCalls = 0;
    var generateCalls = 0;
    final chart = _chart();
    final provider = AstrologyProvider(
      loadChartFn: (_) async {
        loadCalls++;
        return null;
      },
      generateChartFn:
          ({
            required uid,
            required birthDate,
            required birthTime,
            required latitude,
            required longitude,
          }) async {
            generateCalls++;
            return chart;
          },
    );

    await provider.generateChart(
      uid: 'uid-1',
      birthDate: '1982-06-06',
      birthTime: '00:03',
      latitude: 18.7883,
      longitude: 98.9853,
    );

    expect(generateCalls, 1);
    expect(loadCalls, 0);
    expect(provider.chart, same(chart));
    expect(provider.error, isNull);
  });

  test('accepts a chart prepared by the selection handoff', () {
    final provider = AstrologyProvider(loadChartFn: (_) async => null);
    final chart = _chart();

    provider.usePreparedChart(chart);

    expect(provider.chart, same(chart));
    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
  });
}

AstrologyChartModel _chart() => AstrologyChartModel(
  version: 'western_natal_v2',
  contractId: 'knowme_western_reader_v2',
  engineVersion: 'engine-v2',
  inputHash: 'hash',
  big3: const {'sun': 'Gemini', 'moon': 'Sagittarius', 'rising': 'Pisces'},
  planets: const {},
  insight: const {},
  overallSummary: const {},
  reader: const {'version': 'western_reader_th_v2'},
);
