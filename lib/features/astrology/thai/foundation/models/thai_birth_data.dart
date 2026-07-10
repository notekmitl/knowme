/// Birth input for Thai Foundation Engine V1 — a pure engine model.
///
/// [localDateTime] uses civil/local calendar components (date + optional time).
/// [timeZoneOffset] converts local civil time to UTC (e.g. `Duration(hours: 7)` for ICT).
///
/// This model knows nothing about Birth Normalization. The bridge that builds it
/// from a normalized `ThaiBirthContext` is `ThaiEngineAdapter`, owned by
/// `lib/features/birth_normalization/application/adapters/`. Direct construction
/// remains for QA fixtures and falls back to [dateOnly] for the astrological date.
class ThaiBirthData {
  const ThaiBirthData({
    required this.localDateTime,
    required this.timeZoneOffset,
    required this.latitude,
    required this.longitude,
    this.hasBirthTime = true,
    DateTime? astrologicalDate,
  }) : _astrologicalDate = astrologicalDate;

  final DateTime localDateTime;
  final Duration timeZoneOffset;
  final double latitude;
  final double longitude;
  final bool hasBirthTime;

  final DateTime? _astrologicalDate;

  DateTime get utcDateTime => localDateTime.subtract(timeZoneOffset);

  DateTime get dateOnly => DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

  /// Sunrise-adjusted Thai astrological date (from Birth Normalization).
  /// Previous calendar day for before-sunrise births; falls back to [dateOnly]
  /// when constructed without a context (QA fixtures / legacy callers).
  DateTime get astrologicalDate => _astrologicalDate ?? dateOnly;

  /// The single, canonical Thai weekday for every layer: อาทิตย์=1 … เสาร์=7,
  /// derived from [astrologicalDate] (the sunrise day boundary), never from the
  /// civil date. All Thai layers (day base, life-period ruler, lens fallback)
  /// must use this so they agree on the same Thai day.
  int get thaiWeekdayNumber {
    final w = astrologicalDate.weekday; // Mon=1 … Sun=7
    return w == DateTime.sunday ? 1 : w + 1;
  }
}
