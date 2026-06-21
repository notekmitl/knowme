/// Sidereal lagna frame for Thai Chart V2.
class ThaiLagna {
  const ThaiLagna({
    required this.signKey,
    required this.lordKey,
    required this.siderealDeg,
    required this.signIndex,
  });

  final String signKey;
  final String lordKey;
  final double siderealDeg;
  final int signIndex;
}
