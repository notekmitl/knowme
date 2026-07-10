import '../domain/birth_time_zone.dart';

/// Resolves a timezone id to a fixed UTC offset.
///
/// Fixed offsets (no DST) — correct for Thailand and most of the supported
/// region. Unknown/empty ids default to Asia/Bangkok (+07:00), the Thai-first
/// product default. Add ids here as new markets are supported.
abstract final class BirthTimeZoneResolver {
  static const Map<String, Duration> _offsets = {
    'asia/bangkok': Duration(hours: 7),
    'asia/jakarta': Duration(hours: 7),
    'asia/ho_chi_minh': Duration(hours: 7),
    'asia/phnom_penh': Duration(hours: 7),
    'asia/vientiane': Duration(hours: 7),
    'asia/singapore': Duration(hours: 8),
    'asia/kuala_lumpur': Duration(hours: 8),
    'asia/manila': Duration(hours: 8),
    'asia/shanghai': Duration(hours: 8),
    'asia/hong_kong': Duration(hours: 8),
    'asia/tokyo': Duration(hours: 9),
    'asia/seoul': Duration(hours: 9),
    'asia/kolkata': Duration(hours: 5, minutes: 30),
    'asia/yangon': Duration(hours: 6, minutes: 30),
    'asia/dubai': Duration(hours: 4),
    'europe/london': Duration.zero,
    'utc': Duration.zero,
    'america/new_york': Duration(hours: -5),
    'america/los_angeles': Duration(hours: -8),
    'australia/sydney': Duration(hours: 10),
  };

  static BirthTimeZone resolve(String? id) {
    final key = id?.trim().toLowerCase() ?? '';
    if (key.isEmpty) return BirthTimeZone.bangkok;
    final offset = _offsets[key];
    if (offset == null) return BirthTimeZone.bangkok;
    return BirthTimeZone(
      id: id!.trim(),
      utcOffset: offset,
      resolved: true,
    );
  }
}
