import '../../foundation/models/thai_birth_data.dart';
import 'thai_mirror_population_profile.dart';

/// Deterministic synthetic profile generator for Population QA.
abstract final class ThaiMirrorPopulationGenerator {
  static const defaultCount = 120;
  static const minNoBirthTimeRatio = 0.35;

  static const _bangkokOffset = Duration(hours: 7);

  static const _locations = <({double lat, double lon, String label})>[
    (lat: 13.75, lon: 100.50, label: 'Bangkok'),
    (lat: 18.79, lon: 98.98, label: 'Chiang Mai'),
    (lat: 7.88, lon: 98.39, label: 'Phuket'),
    (lat: 16.43, lon: 102.83, label: 'Khon Kaen'),
  ];

  /// Birth years spanning six decades for population spread.
  static const _years = <int>[
    1962,
    1968,
    1974,
    1980,
    1986,
    1992,
    1998,
    2004,
    2010,
    2016,
  ];

  /// Generates [count] balanced synthetic profiles (default 120).
  static List<ThaiMirrorPopulationProfile> generate({
    int count = defaultCount,
  }) {
    if (count <= 0) return const [];

    return List<ThaiMirrorPopulationProfile>.generate(count, (index) {
      final gender = index.isEven
          ? ThaiMirrorPopulationGender.male
          : ThaiMirrorPopulationGender.female;
      final month = (index % 12) + 1;
      final year = _years[(index ~/ 12) % _years.length];
      final day = (index % 28) + 1;
      final hasBirthTime = !_isNoBirthTimeSlot(index);
      final location = _locations[index % _locations.length];

      final hour = hasBirthTime ? (index ~/ 3) % 24 : 12;
      final minute = hasBirthTime ? (index % 4) * 15 : 0;

      return ThaiMirrorPopulationProfile(
        id: 'POP-${(index + 1).toString().padLeft(3, '0')}',
        gender: gender,
        cohortIndex: index,
        birthData: ThaiBirthData(
          localDateTime: DateTime(year, month, day, hour, minute),
          timeZoneOffset: _bangkokOffset,
          latitude: location.lat,
          longitude: location.lon,
          hasBirthTime: hasBirthTime,
        ),
      );
    }, growable: false);
  }

  /// Seven of every twenty profiles omit birth time (35%).
  static bool _isNoBirthTimeSlot(int index) => (index % 20) < 7;

  static double noBirthTimeRatioFor(List<ThaiMirrorPopulationProfile> profiles) {
    if (profiles.isEmpty) return 0;
    final without =
        profiles.where((profile) => !profile.hasBirthTime).length;
    return without / profiles.length;
  }
}
