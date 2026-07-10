/// A resolved timezone: an id plus the fixed UTC offset used for normalization.
///
/// The app currently has no DST-aware tz database dependency; offsets are fixed
/// (correct for Thailand and most of the supported region, which observe no DST).
class BirthTimeZone {
  const BirthTimeZone({
    required this.id,
    required this.utcOffset,
    required this.resolved,
  });

  /// IANA-style id, e.g. `Asia/Bangkok`.
  final String id;

  final Duration utcOffset;

  /// False when the id was unknown/empty and the default was applied.
  final bool resolved;

  double get offsetHours => utcOffset.inMinutes / 60.0;

  static const BirthTimeZone bangkok = BirthTimeZone(
    id: 'Asia/Bangkok',
    utcOffset: Duration(hours: 7),
    resolved: true,
  );
}
