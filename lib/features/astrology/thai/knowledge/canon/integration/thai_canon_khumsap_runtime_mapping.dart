import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_entity.dart';

import 'thai_canon_ontology_runtime_mapping.dart';
import 'thai_mahabhut_khumsap_runtime_key.dart';

/// Exact Canon Khumsap ↔ internal runtime key mapping.
///
/// No fuzzy matching. No alias to `mahabhuta_thaya`.
abstract final class ThaiCanonKhumsapRuntimeMapping {
  static const canonEntityId = ThaiMahabhutKhumsapRuntimeKey.canonEntityId;

  static const internalRuntimeKey = ThaiMahabhutKhumsapRuntimeKey.khumsap;

  static bool isInternalKhumsapRuntimeKey(String? runtimeKey) =>
      ThaiMahabhutKhumsapRuntimeKey.isKhumsapRuntimeKey(runtimeKey);

  static String? runtimeKeyForCanonId(String canonEntityId) {
    if (canonEntityId != ThaiCanonKhumsapRuntimeMapping.canonEntityId) {
      return null;
    }
    return internalRuntimeKey;
  }

  static String? canonIdForRuntimeKey(String runtimeKey) {
    if (!isInternalKhumsapRuntimeKey(runtimeKey)) return null;
    return canonEntityId;
  }

  static CanonicalEntity? khumsapEntity() {
    for (final entity in CanonOntologyData.mahabhutPositions) {
      if (entity.id == canonEntityId) return entity;
    }
    return null;
  }

  /// Exact Thai label from frozen Canon ontology only.
  static String? primaryThaiLabel() {
    final entity = khumsapEntity();
    if (entity == null || entity.aliases.isEmpty) return null;
    return entity.aliases.first;
  }

  static List<ThaiCanonRuntimeMappingEntry> runtimeMappings() {
    return [
      ThaiCanonRuntimeMappingEntry(
        canonEntityId: canonEntityId,
        runtimeKey: internalRuntimeKey,
        kind: ThaiCanonRuntimeKeyKind.internalMahabhutPosition,
        note: 'Internal metadata key only — not ThaiContentRegistry / report copy',
      ),
    ];
  }
}
