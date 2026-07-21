import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/contracts/thai_v2_engine_contract.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
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

String _canonicalBirthFingerprint(ThaiBirthData birthData) {
  final local = birthData.localDateTime;
  final year = local.year;
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final tzOffsetMinutes = birthData.timeZoneOffset.inMinutes;
  final latitude = birthData.latitude;
  final longitude = birthData.longitude;
  final hasBirthTime = birthData.hasBirthTime;

  return '$year-$month-$day|$hour:$minute|'
      '$tzOffsetMinutes|$latitude|$longitude|$hasBirthTime';
}

String _sha256Fingerprint(ThaiBirthData birthData) {
  final canonical = _canonicalBirthFingerprint(birthData);
  return sha256.convert(utf8.encode(canonical)).toString();
}

void main() {
  group('ThaiChartEngine', () {
    test('birth time available — lagna, 12 houses, empty placeholders', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );

      final chart = ThaiChartEngine.generate(birth);

      expect(chart.warnings, isEmpty);
      expect(chart.lagna, isNotNull);
      expect(chart.lagna!.signKey, ThaiContentKeys.lagnaVirgo);
      expect(chart.lagna!.signIndex, 5);
      expect(chart.houses, hasLength(12));
      expect(chart.houses.first.houseNumber, 1);
      expect(chart.houses.first.signKey, ThaiContentKeys.lagnaVirgo);
      expect(chart.houses.last.houseNumber, 12);
      expect(chart.placements, isEmpty);
      expect(chart.relationships, isEmpty);
    });

    test('no birth time — null lagna, empty houses, missing time warning', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hasBirthTime: false,
      );

      final chart = ThaiChartEngine.generate(birth);

      expect(chart.lagna, isNull);
      expect(chart.houses, isEmpty);
      expect(chart.warnings, hasLength(1));
      expect(chart.warnings.first.code, 'MISSING_BIRTH_TIME');
      expect(chart.placements, isEmpty);
      expect(chart.relationships, isEmpty);
      expect(chart.metadata.hasBirthTime, isFalse);
    });

    test('metadata validation', () {
      final birth = _bangkokBirth(
        year: 1988,
        month: 5,
        day: 10,
        hour: 14,
      );

      final chart = ThaiChartEngine.generate(birth);
      final metadata = chart.metadata;

      expect(metadata.engineVersion, ThaiV2EngineContract.engineVersion);
      expect(metadata.schemaVersion, ThaiV2EngineContract.schemaVersion);
      expect(metadata.zodiac, ThaiV2EngineContract.zodiac);
      expect(metadata.ayanamsa, ThaiV2EngineContract.ayanamsa);
      expect(metadata.houseSystem, ThaiV2EngineContract.houseSystem);
      expect(metadata.hasBirthTime, isTrue);
      expect(metadata.computedAt.isUtc, isTrue);
      expect(
        metadata.birthFingerprint,
        _sha256Fingerprint(birth),
      );
      expect(metadata.birthFingerprint, hasLength(64));
    });

    test('birth fingerprint is deterministic for the same birth input', () {
      final birth = _bangkokBirth(
        year: 1990,
        month: 1,
        day: 15,
        hour: 10,
        minute: 30,
      );

      final first = ThaiChartEngine.generate(birth);
      final second = ThaiChartEngine.generate(birth);

      expect(first.metadata.birthFingerprint, second.metadata.birthFingerprint);
    });

    test('house count validation for TC-02 lagna', () {
      final chart = ThaiChartEngine.generate(
        _bangkokBirth(year: 1988, month: 5, day: 10, hour: 14),
      );

      expect(chart.houses, hasLength(12));
      expect(chart.lagna!.signKey, ThaiContentKeys.lagnaPisces);
      expect(chart.houses[0].signKey, ThaiContentKeys.lagnaPisces);
      expect(chart.houses[1].signKey, ThaiContentKeys.lagnaAries);
    });
  });
}
