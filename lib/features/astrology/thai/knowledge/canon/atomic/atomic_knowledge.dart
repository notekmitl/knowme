/// Canon Atomic Knowledge V2 — barrel export.
///
/// One import for the atomic knowledge model: vocabulary, the atomic unit,
/// extraction rules, the knowledge graph and the completeness report.
///
/// This layer realises the platform's direction:
/// Book → **Atomic Knowledge** → **Knowledge Graph** → Rule Engine → Reasoning →
/// Narrative (narrative is generated from knowledge, never stored as Canon).
///
/// Pure Dart; no Flutter/engine/runtime/matrix/mirror/fusion dependency.
library;

export 'atomic_extraction_rules.dart';
export 'atomic_knowledge_graph.dart';
export 'atomic_knowledge_unit.dart';
export 'atomic_relation.dart';
export 'canon_completeness_report.dart';
