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
  meaning,
  role,
  keyword,
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

  /// Mahabhut Named Position — the book's own system of named planetary
  /// positions (`เรือนธงชัย`, `อธิบดี`, `ขุมทรัพย์`, …). Controlled vocabulary
  /// only (identifier + Thai aliases); the *meaning* of each position is Canon
  /// knowledge extracted from the book, never encoded here. Added by D-067 to
  /// unblock Mahabhut knowledge production (D-065 Ontology Expansion). Every
  /// existing category keeps its same `wire` identifier (the only persisted
  /// form); `other` stays the resolution fallback.
  mahabhutPosition,

  /// Planet Library attribute **category** (D-072 Ontology Expansion).
  /// Structural slot only — e.g. color, taste, metal, disease, place,
  /// profession. No meanings, relationships, or Canon claims encoded here.
  attributeCategory,

  /// Planet Library attribute **value token** (D-072). A stable id + verbatim
  /// Thai surface form(s) from the Canon source; parentId points at an
  /// [attributeCategory]. What a planet *signifies* is Canon knowledge produced
  /// through extraction, never encoded in the ontology layer.
  attribute,

  /// Mahabhut **ทักษา** dignity role (D-074 Phase C). Controlled vocabulary
  /// only — stable id + Thai aliases from the Canon text (`บริวาร`, `อายุ`, …).
  /// Role *meanings* and planet assignments are Canon knowledge, never encoded
  /// here.
  taksaRole,
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
