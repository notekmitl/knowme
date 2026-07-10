/// Normalized birth data for **BaZi** — placeholder only.
///
/// BaZi normalization (true solar time + solar-term/month-pillar boundaries) is
/// **not implemented yet**. This carries the raw instant so the shape of
/// [NormalizedBirth] is stable; [implemented] is always false until a real BaZi
/// adapter lands. No engine should rely on it for chart logic yet.
class BaZiBirthContext {
  const BaZiBirthContext.placeholder({
    required this.localDateTime,
    required this.utcInstant,
    required this.latitude,
    required this.longitude,
  });

  final DateTime localDateTime;
  final DateTime utcInstant;
  final double latitude;
  final double longitude;

  bool get implemented => false;
}
