import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/sidereal_engine.dart';

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

void main() {
  group('SiderealEngine', () {
    test('returns null lagna and warning when birth time is missing', () {
      final result = SiderealEngine.calculate(
        _bangkokBirth(
          year: 1990,
          month: 1,
          day: 15,
          hasBirthTime: false,
        ),
      );

      expect(result.lagna, isNull);
      expect(result.warnings, hasLength(1));
      expect(result.warnings.first.code, 'MISSING_BIRTH_TIME');
      expect(result.warnings.first.severity.name, 'high');
      expect(result.warnings.first.affectedFields, ['lagnaKey', 'lagnaLordKey']);
    });

    test('TC-01 Bangkok 1990-01-15 10:30 — deterministic lagna', () {
      final result = SiderealEngine.calculate(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      );

      expect(result.warnings, isEmpty);
      expect(result.lagna, isNotNull);
      expect(result.lagna!.signKey, ThaiContentKeys.lagnaVirgo);
      expect(result.lagna!.signIndex, 5);
      expect(result.lagna!.lordKey, ThaiContentKeys.lagnaLordMercury);
      expect(result.lagna!.siderealDeg, inInclusiveRange(0.0, 360.0));
    });

    test('TC-02 Bangkok 1988-05-10 14:00 — deterministic lagna', () {
      final result = SiderealEngine.calculate(
        _bangkokBirth(year: 1988, month: 5, day: 10, hour: 14),
      );

      expect(result.warnings, isEmpty);
      expect(result.lagna, isNotNull);
      expect(result.lagna!.signKey, ThaiContentKeys.lagnaPisces);
      expect(result.lagna!.signIndex, 11);
      expect(result.lagna!.lordKey, ThaiContentKeys.lagnaLordJupiter);
      expect(result.lagna!.siderealDeg, inInclusiveRange(0.0, 360.0));
    });
  });
}
