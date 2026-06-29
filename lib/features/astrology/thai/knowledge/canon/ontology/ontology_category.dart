/// Canon Ontology V3 — entity categories.
///
/// The Canonical Ontology Layer is the single controlled vocabulary shared by
/// every Canon package. Each canonical entity belongs to exactly one category.
/// The category [wire] also forms the id prefix convention (`<wire>.<slug>`,
/// e.g. `planet.jupiter`, `domain.finance`, `relationship.owns`).
///
/// Pure Dart leaf — no imports, no Flutter, no engine/runtime/matrix.
library;

enum OntologyCategory {
  planet,
  house,
  sign,
  element,
  domain,
  lifeArea,
  relationship,
  condition,
  effect,
  remedy,
  agePeriod,
  gender,
  confidence,
  evidence,
  school,
  book,
  author,
  knowledgeStatus,
  other;

  /// Stable wire name used in ids and JSON.
  String get wire => name;

  static OntologyCategory fromWire(String? wire) {
    if (wire == null) return OntologyCategory.other;
    for (final c in OntologyCategory.values) {
      if (c.wire == wire) return c;
    }
    return OntologyCategory.other;
  }
}
