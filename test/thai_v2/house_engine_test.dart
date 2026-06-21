import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/constants/thai_lagna_rulership.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/house_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/sidereal_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/models/thai_lagna.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: true,
  );
}

void main() {
  group('HouseEngine', () {
    test('TC-01 Bangkok 1990-01-15 10:30 — whole-sign houses', () {
      final lagna = SiderealEngine.calculate(
        _bangkokBirth(year: 1990, month: 1, day: 15, hour: 10, minute: 30),
      ).lagna!;

      final houses = HouseEngine.calculate(lagna: lagna);

      expect(houses, hasLength(12));
      expect(houses[0].houseNumber, 1);
      expect(houses[0].signKey, ThaiContentKeys.lagnaVirgo);
      expect(houses[0].lordKey, ThaiContentKeys.lagnaLordMercury);
      expect(houses[6].houseNumber, 7);
      expect(houses[6].signKey, ThaiContentKeys.lagnaPisces);
      expect(houses[6].lordKey, ThaiContentKeys.lagnaLordJupiter);
      expect(houses[11].houseNumber, 12);
      expect(houses[11].signKey, ThaiContentKeys.lagnaLeo);
      expect(houses[11].lordKey, ThaiContentKeys.lagnaLordSun);
    });

    test('TC-02 Bangkok 1988-05-10 14:00 — whole-sign houses', () {
      final lagna = SiderealEngine.calculate(
        _bangkokBirth(year: 1988, month: 5, day: 10, hour: 14),
      ).lagna!;

      final houses = HouseEngine.calculate(lagna: lagna);

      expect(houses, hasLength(12));
      expect(houses[0].signKey, ThaiContentKeys.lagnaPisces);
      expect(houses[0].lordKey, ThaiContentKeys.lagnaLordJupiter);
      expect(houses[1].houseNumber, 2);
      expect(houses[1].signKey, ThaiContentKeys.lagnaAries);
      expect(houses[1].lordKey, ThaiContentKeys.lagnaLordMars);
      expect(houses[9].houseNumber, 10);
      expect(houses[9].signKey, ThaiContentKeys.lagnaSagittarius);
      expect(houses[9].lordKey, ThaiContentKeys.lagnaLordJupiter);
    });

    test('house matrix validation for all 12 lagna sign indexes', () {
      for (var lagnaIndex = 0; lagnaIndex < 12; lagnaIndex++) {
        final signKey = ThaiContentKeys.allLagna[lagnaIndex];
        final lagna = ThaiLagna(
          signKey: signKey,
          lordKey: ThaiLagnaRulership.lordForLagna(signKey)!,
          siderealDeg: 0.0,
          signIndex: lagnaIndex,
        );

        final houses = HouseEngine.calculate(lagna: lagna);

        expect(houses, hasLength(12));

        for (var i = 0; i < 12; i++) {
          final house = houses[i];
          final expectedSignIndex =
              (lagnaIndex + house.houseNumber - 1) % ThaiContentKeys.allLagna.length;
          final expectedSignKey = ThaiContentKeys.allLagna[expectedSignIndex];
          final expectedLordKey =
              ThaiLagnaRulership.lordForLagna(expectedSignKey)!;

          expect(house.houseNumber, i + 1);
          expect(house.signKey, expectedSignKey);
          expect(house.lordKey, expectedLordKey);
        }
      }
    });
  });
}
