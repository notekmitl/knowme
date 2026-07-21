/// Canon Knowledge Extraction Workspace V4 — barrel export.
///
/// The **Knowledge Extraction Workspace**: the only supported path for adding new
/// Canon knowledge. It orchestrates the lifecycle
///
///   Book Page → Extraction Workspace → Atomic Knowledge Units → Ontology
///   Validation → Knowledge Graph Validation → Review → Canon Database
///
/// over the (frozen) atomic + ontology knowledge layers. No engine may depend on
/// it; it depends on no engine/runtime/matrix/mirror/fusion. Pure Dart.
library;

export 'completeness_delta.dart';
export 'extraction_source.dart';
export 'knowledge_diff.dart';
export 'knowledge_extraction_session.dart';
export 'review_report.dart';
export 'workspace_validator.dart';
