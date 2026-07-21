import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/thai_foundation_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_fact_type.dart';
import 'package:knowme/features/astrology/thai/signal/thai_signal_extractor.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
  bool hasBirthTime = true,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: hasBirthTime,
  );
}

String _chartDeterministicKey(ThaiBirthData birth) {
  final chart = ThaiChartEngine.generate(birth);
  final lagna = chart.lagna;
  final houses = chart.houses
      .map((house) => '${house.houseNumber}:${house.signKey}:${house.lordKey}')
      .join(';');
  final warnings = chart.warnings.map((warning) => warning.code).join(',');
  return '${chart.metadata.birthFingerprint}|'
      '${chart.metadata.hasBirthTime}|'
      '${lagna?.signKey}|${lagna?.lordKey}|${lagna?.signIndex}|${lagna?.siderealDeg}|'
      '$houses|$warnings';
}

String _bundleDeterministicKey(ThaiBirthData birth) {
  final chart = ThaiChartEngine.generate(birth);
  final result = ThaiSignalExtractor.extract(
    ThaiSignalExtractorInput(chart: chart, birthData: birth),
  );
  final signalIds = result.bundle.signals
      .map((signal) => signal.signalId)
      .toList()
    ..sort();
  return '${result.bundle.bundleId}|${result.bundle.hasBirthTime}|'
      '${result.bundle.extractorVersion}|${signalIds.join(',')}';
}

void _assertV1V2Parity(ThaiBirthData birth, {required String caseId}) {
  final v1 = ThaiFoundationEngine.generate(birth);
  final chart = ThaiChartEngine.generate(birth);
  final v2 = ThaiSignalExtractor.extract(
    ThaiSignalExtractorInput(chart: chart, birthData: birth),
  );

  if (birth.hasBirthTime) {
    expect(v1.lagnaKey, chart.lagna?.signKey, reason: '$caseId lagna chart');
    expect(v1.lagnaLordKey, chart.lagna?.lordKey, reason: '$caseId lagna lord chart');

    final lagnaSign = v2.bundle.signals.firstWhere(
      (signal) => signal.factType == ThaiSignalFactType.lagnaSign,
    );
    final lagnaLord = v2.bundle.signals.firstWhere(
      (signal) => signal.factType == ThaiSignalFactType.lagnaLord,
    );
    expect(lagnaSign.contentKeyRefs, [v1.lagnaKey], reason: '$caseId lagna sign signal');
    expect(lagnaLord.contentKeyRefs, [v1.lagnaLordKey], reason: '$caseId lagna lord signal');
  } else {
    expect(v1.lagnaKey, isNull, reason: '$caseId v1 no lagna');
    expect(chart.lagna, isNull, reason: '$caseId chart no lagna');
    expect(
      v2.bundle.signals.where(
        (signal) =>
            signal.factType == ThaiSignalFactType.lagnaSign ||
            signal.factType == ThaiSignalFactType.lagnaLord,
      ),
      isEmpty,
      reason: '$caseId no lagna signals',
    );
  }

  final v2MyanmarKeys = v2.bundle.signals
      .where((signal) => signal.factType == ThaiSignalFactType.myanmarPosition)
      .map((signal) => signal.contentKeyRefs.single)
      .toSet();
  final v2MahabhutaKeys = v2.bundle.signals
      .where((signal) => signal.factType == ThaiSignalFactType.mahabhutaPosition)
      .map((signal) => signal.contentKeyRefs.single)
      .toSet();

  expect(v2MyanmarKeys, v1.myanmarKeys.toSet(), reason: '$caseId myanmar keys');
  expect(
    v2MahabhutaKeys,
    v1.mahabhutaPositionKeys.toSet(),
    reason: '$caseId mahabhuta keys',
  );
}

void main() {
  group('A5 Parity — V1 Foundation vs V2 Signal Layer', () {
    test('TC-01 lagna, lord, seven numbers', () {
      _assertV1V2Parity(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
        caseId: 'TC-01',
      );
    });

    test('TC-02 lagna, lord, seven numbers', () {
      _assertV1V2Parity(
        _bangkokBirth(year: 1988, month: 5, day: 10, hour: 14),
        caseId: 'TC-02',
      );
    });

    test('GC-05 lagna, lord, seven numbers', () {
      _assertV1V2Parity(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
        caseId: 'GC-05',
      );
    });

    test('no birth time — seven numbers only', () {
      _assertV1V2Parity(
        _bangkokBirth(year: 1990, month: 1, day: 15, hasBirthTime: false),
        caseId: 'NO_TIME',
      );
    });
  });

  group('A5 Determinism — 100 iterations', () {
    final birth = _bangkokBirth(
      year: 1990,
      month: 1,
      day: 15,
      hour: 10,
      minute: 30,
    );

    test('ThaiChart structural fields are stable across 100 runs', () {
      final baseline = _chartDeterministicKey(birth);
      for (var i = 0; i < 100; i++) {
        expect(
          _chartDeterministicKey(birth),
          baseline,
          reason: 'iteration $i',
        );
      }
    });

    test('ThaiSignalBundle deterministic key is stable across 100 runs', () {
      final baseline = _bundleDeterministicKey(birth);
      for (var i = 0; i < 100; i++) {
        expect(
          _bundleDeterministicKey(birth),
          baseline,
          reason: 'iteration $i',
        );
      }
    });
  });

  group('A5 Seven Numbers signalId naming audit', () {
    test('signalId equals contentKey for seven numbers', () {
      final birth = _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2);
      final chart = ThaiChartEngine.generate(birth);
      final result = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );

      for (final signal in result.bundle.signals.where(
        (signal) =>
            signal.factType == ThaiSignalFactType.myanmarPosition ||
            signal.factType == ThaiSignalFactType.mahabhutaPosition,
      )) {
        expect(signal.signalId, signal.contentKeyRefs.single);
      }
    });
  });
}
