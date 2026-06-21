import '../models/thai_content_key.dart';
import '../models/thai_content_section.dart';
import '../models/thai_content_type.dart';
import 'lagna/lagna_content.dart';
import 'lagna_lords/lagna_lord_content.dart';
import 'mahabhuta/mahabhuta_content.dart';
import 'myanmar/myanmar_seven_content.dart';
import 'ramahabhuta/ramahabhuta_content.dart';
import 'thai_placeholder_content.dart';

/// In-memory catalog of Thai astrology content sections.
abstract final class ThaiContentLibrary {
  static final Map<String, ThaiContentSection> sections = {
    for (final section in _allSections()) section.key: section,
  };

  static List<ThaiContentSection> _allSections() => [
        ...LagnaContent.all(),
        ...LagnaLordContent.all(),
        ...RamahabhutaContent.all(),
        ...MahabhutaContent.all(),
        ...MyanmarSevenContent.all(),
        ...ThaiPlaceholderContent.all(),
      ];

  /// Keys registered in the library (content may or may not exist yet).
  static final Set<String> registeredKeys = {
    ...ThaiContentKeys.all,
    ...sections.keys,
  };

  static bool hasContent(String key) => sections.containsKey(_normalize(key));

  static ThaiContentSection? getSection(String key) {
    return sections[_normalize(key)];
  }

  /// Returns authored sections for [type] using [ThaiContentSection.contentType].
  static List<ThaiContentSection> getByType(ThaiContentType type) {
    return sections.values
        .where((section) => section.contentType == type)
        .toList();
  }

  static String _normalize(String key) => key.trim().toLowerCase();
}
