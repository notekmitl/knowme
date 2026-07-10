/// Presentation polish for Thai Beta PDF/export text (no new predictions).
library;

/// Cleans export strings: duplicate prefixes, zero-remaining copy, ellipsis
/// truncations, spacing, and consecutive duplicates.
abstract final class ThaiBetaReportExportPolish {
  static final _zeroYearPatterns = <Pattern>[
    RegExp(r'และจะอยู่ในจังหวะนี้ไปอีกประมาณ\s*0\s*ปี'),
    RegExp(r'จะอยู่ในจังหวะนี้ไปอีกประมาณ\s*0\s*ปี'),
    RegExp(r'ในราว\s*0\s*ปีข้างหน้า'),
    RegExp(r'ราว\s*0\s*ปีข้างหน้า'),
    RegExp(r'เหลืออีกประมาณ\s*0\s*ปี[^\n]*'),
    RegExp(r'เหลือเวลาในช่วงนี้อีกราว\s*0\s*ปี[^\n]*'),
    RegExp(r'ไปอีกประมาณ\s*0\s*ปี'),
    RegExp(r'อีกราว\s*0\s*ปี[^\n]*'),
    RegExp(r'อีกประมาณ\s*0\s*ปี[^\n]*'),
    RegExp(r'เหลืออีกประมาณ\s*0\s*เดือน[^\n]*'),
    RegExp(r'อีกประมาณ\s*0\s*เดือน[^\n]*'),
  ];

  /// Prefer full labels already containing the prefix; avoid "ช่วงก่อนหน้า: ช่วงก่อนหน้า:".
  static String neighbourLabel(String raw, {required String prefix}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith(prefix)) return trimmed;
    return '$prefix$trimmed';
  }

  /// Rewrite zero-remaining timing copy for late-stage periods.
  static String polishTimingCopy(String input) {
    var text = input;
    for (final pattern in _zeroYearPatterns) {
      text = text.replaceAll(pattern, 'กำลังอยู่ช่วงปลายของจังหวะนี้');
    }
    // Future-preview style: "ในราว 0 ปีข้างหน้า …" → late-stage phrasing.
    text = text.replaceAll(
      RegExp(r'กำลังอยู่ช่วงปลายของจังหวะนี้\s*ชีวิตของคุณมักจะ'),
      'กำลังอยู่ช่วงปลายของจังหวะนี้ ชีวิตของคุณมักจะ',
    );
    // Collapse accidental double sentences after replacement.
    text = text.replaceAll(
      RegExp(r'กำลังอยู่ช่วงปลายของจังหวะนี้\s*ก่อน[^\n]*'),
      'กำลังอยู่ช่วงปลายของจังหวะนี้',
    );
    return text.trim();
  }

  /// Drop UI-truncated fragments (mid-word ellipsis). Keep full sentences.
  static bool isUiTruncated(String input) {
    final t = input.trim();
    if (!t.endsWith('…') && !t.endsWith('...')) return false;
    // Sentence-style ellipsis after punctuation is rare in our copy; treat
    // trailing ellipsis as UI truncation for export.
    return true;
  }

  /// Normalize spacing around Thai/ASCII punctuation and parentheses.
  static String normalizeSpacing(String input) {
    var text = input.trim();
    if (text.isEmpty) return text;
    // Collapse horizontal whitespace only — keep intentional newlines.
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.replaceAllMapped(
      RegExp(r'([^\s])\('),
      (m) => '${m[1]} (',
    );
    text = text.replaceAllMapped(
      RegExp(r'\)([^\s\.,;:!?…\n])'),
      (m) => ') ${m[1]}',
    );
    text = text.replaceAllMapped(
      RegExp(r'([^\s])•'),
      (m) => '${m[1]} •',
    );
    text = text.replaceAllMapped(
      RegExp(r'•([^\s])'),
      (m) => '• ${m[1]}',
    );
    text = text.replaceAll(RegExp(r'[ \t]+([,.;:!?])'), r'$1');
    return text.trim();
  }

  /// Remove duplicate consecutive paragraphs / title echoed as first line.
  static List<String> dedupeParagraphs(String title, List<String> paragraphs) {
    final out = <String>[];
    String? last;
    for (final raw in paragraphs) {
      final p = normalizeSpacing(polishTimingCopy(raw));
      if (p.isEmpty) continue;
      if (isUiTruncated(p)) continue;
      if (p == title) continue;
      if (last != null && last == p) continue;
      // Drop "Title Title" style echoes.
      if (p == '$title $title' || p.startsWith('$title $title')) continue;
      out.add(p);
      last = p;
    }
    return out;
  }

  static String polishTitle(String title) {
    var t = normalizeSpacing(title);
    // "การเติบโต การเติบโต" → "การเติบโต"
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 2 && parts[0] == parts[1]) {
      t = parts[0];
    }
    return t;
  }
}
