import '../domain/birth_location.dart';
import '../domain/raw_birth_input.dart';
import 'thai_provinces.dart';

class _Coord {
  const _Coord(this.lat, this.lng);
  final double lat;
  final double lng;
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
  static final Map<String, _Coord> _provinces = {
    for (final p in kThaiProvincesAll)
      p.key: _Coord(p.latitude, p.longitude),
    for (final entry in kThaiProvinceAliases.entries)
      if (_coordFor(entry.value) != null) entry.key: _coordFor(entry.value)!,
  };

  static _Coord? _coordFor(String key) {
    for (final p in kThaiProvincesAll) {
      if (p.key == key) return _Coord(p.latitude, p.longitude);
    }
    return null;
  }

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

  static BirthLocation resolve(RawBirthInput input) {
    if (input.hasExplicitCoordinates) {
      return BirthLocation(
        latitude: input.latitude!,
        longitude: input.longitude!,
        source: BirthLocationSource.explicit,
        province: input.province,
        country: input.country,
        label: input.placeLabel,
      );
    }

    final provinceKey = input.province?.trim().toLowerCase();
    if (provinceKey != null && _provinces.containsKey(provinceKey)) {
      final c = _provinces[provinceKey]!;
      return BirthLocation(
        latitude: c.lat,
        longitude: c.lng,
        source: BirthLocationSource.resolvedFromProvince,
        province: input.province,
        country: input.country,
        label: input.placeLabel,
      );
    }

    final countryKey = input.country?.trim().toLowerCase();
    if (countryKey != null && _countries.containsKey(countryKey)) {
      final c = _countries[countryKey]!;
      return BirthLocation(
        latitude: c.lat,
        longitude: c.lng,
        source: BirthLocationSource.resolvedFromCountry,
        province: input.province,
        country: input.country,
        label: input.placeLabel,
      );
    }

    return const BirthLocation(
      latitude: bangkokLat,
      longitude: bangkokLng,
      source: BirthLocationSource.defaulted,
    );
  }
}
