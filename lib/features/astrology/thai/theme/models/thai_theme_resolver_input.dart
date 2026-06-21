/// Content keys from each Thai astrology lens to aggregate into theme signals.
class ThaiThemeResolverInput {
  const ThaiThemeResolverInput({
    this.lagnaKey,
    this.lagnaLordKey,
    this.ramahabhutaKey,
    this.mahabhutaPositionKeys = const [],
    this.myanmarKeys = const [],
  });

  final String? lagnaKey;
  final String? lagnaLordKey;
  final String? ramahabhutaKey;
  final List<String> mahabhutaPositionKeys;
  final List<String> myanmarKeys;
}
