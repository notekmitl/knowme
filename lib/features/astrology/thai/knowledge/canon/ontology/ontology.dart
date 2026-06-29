/// Canon Ontology V3 — barrel export.
///
/// The **Canonical Ontology Layer**: the single controlled vocabulary every
/// Canon package must use. No package may invent entity or relationship names
/// outside this ontology.
///
/// Flow: Book → Atomic Knowledge → **Canonical Ontology** → Knowledge Graph →
/// Rule Engine → Reasoning → Narrative.
///
/// Pure Dart; no Flutter/engine/runtime/matrix/mirror/fusion dependency.
library;

export 'canon_ontology_data.dart';
export 'canonical_entity.dart';
export 'canonical_ontology.dart';
export 'ontology_category.dart';
export 'ontology_validation.dart';
