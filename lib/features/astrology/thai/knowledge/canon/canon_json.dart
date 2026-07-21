/// Canon Platform — shared JSON decode helpers.
///
/// Single source of truth for the small parsing utilities that were previously
/// duplicated across `canon_knowledge_engine.dart`, `database/canon_entities.dart`
/// and `ingestion/canon_candidate.dart`. Pure Dart leaf (no imports), so every
/// canon layer (root / database / ingestion) may depend on it without creating a
/// cycle or leaking a layer.
library;

/// Resolve an enum value by its `name`, or null when absent/unknown.
T? canonEnumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

/// Coerce a JSON value into a list of trimmed, non-empty strings.
List<String> canonStringList(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return const [];
}
