/// Thai language and punctuation normalizer for Thai Beta presentation layer.
library;

abstract final class ThaiBetaNarrativeFormatting {
  /// Forbidden formatting patterns (regex) for regression tests.
  static final forbiddenPatterns = <RegExp>[
    RegExp(r'\*\*'),
    RegExp(r'อายุ\d'),
    RegExp(r'[ก-๙]•'),
    RegExp(r'[ก-๙A-Za-z]—'),
    RegExp(r'[ก-๙]\('),
    RegExp(r'ปกติลอง'),
    RegExp(r'ด้านนี้ลอง'),
  ];

  /// Known glued transition phrases — explicit fixes only (never split compounds
  /// such as `ตั้งแต่` or `ทดลอง`).
  static const _gluedTransitionFixes = <String, String>{
    'ปกติลอง': 'ปกติ ลอง',
    'ด้านนี้ลอง': 'ด้านนี้ ลอง',
  };

  static List<String> findForbidden(String text) {
    final hits = <String>[];
    for (final pattern in forbiddenPatterns) {
      for (final match in pattern.allMatches(text)) {
        hits.add(match.group(0)!);
      }
    }
    return hits.toSet().toList();
  }

  static String normalize(String input) {
    var text = input.trim();
    if (text.isEmpty) return text;

    text = text.replaceAll('**', '');
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Space before opening parenthesis after Thai/Latin word.
    text = text.replaceAllMapped(
      RegExp(r'([^\s])\('),
      (m) => '${m[1]} (',
    );

    // Bullet spacing.
    text = text.replaceAllMapped(
      RegExp(r'([^\s])•'),
      (m) => '${m[1]} •',
    );
    text = text.replaceAllMapped(
      RegExp(r'•([^\s])'),
      (m) => '• ${m[1]}',
    );

    // Em dash spacing.
    text = text.replaceAllMapped(
      RegExp(r'([^\s])—'),
      (m) => '${m[1]} —',
    );
    text = text.replaceAllMapped(
      RegExp(r'—([^\s])'),
      (m) => '— ${m[1]}',
    );

    // Middle dot spacing.
    text = text.replaceAllMapped(
      RegExp(r'([^\s])·'),
      (m) => '${m[1]} ·',
    );
    text = text.replaceAllMapped(
      RegExp(r'·([^\s])'),
      (m) => '· ${m[1]}',
    );

    // Age label spacing.
    text = text.replaceAllMapped(
      RegExp(r'อายุ(?!\s)(\d+(?:–\d+)?)'),
      (m) => 'อายุ ${m[1]}',
    );

    // Explicit glued transition fixes only — avoids splitting valid Thai words.
    for (final entry in _gluedTransitionFixes.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }

    // Transition words after sentence punctuation or em-dash only.
    for (final word in ['แต่', 'อีกด้าน', 'อย่างไรก็ตาม']) {
      text = text.replaceAllMapped(
        RegExp('([.!?…])\\s*$word'),
        (m) => '${m[1]} $word',
      );
      text = text.replaceAllMapped(
        RegExp('([)—])\\s*$word'),
        (m) => '${m[1]} $word',
      );
    }

    // Space after sentence-ending punctuation before Thai text.
    text = text.replaceAllMapped(
      RegExp(r'([.!?…])([ก-๙])'),
      (m) => '${m[1]} ${m[2]}',
    );

    text = text.replaceAllMapped(
      RegExp(r'[ \t]+([,.;:!?])'),
      (m) => m[1]!,
    );
    return text.trim();
  }

  /// Normalized key for dedupe comparisons.
  static String normalizedKey(String input) {
    return normalize(input)
        .replaceAll(RegExp(r'[ \t\n\r]+'), ' ')
        .replaceAll(RegExp(r'[,.;:!?…—\-•·]'), '')
        .toLowerCase()
        .trim();
  }
}
