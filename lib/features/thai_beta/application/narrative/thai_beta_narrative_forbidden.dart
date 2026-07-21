/// Forbidden runtime pattern detection for Thai Beta narrative V1.1.
library;

abstract final class ThaiBetaNarrativeForbidden {
  /// Regex patterns that must never appear in composed output.
  static final runtimePatterns = <RegExp>[
    RegExp(r'ลองคุณ'),
    RegExp(r'ลองงาน'),
    RegExp(r'ลองเป้าหมาย'),
    RegExp(r'ลองความรัก'),
    RegExp(r'ลองโอกาส'),
    RegExp(r'ลองระบาย'),
    RegExp(r'ลองมอบหมาย'),
    RegExp(r'ลองคุณกล้า'),
    RegExp(r'ตัวอย่างที่พบได้บ่อยคือเมื่อต้องใช้'),
    RegExp(r'อย่างเช่น เมื่อต้องใช้'),
    RegExp(r'แต่เมื่อต้องตัดสินใจ คุณยัง'),
    RegExp(r'ในขณะที่อีกด้านหนึ่งคุณ'),
    RegExp(r'เมื่อสถานการณ์เร่ง(?![ก-๙a-zA-Z])'),
    RegExp(r'คุณทำได้ดีกว่าที่คาด(?![ก-๙a-zA-Z])'),
  ];

  /// Deep-motive phrases forbidden when birth time is missing.
  static final noBirthTimeForbidden = <RegExp>[
    RegExp(r'ลึก\s*ๆ\s*คุณต้องการ'),
    RegExp(r'สิ่งที่อยู่ใจกลางตัวคุณ'),
    RegExp(r'นี่คือแรงขับที่แท้จริงของคุณ'),
  ];

  /// Valid advice action phrase prefixes (curated advice must start with one).
  static const validAdvicePrefixes = <String>[
    'ลองกำหนด',
    'ลองเว้น',
    'ลองจด',
    'ลองถาม',
    'ลองแบ่ง',
    'ลองเลือก',
    'ลองตั้ง',
    'ลองพัก',
    'ลองสังเกต',
    'ลองย้อน',
    'ลองลด',
    'ลองเปิด',
    'ลองปรึกษา',
    'ลองทบทวน',
    'ลองจัด',
    'ลองแยก',
    'ลองค่อย',
    'ลองให้',
    'ลองเริ่ม',
    'ลองหยุด',
  ];

  static bool hasRepeatedMueangLead(String text) {
    final chunks = text.split(RegExp(r'[\n\r]+|[.!?…]\s+'));
    for (final chunk in chunks) {
      if (RegExp(r'คุณมัก').allMatches(chunk).length > 1) {
        return true;
      }
    }
    return false;
  }

  static List<String> findForbidden(String text) {
    final hits = <String>[];
    for (final pattern in runtimePatterns) {
      for (final match in pattern.allMatches(text)) {
        hits.add(match.group(0)!);
      }
    }
    for (final paragraph in text.split(RegExp(r'\n\n+'))) {
      if (hasRepeatedMueangLead(paragraph)) {
        hits.add('คุณมัก{duplicate}');
      }
    }
    return hits.toSet().toList();
  }

  static List<String> findNoBirthTimeViolations(String text) {
    final hits = <String>[];
    for (final pattern in noBirthTimeForbidden) {
      for (final match in pattern.allMatches(text)) {
        hits.add(match.group(0)!);
      }
    }
    return hits.toSet().toList();
  }

  static bool isValidAdvicePhrase(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    return validAdvicePrefixes.any(trimmed.startsWith);
  }

  /// Detects semantic duplicate where only คุณ/คุณมัก differs.
  static bool isSemanticVariant(String a, String b) {
    final normA = _stripLead(a);
    final normB = _stripLead(b);
    return normA == normB && a != b;
  }

  static String _stripLead(String text) {
    return text
        .replaceFirst(RegExp(r'^คุณมัก\s*'), 'คุณ ')
        .replaceFirst(RegExp(r'^คุณ\s*'), '')
        .trim();
  }
}
