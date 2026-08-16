/// The release contract for the instant represented by an analysis.
abstract final class ThaiBetaAnalysisClock {
  static const bangkokOffset = Duration(hours: 7);

  /// Converts an absolute instant to an `Asia/Bangkok` civil timestamp.
  ///
  /// Thailand has used UTC+07:00 continuously for the supported product date
  /// range. Returning a timezone-free civil value prevents device timezone
  /// settings from changing date-aware astrology calculations.
  static DateTime asBangkokCivil(DateTime instant) {
    final bangkok = instant.toUtc().add(bangkokOffset);
    return DateTime(
      bangkok.year,
      bangkok.month,
      bangkok.day,
      bangkok.hour,
      bangkok.minute,
      bangkok.second,
      bangkok.millisecond,
      bangkok.microsecond,
    );
  }
}
