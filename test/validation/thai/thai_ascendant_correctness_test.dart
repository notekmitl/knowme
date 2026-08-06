import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/astronomy/sidereal_ascendant.dart';
import 'package:knowme/features/astrology/thai/foundation/engines/lagna_engine.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_engine_adapter.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';

void main() {
  const oracleJulianDay = 2445126.2326352596;
  const oracleTropicalChiangMai = 342.9181424055;
  const oracleSiderealChiangMai = 319.3113756168;
  const toleranceDegrees = 0.01;

  RawBirthInput input({
    String province = 'chiang mai',
    String placeLabel = 'เชียงใหม่',
  }) => RawBirthInput(
    birthDate: DateTime(1982, 6, 6),
    birthHour: 0,
    birthMinute: 35,
    province: province,
    placeLabel: placeLabel,
    timeZoneId: 'Asia/Bangkok',
  );

  test('all supported Chiang Mai key forms resolve identically', () {
    for (final key in [
      'chiang mai',
      'chiang_mai',
      'chiang-mai',
      'CHIANG MAI',
      'เชียงใหม่',
    ]) {
      final result = BirthNormalizer.normalize(input(province: key));
      expect(result.isValid, isTrue, reason: key);
      expect(result.birth!.latitude, 18.7883, reason: key);
      expect(result.birth!.longitude, 98.9853, reason: key);
    }
  });

  test('province label cannot disagree with resolved coordinates', () {
    final result = BirthNormalizer.normalize(
      input(province: 'phuket', placeLabel: 'เชียงใหม่'),
    );
    expect(result.isValid, isFalse);
    expect(result.error, contains('does not match'));
  });

  test('known civil instant stays separate from astrological weekday date', () {
    final normalized = BirthNormalizer.normalize(input()).birth!;
    final birthData = ThaiEngineAdapter.fromNormalized(normalized);
    expect(birthData.localDateTime, DateTime(1982, 6, 6, 0, 35));
    expect(birthData.utcDateTime, DateTime.utc(1982, 6, 5, 17, 35));
    expect(birthData.utcDateTime.isUtc, isTrue);
    expect(normalized.thai.astrologicalDate, DateTime(1982, 6, 5));
    expect(birthData.utcDateTime, normalized.western.utcInstant);
  });

  test('Chiang Mai numeric layers match independent Lahiri oracle', () {
    final birthData = ThaiEngineAdapter.fromNormalized(
      BirthNormalizer.normalize(input()).birth!,
    );
    final jd = SiderealAscendant.julianDay(birthData.utcDateTime);
    final tropical = SiderealAscendant.tropicalAscendantDegrees(
      julianDay: jd,
      latitude: birthData.latitude,
      longitudeEast: birthData.longitude,
    );
    final result = LagnaEngine.calculate(birthData)!;
    expect(jd, closeTo(oracleJulianDay, 0.00001));
    expect(tropical, closeTo(oracleTropicalChiangMai, toleranceDegrees));
    expect(
      result.siderealAscendantDeg,
      closeTo(oracleSiderealChiangMai, toleranceDegrees),
    );
    expect(result.signIndex, 10);
    expect(result.lagnaKey, ThaiContentKeys.lagnaAquarius);
    expect(_display(result.siderealAscendantDeg), '19°19′');
  });

  test('Bangkok control is Aquarius near 21°54′, never Virgo', () {
    final normalized = BirthNormalizer.normalize(
      RawBirthInput(
        birthDate: DateTime(1982, 6, 6),
        birthHour: 0,
        birthMinute: 35,
        latitude: 13.7563,
        longitude: 100.5018,
        timeZoneId: 'Asia/Bangkok',
      ),
    ).birth!;
    final result = LagnaEngine.calculate(
      ThaiEngineAdapter.fromNormalized(normalized),
    )!;
    expect(result.siderealAscendantDeg, closeTo(321.9044290, toleranceDegrees));
    expect(result.lagnaKey, ThaiContentKeys.lagnaAquarius);
    expect(_display(result.siderealAscendantDeg), '21°54′');
  });

  test('whole-sign boundaries use floor on normalized longitude', () {
    expect(SiderealAscendant.wholeSignIndex(0), 0);
    expect(SiderealAscendant.wholeSignIndex(29 + 59 / 60), 0);
    expect(SiderealAscendant.wholeSignIndex(30), 1);
    expect(SiderealAscendant.wholeSignIndex(299 + 59 / 60), 9);
    expect(SiderealAscendant.wholeSignIndex(300), 10);
    expect(SiderealAscendant.wholeSignIndex(329 + 59 / 60), 10);
    expect(SiderealAscendant.wholeSignIndex(330), 11);
  });
}

String _display(double longitude) {
  final within = ((longitude % 30) + 30) % 30;
  final totalMinutes = (within * 60).round();
  return '${totalMinutes ~/ 60}°${(totalMinutes % 60).toString().padLeft(2, '0')}′';
}
