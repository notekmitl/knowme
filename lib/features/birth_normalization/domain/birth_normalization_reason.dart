/// Why the normalizer made the choices it did. Every [NormalizedBirth] carries a
/// list of these so downstream systems (and tests) can trace exactly how raw
/// input became normalized birth data — no hidden assumptions.
enum BirthNormalizationReason {
  /// A real birth time was provided and used.
  birthTimeProvided,

  /// No birth time — noon was assumed (so Thai resolves to the same day).
  birthTimeMissingNoonAssumed,

  /// Born before local sunrise → the Thai astrological date is the previous day.
  bornBeforeLocalSunrise,

  /// Born at/after local sunrise → the Thai astrological date is the same day.
  bornAfterLocalSunrise,

  /// Sunrise could not be computed for this latitude/date (polar) — no Thai day
  /// shift was applied.
  sunriseUnavailableNoShift,

  /// Coordinates came directly from the input (e.g. the location picker).
  locationFromExplicitCoordinates,

  /// Coordinates were resolved from a known province.
  locationResolvedFromProvince,

  /// Coordinates were resolved from a known country.
  locationResolvedFromCountry,

  /// No usable location — defaulted to Bangkok (Thai-first product default).
  locationDefaultedToBangkok,

  /// The timezone id resolved to a known UTC offset.
  timeZoneResolved,

  /// Unknown/empty timezone — defaulted to Asia/Bangkok (+07:00).
  timeZoneDefaultedToBangkok,

  /// Western uses the exact astronomical instant; no day adjustment is applied.
  westernUsesExactInstant,

  /// BaZi normalization is not implemented yet (adapter placeholder only).
  baziNotImplemented,
}
