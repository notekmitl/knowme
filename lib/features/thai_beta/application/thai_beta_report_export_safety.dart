/// Scrubs forbidden internal content from export text.
abstract final class ThaiBetaReportExportSafety {
  static const forbiddenSubstrings = <String>[
    'ดวงขึ้น',
    'ดวงตก',
    'Taksa',
    'taksa',
    'ทักษา',
    'Khumsap',
    'khumsap',
    'คุ้มทรัพย์',
    'remedy',
    'Remedy',
    'แก้เคล็ด',
    'ontology',
    'Ontology',
    'canon.unit',
    'unit.',
    'signalId',
    'evidenceType',
    'sourcePage',
    'source_page',
    'raw Canon',
  ];

  /// Returns true when [text] contains any forbidden token.
  static bool containsForbidden(String text) {
    for (final token in forbiddenSubstrings) {
      if (text.contains(token)) return true;
    }
    // Canon-like ids: unit.xxx or ontology:xxx
    if (RegExp(r'\bunit\.[a-zA-Z0-9_.-]+').hasMatch(text)) return true;
    if (RegExp(r'\bontology[:.][a-zA-Z0-9_.-]+').hasMatch(text)) return true;
    return false;
  }

  /// Removes lines/sentences that contain forbidden tokens.
  static String scrub(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    if (!containsForbidden(trimmed)) return trimmed;

    final parts = trimmed.split(RegExp(r'[\n。\.\!\?]+'));
    final kept = <String>[];
    for (final part in parts) {
      final p = part.trim();
      if (p.isEmpty) continue;
      if (!containsForbidden(p)) kept.add(p);
    }
    return kept.join('. ').trim();
  }
}
