/// Thai-language date/weekday formatting for the Research summary card.
///
/// Presentation-only: years are shown in the Buddhist era (CE + 543) with Thai
/// month names, e.g. `8 มิถุนายน 2525`. Does not touch Birth Normalization.
abstract final class ThaiBetaDateFormat {
  static const List<String> _months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  /// `DateTime.weekday`: Mon=1 … Sun=7. Index here is keyed by that value.
  static const Map<int, String> _weekdays = {
    DateTime.sunday: 'วันอาทิตย์',
    DateTime.monday: 'วันจันทร์',
    DateTime.tuesday: 'วันอังคาร',
    DateTime.wednesday: 'วันพุธ',
    DateTime.thursday: 'วันพฤหัสบดี',
    DateTime.friday: 'วันศุกร์',
    DateTime.saturday: 'วันเสาร์',
  };

  /// `8 มิถุนายน 2525` (Buddhist era).
  static String formatDate(DateTime date) {
    final month = _months[date.month - 1];
    final buddhistYear = date.year + 543;
    return '${date.day} $month $buddhistYear';
  }

  /// `วันเสาร์` etc.
  static String weekday(DateTime date) => _weekdays[date.weekday] ?? '';

  /// Parses a `yyyy-MM-dd` snapshot string into Thai date text; returns the raw
  /// string unchanged when it cannot be parsed.
  static String formatIsoDate(String iso) {
    final parsed = parseIso(iso);
    return parsed == null ? iso : formatDate(parsed);
  }

  static DateTime? parseIso(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
}
