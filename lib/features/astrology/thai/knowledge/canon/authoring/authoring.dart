/// Canon Knowledge Authoring Studio V1 — barrel export.
///
/// The official human editing layer that sits *before* the Knowledge Extraction
/// Workspace:
///
///   Reference Book Page → Authoring Studio → Draft Knowledge Units → Workspace
///   Validation → Diff → Review → Canon Import
///
/// Authoring only — nothing here is Canon, and it reuses the Workspace validator
/// rather than duplicating it. Pure Dart; no engine/runtime/matrix/mirror/fusion.
library;

export 'authoring_studio.dart';
export 'draft_knowledge_unit.dart';
export 'ontology_assist.dart';
