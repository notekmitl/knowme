/// HS1 — canonical semantic source types for fusion-derived human meaning.
enum HumanSemanticSourceType {
  agreement('agreement'),
  tension('tension'),
  reinforcement('reinforcement'),
  blindSpot('blind_spot');

  const HumanSemanticSourceType(this.key);

  final String key;

  static HumanSemanticSourceType? parse(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final value in values) {
      if (value.key == normalized) return value;
    }
    return null;
  }
}
