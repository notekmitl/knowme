/// How a [BirthLocation]'s coordinates were determined.
enum BirthLocationSource {
  explicit,
  resolvedFromProvince,
  resolvedFromCountry,
  defaulted,
}

/// A resolved birth place with the coordinates every engine needs.
class BirthLocation {
  const BirthLocation({
    required this.latitude,
    required this.longitude,
    required this.source,
    this.province,
    this.country,
    this.label,
  });

  final double latitude;
  final double longitude;
  final BirthLocationSource source;

  final String? province;
  final String? country;
  final String? label;
}
