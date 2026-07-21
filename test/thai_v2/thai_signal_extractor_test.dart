import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/engines/mahabhuta_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/engines/myanmar_seven_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_fact_type.dart';
import 'package:knowme/features/astrology/thai/signal/models/thai_signal_source.dart';
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

List<String> _structuralSignalIds(ThaiSignalExtractorResult result) {
  return result.bundle.signals
      .where(
        (signal) =>
            signal.source == ThaiSignalSource.sidereal ||
            signal.source == ThaiSignalSource.house,
      )
      .map((signal) => signal.signalId)
      .toList();
}

void main() {
  group('ThaiSignalExtractor', () {
    test('signal count — 26 structural signals when birth time is available', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );
      final chart = ThaiChartEngine.generate(birth);
      final result = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );

      final structural = result.bundle.signals
          .where(
            (signal) =>
                signal.source == ThaiSignalSource.sidereal ||
                signal.source == ThaiSignalSource.house,
          )
          .toList();

      expect(structural, hasLength(26));
      expect(
        structural.where((s) => s.factType == ThaiSignalFactType.lagnaSign),
        hasLength(1),
      );
      expect(
        structural.where((s) => s.factType == ThaiSignalFactType.lagnaLord),
        hasLength(1),
      );
      expect(
        structural.where((s) => s.factType == ThaiSignalFactType.houseSign),
        hasLength(12),
      );
      expect(
        structural.where((s) => s.factType == ThaiSignalFactType.houseLord),
        hasLength(12),
      );
    });

    test('no birth time — no lagna or house signals', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hasBirthTime: false,
      );
      final chart = ThaiChartEngine.generate(birth);
      final result = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );

      expect(
        result.bundle.signals.where(
          (signal) =>
              signal.source == ThaiSignalSource.sidereal ||
              signal.source == ThaiSignalSource.house,
        ),
        isEmpty,
      );
      expect(result.bundle.hasBirthTime, isFalse);
    });

    test('deterministic bundle id for the same chart input', () {
      final birth = _bangkokBirth(
        year: 1988,
        month: 5,
        day: 10,
        hour: 14,
      );
      final chart = ThaiChartEngine.generate(birth);

      final first = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );
      final second = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );

      expect(first.bundle.bundleId, second.bundle.bundleId);
      expect(
        first.bundle.signals.map((signal) => signal.signalId).toList(),
        second.bundle.signals.map((signal) => signal.signalId).toList(),
      );
    });

    test('lagna parity with chart', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );
      final chart = ThaiChartEngine.generate(birth);
      final result = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );

      final lagnaSign = result.bundle.signals.firstWhere(
        (signal) => signal.factType == ThaiSignalFactType.lagnaSign,
      );
      final lagnaLord = result.bundle.signals.firstWhere(
        (signal) => signal.factType == ThaiSignalFactType.lagnaLord,
      );

      expect(lagnaSign.contentKeyRefs, [chart.lagna!.signKey]);
      expect(lagnaLord.contentKeyRefs, [chart.lagna!.lordKey]);
      expect(lagnaSign.signalId, 'lagna_sign_virgo');
      expect(lagnaLord.signalId, 'lagna_lord_mercury');
    });

    test('house parity with chart', () {
      final birth = _bangkokBirth(
        year: 1988,
        month: 5,
        day: 10,
        hour: 14,
      );
      final chart = ThaiChartEngine.generate(birth);
      final result = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );

      for (final house in chart.houses) {
        final signSignal = result.bundle.signals.firstWhere(
          (signal) => signal.signalId == 'house_${house.houseNumber}_sign_${house.signKey.replaceFirst('lagna_', '')}',
        );
        final lordSignal = result.bundle.signals.firstWhere(
          (signal) => signal.signalId == 'house_${house.houseNumber}_lord_${house.lordKey.replaceFirst('lagna_lord_', '')}',
        );

        expect(signSignal.contentKeyRefs, [house.signKey]);
        expect(lordSignal.contentKeyRefs, [house.lordKey]);
      }
    });

    test('seven numbers adapter — GC-05 birth data', () {
      final birth = _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2);
      final chart = ThaiChartEngine.generate(birth);
      final myanmar = MyanmarSevenEngine.calculate(birth);
      final mahabhuta = MahabhutaEngine.calculate(birth);

      final result = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );

      final myanmarSignals = result.bundle.signals
          .where((signal) => signal.factType == ThaiSignalFactType.myanmarPosition)
          .toList();
      final mahabhutaSignals = result.bundle.signals
          .where(
            (signal) =>
                signal.factType == ThaiSignalFactType.mahabhutaPosition,
          )
          .toList();

      expect(myanmarSignals, hasLength(myanmar.myanmarKeys.length));
      expect(mahabhutaSignals, hasLength(mahabhuta.mahabhutaPositionKeys.length));

      for (final key in myanmar.myanmarKeys) {
        expect(
          result.bundle.signals.any((signal) => signal.signalId == key),
          isTrue,
        );
      }

      for (final key in mahabhuta.mahabhutaPositionKeys) {
        expect(
          result.bundle.signals.any(
            (signal) => signal.signalId == key,
          ),
          isTrue,
        );
      }

      expect(_structuralSignalIds(result), hasLength(26));
    });

    test('signals contain no theme or category fields', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );
      final chart = ThaiChartEngine.generate(birth);
      final result = ThaiSignalExtractor.extract(
        ThaiSignalExtractorInput(chart: chart, birthData: birth),
      );

      for (final signal in result.bundle.signals) {
        expect(signal.facts.containsKey('themeId'), isFalse);
        expect(signal.facts.containsKey('categoryHint'), isFalse);
      }
    });
  });
}
