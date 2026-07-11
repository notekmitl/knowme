/// Presentation polish for Thai Beta PDF/export text (no new predictions).
library;

/// Cleans export strings: duplicate prefixes, zero-remaining copy, ellipsis
/// truncations, spacing, heading echoes, and consecutive duplicates.
///
/// Applied both when building the export document and again inside the PDF
/// exporter so the real download path cannot skip polish.
abstract final class ThaiBetaReportExportPolish {
  static const lateStagePhrase = 'กำลังอยู่ช่วงปลายของจังหวะนี้';

  static final _zeroRemainingLine = RegExp(
    r'[^\n]*(?:อีกประมาณ|อีกราว|ในราว|ราว|เหลือ(?:อีก)?ประมาณ|เหลือเวลาในช่วงนี้อีกราว|'
    r'ไปอีกประมาณ|และจะอยู่ในจังหวะนี้ไปอีกประมาณ)\s*0\s*(?:ปี|เดือน)[^\n]*',
  );

  static final _zeroToken = RegExp(r'(?<![0-9])0\s*(?:ปี|เดือน)');

  static final _uiEllipsisArtifact =
      RegExp(r'[ก-๙A-Za-z0-9]\u2026|[ก-๙A-Za-z0-9]\.\.\.');

  /// Prefer full labels already containing the prefix; collapse double prefixes.
  static String neighbourLabel(String raw, {required String prefix}) {
    var trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final bare = prefix.replaceAll(':', '').trim();
    trimmed = trimmed.replaceAll(
      RegExp('${RegExp.escape(prefix)}+'),
      prefix,
    );
    if (bare.isNotEmpty) {
      trimmed = trimmed.replaceAll(
        RegExp('(${RegExp.escape(bare)}:\\s*)+'),
        prefix,
      );
    }
    if (trimmed.startsWith(prefix)) return trimmed;
    if (bare.isNotEmpty && trimmed.startsWith('$bare:')) {
      return '$prefix${trimmed.substring(bare.length + 1).trim()}';
    }
    return '$prefix$trimmed';
  }

  /// Rewrite zero-remaining timing copy for late-stage periods.
  static String polishTimingCopy(String input) {
    var text = input.trim();
    if (text.isEmpty) return text;

    text = text.replaceAll(_zeroRemainingLine, lateStagePhrase);

    // Residual standalone "0 ปี" / "0 เดือน" (not part of 10/20/…) → late-stage.
    if (_zeroToken.hasMatch(text)) {
      text = text.replaceAll(
        RegExp(r'[^\n]*(?<![0-9])0\s*(?:ปี|เดือน)[^\n]*'),
        lateStagePhrase,
      );
    }

    text = text.replaceAll(
      RegExp('$lateStagePhrase\\s*$lateStagePhrase'),
      lateStagePhrase,
    );
    text = text.replaceAll(
      RegExp('$lateStagePhrase\\s*ก่อน[^\\n]*'),
      lateStagePhrase,
    );
    return text.trim();
  }

  /// Drop UI-truncated fragments (mid-word ellipsis). Keep full sentences.
  static bool isUiTruncated(String input) {
    final t = input.trim();
    if (t.isEmpty) return false;
    if (t.endsWith('…') || t.endsWith('...')) return true;
    return hasUiEllipsisArtifact(t);
  }

  static bool hasUiEllipsisArtifact(String input) =>
      _uiEllipsisArtifact.hasMatch(input);

  /// Normalize spacing around Thai/ASCII punctuation and parentheses.
  static String normalizeSpacing(String input) {
    var text = input.trim();
    if (text.isEmpty) return text;
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
    text = text.replaceAllMapped(
      RegExp(r'([^\s])·'),
      (m) => '${m[1]} ·',
    );
    text = text.replaceAllMapped(
      RegExp(r'·([^\s])'),
      (m) => '· ${m[1]}',
    );
    text = text.replaceAllMapped(
      RegExp(r'อายุ(?!\s)(\d+(?:–\d+)?)'),
      (m) => 'อายุ ${m[1]}',
    );
    text = text.replaceAll(RegExp(r'[ \t]+([,.;:!?])'), r'$1');
    return text.trim();
  }

  /// Single-line polish used for every title/paragraph written into the PDF.
  static String polishLine(String input) {
    var text = normalizeSpacing(polishTimingCopy(input));
    text = text.replaceAll('**', '');
    text = text
        .replaceAll(RegExp(r'(ช่วงก่อนหน้า:\s*)+'), 'ช่วงก่อนหน้า: ')
        .replaceAll(RegExp(r'(ช่วงถัดไป:\s*)+'), 'ช่วงถัดไป: ');
    text = polishTimingCopy(text);
    return normalizeSpacing(text);
  }

  /// Remove duplicate consecutive paragraphs / title / bullet-keyword echoes.
  static List<String> dedupeParagraphs(String title, List<String> paragraphs) {
    final out = <String>[];
    String? last;
    for (final raw in paragraphs) {
      final p = polishLine(raw);
      if (p.isEmpty) continue;
      if (isUiTruncated(p)) continue;
      if (p == title) continue;
      if (last != null && last == p) continue;
      if (p == '$title $title' || p.startsWith('$title $title')) continue;
      if (_isKeywordEchoOf(last, p)) continue;
      out.add(p);
      last = p;
    }
    return out;
  }

  /// True when [current] repeats the bullet keyword already on [previous].
  static bool _isKeywordEchoOf(String? previous, String current) {
    if (previous == null) return false;
    final bullet = RegExp(r'•\s*(.+)$').firstMatch(previous);
    if (bullet == null) return false;
    final keyword = bullet.group(1)!.trim();
    if (keyword.isEmpty) return false;
    if (current == keyword) return true;
    if (current == 'คำสำคัญ: $keyword') return true;
    if (current == 'คำสำคัญ:$keyword') return true;
    return false;
  }

  static String polishTitle(String title) {
    var t = polishLine(title);
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 2 && parts[0] == parts[1]) {
      t = parts[0];
    }
    return t;
  }

  /// Forbidden regression strings that must never appear in real PDF text.
  static const forbiddenSubstrings = <String>[
    'อีกประมาณ 0',
    'ช่วงก่อนหน้า: ช่วงก่อนหน้า',
    'ช่วงถัดไป: ช่วงถัดไป',
    'ผ่านรู้สึก…',
    'ผ่านคิดละเอ…',
    'ดี(ผ่าน',
    '• การเติบโต\nการเติบโต',
    '• การเรียนรู้\nการเรียนรู้',
    '• ความมั่นคง\nความมั่นคง',
  ];

  static final forbiddenPatterns = <RegExp>[
    RegExp(r'(?<![0-9])0\s*ปี'),
    RegExp(r'(?<![0-9])0\s*เดือน'),
  ];

  static List<String> findForbidden(String text) {
    final hits = <String>[
      for (final needle in forbiddenSubstrings)
        if (text.contains(needle)) needle,
    ];
    for (final pattern in forbiddenPatterns) {
      if (pattern.hasMatch(text)) {
        hits.add(pattern.pattern);
      }
    }
    return hits;
  }
}
