import '../models/thai_content_section.dart';
import '../models/thai_content_type.dart';
import '../registry/thai_content_registry.dart';

/// Read-only access to Thai astrology content.
abstract class ThaiContentRepository {
  bool isKnownKey(String key);

  bool hasContent(String key);

  ThaiContentSection? getByKey(String key);

  List<ThaiContentSection> getByKeys(Iterable<String> keys);

  List<ThaiContentSection> getByType(ThaiContentType type);

  List<String> missingKeysForType(ThaiContentType type);
}

/// Default in-memory repository backed by [ThaiContentRegistry].
class ThaiContentRepositoryImpl implements ThaiContentRepository {
  const ThaiContentRepositoryImpl();

  @override
  bool isKnownKey(String key) => ThaiContentRegistry.isKnownKey(key);

  @override
  bool hasContent(String key) => ThaiContentRegistry.hasContent(key);

  @override
  ThaiContentSection? getByKey(String key) => ThaiContentRegistry.resolve(key);

  @override
  List<ThaiContentSection> getByKeys(Iterable<String> keys) {
    return ThaiContentRegistry.resolveMany(keys);
  }

  @override
  List<ThaiContentSection> getByType(ThaiContentType type) {
    return ThaiContentRegistry.byType(type);
  }

  @override
  List<String> missingKeysForType(ThaiContentType type) {
    return ThaiContentRegistry.missingKeysForType(type);
  }
}
