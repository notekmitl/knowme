import '../library/thai_content_library.dart';
import '../models/thai_content_key.dart';
import '../models/thai_content_section.dart';
import '../models/thai_content_type.dart';

/// Resolves content keys to [ThaiContentSection] instances.
abstract final class ThaiContentRegistry {
  static bool isKnownKey(String key) {
    return ThaiContentLibrary.registeredKeys.contains(_normalize(key));
  }

  static bool hasContent(String key) {
    return ThaiContentLibrary.hasContent(key);
  }

  static ThaiContentSection? resolve(String key) {
    if (!isKnownKey(key)) return null;
    return ThaiContentLibrary.getSection(key);
  }

  static List<ThaiContentSection> resolveMany(Iterable<String> keys) {
    return keys
        .map(resolve)
        .whereType<ThaiContentSection>()
        .toList();
  }

  static List<ThaiContentSection> allLagna() {
    return resolveMany(ThaiContentKeys.allLagna);
  }

  static List<ThaiContentSection> allLagnaLord() {
    return resolveMany(ThaiContentKeys.allLagnaLord);
  }

  static List<ThaiContentSection> allRamahabhuta() {
    return resolveMany(ThaiContentKeys.allRamahabhuta);
  }

  static List<ThaiContentSection> allMahabhutaPosition() {
    return resolveMany(ThaiContentKeys.allMahabhutaPosition);
  }

  static List<ThaiContentSection> allMyanmarSeven() {
    return resolveMany(ThaiContentKeys.allMyanmarSeven);
  }

  static List<ThaiContentSection> byType(ThaiContentType type) {
    return ThaiContentLibrary.getByType(type);
  }

  static List<String> missingKeysForType(ThaiContentType type) {
    final expected = switch (type) {
      ThaiContentType.lagna => ThaiContentKeys.allLagna,
      ThaiContentType.lagnaLord => ThaiContentKeys.allLagnaLord,
      ThaiContentType.ramahabhuta => ThaiContentKeys.allRamahabhuta,
      ThaiContentType.mahabhutaPosition => ThaiContentKeys.allMahabhutaPosition,
      ThaiContentType.myanmarSeven => ThaiContentKeys.allMyanmarSeven,
    };

    return expected.where((key) => !hasContent(key)).toList();
  }

  static String _normalize(String key) => key.trim().toLowerCase();
}
