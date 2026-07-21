/// Presentation-only text shaping (no engine changes).
abstract final class MbtiSummaryTextFormat {
  /// Splits insight copy into scannable blocks for the profile section.
  static List<String> profileBlocks(String paragraph) {
    final trimmed = paragraph.trim();
    if (trimmed.isEmpty) return [];

    final explicit = trimmed
        .split(RegExp(r'\n\s*\n|\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (explicit.length > 1) return explicit.take(4).toList();

    final soft = trimmed.split(RegExp(r'(?=\sแต่|\sทำให้)')).map((s) {
      return s.trim();
    }).where((s) => s.isNotEmpty).toList();

    if (soft.length > 1) return soft.take(4).toList();

    if (trimmed.length > 72) {
      final comma = trimmed
          .split(RegExp(r'(?<=[,，])\s+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (comma.length > 1) return comma.take(4).toList();
    }

    return [trimmed];
  }

  /// One continuous paragraph for hero synthesis (no stacked mini-blocks).
  static String singleParagraph(String text) {
    return text
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
