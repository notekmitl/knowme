/// Canonical birth date/time formatting for Firestore storage and UI display.
abstract final class BirthProfileFormat {
  /// Firestore storage: `YYYY-MM-DD` (date only — never ISO datetime).
  static String storageDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses stored `birthDate` — supports `YYYY-MM-DD` and legacy ISO strings.
  static DateTime? parseStoredDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final dateOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(trimmed);
    if (dateOnly != null) {
      final year = int.tryParse(dateOnly.group(1)!);
      final month = int.tryParse(dateOnly.group(2)!);
      final day = int.tryParse(dateOnly.group(3)!);
      if (year == null || month == null || day == null) return null;
      return DateTime(year, month, day);
    }

    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// UI display: `D/M/YYYY`
  static String displayDate(String storedDate) {
    final date = parseStoredDate(storedDate);
    if (date == null) return storedDate.trim();
    return '${date.day}/${date.month}/${date.year}';
  }

  /// UI display: `HH:mm` from separate `birthTime` field.
  static String displayTime(String birthTime) {
    final trimmed = birthTime.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'unknown') return '';
    final parts = trimmed.split(':');
    if (parts.length < 2) return trimmed;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return trimmed;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Profile strip line: `6/6/1982 • 00:35`
  static String profileDateTimeLine(String storedDate, String birthTime) {
    final dateLabel = displayDate(storedDate);
    final timeLabel = displayTime(birthTime);
    if (timeLabel.isEmpty) return dateLabel;
    return '$dateLabel • $timeLabel';
  }
}
