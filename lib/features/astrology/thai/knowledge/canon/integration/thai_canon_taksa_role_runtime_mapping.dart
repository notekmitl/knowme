import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_entity.dart';

import 'thai_canon_ontology_runtime_mapping.dart';
import 'thai_taksa_role_runtime_key.dart';

/// Exact Canon Taksa role ↔ internal runtime key mapping.
///
/// No fuzzy matching. No synonym invention. Runtime key equals Canon id.
abstract final class ThaiCanonTaksaRoleRuntimeMapping {
  static Set<String> get allowedCanonIds => ThaiTaksaRoleRuntimeKey.allowedIds;

  /// Canon entity id → internal runtime key (same id string).
  static String? runtimeKeyForCanonId(String canonEntityId) {
    if (!ThaiTaksaRoleRuntimeKey.isAllowed(canonEntityId)) return null;
    return canonEntityId;
  }

  /// Internal runtime key → Canon entity id.
  static String? canonIdForRuntimeKey(String runtimeKey) =>
      runtimeKeyForCanonId(runtimeKey);

  /// Exact Thai label → Canon id (ontology aliases only).
  static String? canonIdForExactThaiLabel(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return null;
    for (final entity in CanonOntologyData.taksaRoles) {
      if (entity.aliases.contains(trimmed)) return entity.id;
    }
    return null;
  }

  /// Returns null for unknown or ambiguous labels — never guesses.
  static String? canonIdForThaiLabel(String label) => canonIdForExactThaiLabel(label);

  static CanonicalEntity? entityForCanonId(String canonEntityId) {
    for (final entity in CanonOntologyData.taksaRoles) {
      if (entity.id == canonEntityId) return entity;
    }
    return null;
  }

  static String? primaryThaiLabelForCanonId(String canonEntityId) =>
      ThaiTaksaRoleRuntimeKey.primaryThaiLabels[canonEntityId];

  /// Deterministic mapping table for QA documentation.
  static List<ThaiCanonRuntimeMappingEntry> runtimeMappings() {
    return [
      for (final entity in CanonOntologyData.taksaRoles)
        ThaiCanonRuntimeMappingEntry(
          canonEntityId: entity.id,
          runtimeKey: entity.id,
          kind: ThaiCanonRuntimeKeyKind.taksaRole,
          note: 'Internal metadata key only — not report copy',
        ),
    ];
  }

  /// Whether a Canon unit references a Taksa role on subject or object.
  static bool unitReferencesTaksaRole({
    required String subject,
    required String object,
  }) {
    return ThaiTaksaRoleRuntimeKey.isAllowed(subject) ||
        ThaiTaksaRoleRuntimeKey.isAllowed(object);
  }
}
