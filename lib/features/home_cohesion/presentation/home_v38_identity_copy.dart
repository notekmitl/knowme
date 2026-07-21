/// Identity-style hero copy — V3.8 (not report/summary style).
abstract final class HomeV38IdentityCopy {
  static const defaultHeadline =
      'คุณเป็นคนที่มักเลือกสร้างเส้นทางของตัวเอง\n'
      'มากกว่าการเดินตามสิ่งที่คนอื่นกำหนด';

  static const defaultSupporting =
      'คุณเติบโตได้ดีที่สุดเมื่อได้ตัดสินใจด้วยตัวเอง';

  static const _forbiddenPrefixes = [
    'หลายศาสตร์สะท้อนว่า',
    'หลายศาสตร์สะท้อนตรงกันว่า',
    'หลายมุมสะท้อนว่า',
    'จากการวิเคราะห์',
    'ผลลัพธ์แสดงว่า',
    'คุณอาจ',
    'อาจจะ',
    'มีแนวโน้มที่จะ',
    'จากข้อมูล',
  ];

  static const _reportPhrases = [
    'สะท้อนว่า',
    'แสดงว่า',
    'วิเคราะห์',
    'อาจให้ความสำคัญ',
    'อาจมีแนวโน้ม',
    'จากหลายมุม',
    'cross-lens',
    'theme',
  ];

  static String headline(String raw) {
    final cleaned = _clean(raw);
    if (cleaned.isEmpty || _isReportStyle(cleaned)) {
      return defaultHeadline.replaceAll('\n', ' ');
    }
    return _toIdentitySentence(cleaned);
  }

  static String supporting(String raw, {String fallback = defaultSupporting}) {
    final cleaned = _clean(raw);
    if (cleaned.isEmpty || _isReportStyle(cleaned)) {
      return fallback;
    }
    final sentence = _toIdentitySentence(cleaned);
    if (sentence == headline(raw)) return fallback;
    return _truncateToTwoLines(sentence);
  }

  static String _clean(String raw) {
    var text = raw.trim();
    for (final prefix in _forbiddenPrefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        if (text.startsWith('ว่า')) {
          text = text.substring(2).trim();
        }
      }
    }
    return text;
  }

  static bool _isReportStyle(String text) {
    final lower = text.toLowerCase();
    for (final phrase in _reportPhrases) {
      if (text.contains(phrase) || lower.contains(phrase)) return true;
    }
    if (text.startsWith('คุณอาจ')) return true;
    return false;
  }

  static String _toIdentitySentence(String text) {
    var result = text;
    if (!result.startsWith('คุณ')) {
      result = 'คุณ$result';
    }
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (!result.endsWith('.') && !result.endsWith('…')) {
      // keep Thai sentences without forced period
    }
    return result;
  }

  static String _truncateToTwoLines(String text) {
    final parts = text
        .split(RegExp(r'(?<=[。．.!?])\s*'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return text;
    return parts.take(2).join(' ');
  }
}
