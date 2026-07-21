import 'bazi_birth_context.dart';
import 'birth_calendar.dart';
import 'birth_location.dart';
import 'birth_normalization_reason.dart';
import 'birth_time_zone.dart';
import 'raw_birth_input.dart';
import 'thai_birth_context.dart';
import 'western_birth_context.dart';

/// The single normalized birth artifact every astrology system consumes.
///
/// It bundles the raw input, the resolved location/timezone/calendar, the
/// computed local sunrise, and one ready-to-use birth context per system
/// (Thai, Western, BaZi placeholder) — plus the [reasons] that explain every
/// normalization choice.
class NormalizedBirth {
  const NormalizedBirth({
    required this.raw,
    required this.location,
    required this.timeZone,
    required this.calendar,
    required this.sunrise,
    required this.sunriseAvailable,
    required this.thai,
    required this.western,
    required this.bazi,
    required this.reasons,
  });

  final RawBirthInput raw;
  final BirthLocation location;
  final BirthTimeZone timeZone;
  final BirthCalendar calendar;

  /// Local sunrise on the civil birth date.
  final DateTime sunrise;
  final bool sunriseAvailable;

  final ThaiBirthContext thai;
  final WesternBirthContext western;
  final BaZiBirthContext bazi;

  final List<BirthNormalizationReason> reasons;

  double get latitude => location.latitude;
  double get longitude => location.longitude;
}
