import '../domain/birth_location.dart';
import '../domain/raw_birth_input.dart';
import 'thai_provinces.dart';

class _Coord {
  const _Coord(this.lat, this.lng);
  final double lat;
  final double lng;
}

class BirthLocationResolution {
  const BirthLocationResolution.success(this.location) : error = null;
  const BirthLocationResolution.invalid(this.error) : location = null;

  final BirthLocation? location;
  final String? error;
  bool get isValid => location != null && error == null;
}

/// Resolves a [BirthLocation] from raw input.
///
/// Priority: explicit coordinates → known province → known country → Bangkok
/// default (Thai-first). The province table covers all 77 Thai provinces (see
/// [kThaiProvincesAll]); explicit coordinates (from the location picker) remain
/// the highest-priority production path.
abstract final class BirthLocationResolver {
  static const double bangkokLat = 13.7563;
  static const double bangkokLng = 100.5018;

  /// Coordinate per Thai province, built from the canonical 77-province table
  /// plus common English aliases — so every selectable province resolves.
  static final Map<String, ThaiProvince> _provinces = {
    for (final province in kThaiProvincesAll)
      _normalizeKey(province.key): province,
    for (final province in kThaiProvincesAll) province.nameTh: province,
    for (final entry in kThaiProvinceAliases.entries)
      _normalizeKey(entry.key): ?_provinceForCanonicalKey(entry.value),
  };

  static ThaiProvince? _provinceForCanonicalKey(String key) {
    for (final p in kThaiProvincesAll) {
      if (p.key == key) return p;
    }
    return null;
  }

  static String _normalizeKey(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  /// A representative coordinate per country (capital / major city).
  static const Map<String, _Coord> _countries = {
    'thailand': _Coord(13.7563, 100.5018),
    'laos': _Coord(17.9757, 102.6331),
    'cambodia': _Coord(11.5564, 104.9282),
    'vietnam': _Coord(21.0278, 105.8342),
    'myanmar': _Coord(16.8409, 96.1735),
    'malaysia': _Coord(3.1390, 101.6869),
    'singapore': _Coord(1.3521, 103.8198),
    'indonesia': _Coord(-6.2088, 106.8456),
    'china': _Coord(39.9042, 116.4074),
    'japan': _Coord(35.6762, 139.6503),
    'india': _Coord(28.6139, 77.2090),
    'united states': _Coord(38.9072, -77.0369),
    'united kingdom': _Coord(51.5072, -0.1276),
    'australia': _Coord(-33.8688, 151.2093),
  };

  static BirthLocationResolution resolve(RawBirthInput input) {
    if (input.hasExplicitCoordinates) {
      return BirthLocationResolution.success(
        BirthLocation(
          latitude: input.latitude!,
          longitude: input.longitude!,
          source: BirthLocationSource.explicit,
          province: input.province,
          country: input.country,
          label: input.placeLabel,
        ),
      );
    }

    final provinceValue = input.province?.trim() ?? '';
    if (provinceValue.isNotEmpty) {
      final province = _provinces[_normalizeKey(provinceValue)];
      if (province == null) {
        return BirthLocationResolution.invalid(
          'Unknown province key: $provinceValue',
        );
      }
      final label = input.placeLabel?.trim() ?? '';
      final labelledProvince = label.isEmpty
          ? null
          : _provinces[_normalizeKey(label)];
      if (labelledProvince != null && labelledProvince.key != province.key) {
        return BirthLocationResolution.invalid(
          'Province label does not match resolved coordinates.',
        );
      }
      return BirthLocationResolution.success(
        BirthLocation(
          latitude: province.latitude,
          longitude: province.longitude,
          source: BirthLocationSource.resolvedFromProvince,
          province: input.province,
          country: input.country,
          label: input.placeLabel,
        ),
      );
    }

    final countryValue = input.country?.trim() ?? '';
    final countryKey = _normalizeKey(countryValue);
    if (countryValue.isNotEmpty && _countries.containsKey(countryKey)) {
      final c = _countries[countryKey]!;
      return BirthLocationResolution.success(
        BirthLocation(
          latitude: c.lat,
          longitude: c.lng,
          source: BirthLocationSource.resolvedFromCountry,
          province: input.province,
          country: input.country,
          label: input.placeLabel,
        ),
      );
    }
    if (countryValue.isNotEmpty) {
      return BirthLocationResolution.invalid(
        'Unknown country key: $countryValue',
      );
    }

    return const BirthLocationResolution.success(
      BirthLocation(
        latitude: bangkokLat,
        longitude: bangkokLng,
        source: BirthLocationSource.defaulted,
      ),
    );
  }
}
