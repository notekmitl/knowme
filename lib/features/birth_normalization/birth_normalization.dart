/// Birth Normalization — the single birth-input layer for every astrology system.
///
/// Raw user input → [BirthNormalizer] → [NormalizedBirth] (Thai / Western / BaZi
/// contexts). No astrology engine should consume raw input directly; they consume
/// [NormalizedBirth]. See `docs/BIRTH_NORMALIZATION.md`.
library;

export 'application/birth_location_resolver.dart';
export 'application/birth_normalizer.dart';
export 'application/birth_time_zone_resolver.dart';
export 'application/sunrise_calculator.dart';
export 'domain/bazi_birth_context.dart';
export 'domain/birth_calendar.dart';
export 'domain/birth_location.dart';
export 'domain/birth_normalization_reason.dart';
export 'domain/birth_normalization_result.dart';
export 'domain/birth_time_zone.dart';
export 'domain/normalized_birth.dart';
export 'domain/raw_birth_input.dart';
export 'domain/thai_birth_context.dart';
export 'domain/western_birth_context.dart';
