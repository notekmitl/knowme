import 'package:knowme/features/birth_normalization/domain/normalized_birth.dart';

/// JSON-safe snapshot of the Birth Normalization output for one submission.
///
/// Drives both the "ข้อมูลที่ใช้คำนวณ" debug panel and the Firestore record, so
/// the exact resolved inputs behind a report are always recoverable.
class ThaiBetaNormalizedSnapshot {
  const ThaiBetaNormalizedSnapshot({
    required this.rawBirthDate,
    required this.birthTime,
    required this.province,
    required this.sunrise,
    required this.sunriseAvailable,
    required this.thaiAstrologicalDate,
    required this.usedPreviousDay,
    required this.timeZoneId,
    required this.utcOffsetHours,
    required this.latitude,
    required this.longitude,
    required this.locationSource,
    required this.reasons,
  });

  /// Civil birth date, `yyyy-MM-dd`.
  final String rawBirthDate;

  /// `HH:mm`, or empty when no birth time was provided.
  final String birthTime;

  /// Province label as entered, or empty.
  final String province;

  /// Local sunrise `HH:mm` on the civil birth date.
  final String sunrise;
  final bool sunriseAvailable;

  /// Sunrise-adjusted Thai astrological date, `yyyy-MM-dd`.
  final String thaiAstrologicalDate;

  /// True when the birth was before local sunrise (previous day used).
  final bool usedPreviousDay;

  final String timeZoneId;
  final double utcOffsetHours;

  final double latitude;
  final double longitude;

  /// How coordinates were resolved (explicit / province / country / defaulted).
  final String locationSource;

  /// Traceable normalization reasons.
  final List<String> reasons;

  bool get hasBirthTime => birthTime.isNotEmpty;

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  factory ThaiBetaNormalizedSnapshot.fromNormalizedBirth(NormalizedBirth birth) {
    final raw = birth.raw;
    final hasTime = raw.hasBirthTime;
    return ThaiBetaNormalizedSnapshot(
      rawBirthDate: _date(raw.birthDate),
      birthTime: hasTime
          ? '${raw.birthHour!.toString().padLeft(2, '0')}:${raw.birthMinute.toString().padLeft(2, '0')}'
          : '',
      province: (birth.location.label ?? birth.location.province ?? '').trim(),
      sunrise: _time(birth.sunrise),
      sunriseAvailable: birth.sunriseAvailable,
      thaiAstrologicalDate: _date(birth.thai.astrologicalDate),
      usedPreviousDay: birth.thai.bornBeforeSunrise,
      timeZoneId: birth.timeZone.id,
      utcOffsetHours: birth.timeZone.offsetHours,
      latitude: birth.latitude,
      longitude: birth.longitude,
      locationSource: birth.location.source.name,
      reasons: birth.reasons.map((r) => r.name).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rawBirthDate': rawBirthDate,
      'birthTime': birthTime,
      'province': province,
      'sunrise': sunrise,
      'sunriseAvailable': sunriseAvailable,
      'thaiAstrologicalDate': thaiAstrologicalDate,
      'usedPreviousDay': usedPreviousDay,
      'timeZoneId': timeZoneId,
      'utcOffsetHours': utcOffsetHours,
      'latitude': latitude,
      'longitude': longitude,
      'locationSource': locationSource,
      'reasons': reasons,
    };
  }

  factory ThaiBetaNormalizedSnapshot.fromMap(Map<String, dynamic> map) {
    return ThaiBetaNormalizedSnapshot(
      rawBirthDate: (map['rawBirthDate'] ?? '').toString(),
      birthTime: (map['birthTime'] ?? '').toString(),
      province: (map['province'] ?? '').toString(),
      sunrise: (map['sunrise'] ?? '').toString(),
      sunriseAvailable: map['sunriseAvailable'] == true,
      thaiAstrologicalDate: (map['thaiAstrologicalDate'] ?? '').toString(),
      usedPreviousDay: map['usedPreviousDay'] == true,
      timeZoneId: (map['timeZoneId'] ?? '').toString(),
      utcOffsetHours: (map['utcOffsetHours'] as num?)?.toDouble() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      locationSource: (map['locationSource'] ?? '').toString(),
      reasons: (map['reasons'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
