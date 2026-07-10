import 'package:knowme/core/profile/birth_profile_format.dart';

/// Raw, un-normalized birth information exactly as the user supplied it.
///
/// This is the **only** thing the normalizer accepts. No astrology engine should
/// consume it directly — engines consume [NormalizedBirth]. Birth time is
/// optional ([birthHour] null = unknown). Coordinates are optional and, when
/// present, take priority over province/country resolution.
class RawBirthInput {
  const RawBirthInput({
    required this.birthDate,
    this.birthHour,
    this.birthMinute = 0,
    this.province,
    this.country,
    this.placeLabel,
    this.timeZoneId,
    this.latitude,
    this.longitude,
  });

  /// Date-only (year / month / day). Time lives in [birthHour]/[birthMinute].
  final DateTime birthDate;

  /// 0–23, or null when the user did not provide a birth time.
  final int? birthHour;

  /// 0–59 (ignored when [birthHour] is null).
  final int birthMinute;

  final String? province;
  final String? country;

  /// Free-text place (the app stores a single `birthPlace` string).
  final String? placeLabel;

  /// IANA-style id, e.g. `Asia/Bangkok`.
  final String? timeZoneId;

  /// Explicit coordinates (e.g. from the location picker), if known.
  final double? latitude;
  final double? longitude;

  bool get hasBirthTime => birthHour != null;

  bool get hasExplicitCoordinates =>
      latitude != null &&
      longitude != null &&
      !(latitude == 0 && longitude == 0);

  /// Date-only at midnight.
  DateTime get dateOnly =>
      DateTime(birthDate.year, birthDate.month, birthDate.day);

  /// Parses a Firestore profile map (`users/{uid}/profile/main`) into raw input.
  /// Returns null when there is no parseable birth date.
  static RawBirthInput? fromProfileMap(Map<String, dynamic> profile) {
    final birthDateRaw = profile['birthDate']?.toString().trim() ?? '';
    if (birthDateRaw.isEmpty) return null;
    final parsedDate = BirthProfileFormat.parseStoredDate(birthDateRaw);
    if (parsedDate == null) return null;

    final birthTimeRaw = profile['birthTime']?.toString().trim() ?? '';
    final hasTime =
        birthTimeRaw.isNotEmpty && birthTimeRaw.toLowerCase() != 'unknown';
    int? hour;
    var minute = 0;
    if (hasTime) {
      final parts = birthTimeRaw.split(':');
      hour = int.tryParse(parts.first);
      minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    }

    final lat = (profile['latitude'] as num?)?.toDouble();
    final lng = (profile['longitude'] as num?)?.toDouble();

    return RawBirthInput(
      birthDate: parsedDate,
      birthHour: hour,
      birthMinute: minute,
      placeLabel: profile['birthPlace']?.toString().trim(),
      province: profile['birthProvince']?.toString().trim(),
      country: profile['birthCountry']?.toString().trim(),
      timeZoneId: profile['timezone']?.toString().trim(),
      latitude: lat,
      longitude: lng,
    );
  }
}
