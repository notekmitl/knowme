import 'package:flutter/foundation.dart';

import '../models/thai_content_section.dart';
import '../models/thai_content_type.dart';
import '../repository/thai_content_repository.dart';

/// Lightweight state holder for Thai content lookups.
///
/// Does not generate charts or interpretations — load-only by key.
class ThaiContentProvider extends ChangeNotifier {
  ThaiContentProvider({ThaiContentRepository? repository})
      : _repository = repository ?? const ThaiContentRepositoryImpl();

  final ThaiContentRepository _repository;

  final Map<String, ThaiContentSection> _cache = {};

  ThaiContentSection? _lastLoaded;
  String? _lastKey;
  String? _error;

  ThaiContentSection? get lastLoaded => _lastLoaded;
  String? get lastKey => _lastKey;
  String? get error => _error;

  bool isKnownKey(String key) => _repository.isKnownKey(key);

  bool hasContent(String key) => _repository.hasContent(key);

  ThaiContentSection? getCached(String key) => _cache[key.trim().toLowerCase()];

  ThaiContentSection? loadByKey(String key) {
    _error = null;
    _lastKey = key;

    final normalized = key.trim().toLowerCase();

    if (_cache.containsKey(normalized)) {
      _lastLoaded = _cache[normalized];
      notifyListeners();
      return _lastLoaded;
    }

    if (!_repository.isKnownKey(normalized)) {
      _error = 'Unknown Thai content key: $normalized';
      _lastLoaded = null;
      notifyListeners();
      return null;
    }

    final section = _repository.getByKey(normalized);
    if (section == null) {
      _error = 'Content not authored yet: $normalized';
      _lastLoaded = null;
      notifyListeners();
      return null;
    }

    _cache[normalized] = section;
    _lastLoaded = section;
    notifyListeners();
    return section;
  }

  List<ThaiContentSection> loadByType(ThaiContentType type) {
    _error = null;

    final sections = _repository.getByType(type);
    for (final section in sections) {
      _cache[section.key] = section;
    }

    notifyListeners();
    return sections;
  }

  List<String> missingKeysForType(ThaiContentType type) {
    return _repository.missingKeysForType(type);
  }

  void clearCache() {
    _cache.clear();
    _lastLoaded = null;
    _lastKey = null;
    _error = null;
    notifyListeners();
  }
}
