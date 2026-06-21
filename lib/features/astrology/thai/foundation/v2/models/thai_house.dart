/// Structural whole-sign house slot for Thai Chart V2.
///
/// Contains placement facts only — no domain, category, or interpretation fields.
class ThaiHouse {
  const ThaiHouse({
    required this.houseNumber,
    required this.signKey,
    required this.lordKey,
  });

  final int houseNumber;
  final String signKey;
  final String lordKey;
}
