/// Canon Atomic Knowledge V2 — vocabulary.
///
/// The atomic model treats Canon as a **knowledge graph**: entities connected by
/// first-class relationships. This file defines the controlled vocabulary
/// (relations, entity kinds, knowledge domains, strength) so atomic facts are
/// structured, not narrative.
///
/// Pure Dart leaf — no imports, no Flutter, no engine/runtime/matrix.
library;

/// First-class relationship between two entities. Each value has a stable
/// snake_case wire name used in JSON and the graph.
enum AtomicRelation {
  owns, // planet owns meaning
  supports, // planet supports planet
  opposes, // planet opposes planet
  belongsTo, // house belongs_to domain
  locatedIn, // planet located_in house
  requires, // rule requires condition
  produces, // rule produces effect
  exceptionTo, // exception exception_to rule
  relatesTo; // generic, last resort

  String get wire => switch (this) {
        AtomicRelation.owns => 'owns',
        AtomicRelation.supports => 'supports',
        AtomicRelation.opposes => 'opposes',
        AtomicRelation.belongsTo => 'belongs_to',
        AtomicRelation.locatedIn => 'located_in',
        AtomicRelation.requires => 'requires',
        AtomicRelation.produces => 'produces',
        AtomicRelation.exceptionTo => 'exception_to',
        AtomicRelation.relatesTo => 'relates_to',
      };

  static AtomicRelation? fromWire(String? wire) {
    if (wire == null) return null;
    for (final r in AtomicRelation.values) {
      if (r.wire == wire || r.name == wire) return r;
    }
    return null;
  }
}

/// The kind of entity a subject/object refers to. `other` keeps the vocabulary
/// open without inventing a fixed ontology.
enum AtomicEntityKind {
  planet,
  house,
  sign,
  element,
  domain,
  meaning,
  role,
  keyword,
  rule,
  condition,
  effect,
  remedy,
  period,
  aspect,
  other;

  static AtomicEntityKind fromName(String? name) {
    if (name == null) return AtomicEntityKind.other;
    for (final k in AtomicEntityKind.values) {
      if (k.name == name) return k;
    }
    return AtomicEntityKind.other;
  }
}

/// Strength of an atomic effect/relation when the source states one.
enum AtomicStrength {
  none,
  low,
  medium,
  high;

  static AtomicStrength fromName(String? name) {
    if (name == null) return AtomicStrength.none;
    for (final s in AtomicStrength.values) {
      if (s.name == name) return s;
    }
    return AtomicStrength.none;
  }
}

/// Knowledge domains used by the Canon Completeness Report. Coverage is measured
/// per domain, never per file.
enum KnowledgeDomain {
  planetLibrary,
  houseLibrary,
  signLibrary,
  planetRelationships,
  aspects,
  remedies,
  lifePeriodRules,
  other;

  String get label => switch (this) {
        KnowledgeDomain.planetLibrary => 'Planet Library',
        KnowledgeDomain.houseLibrary => 'House Library',
        KnowledgeDomain.signLibrary => 'Sign Library',
        KnowledgeDomain.planetRelationships => 'Planet Relationships',
        KnowledgeDomain.aspects => 'Aspects',
        KnowledgeDomain.remedies => 'Remedies',
        KnowledgeDomain.lifePeriodRules => 'Life Period Rules',
        KnowledgeDomain.other => 'Other',
      };

  static KnowledgeDomain fromName(String? name) {
    if (name == null) return KnowledgeDomain.other;
    for (final d in KnowledgeDomain.values) {
      if (d.name == name) return d;
    }
    return KnowledgeDomain.other;
  }
}
