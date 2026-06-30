/// Canon Working Source Adapter — barrel export.
///
/// A temporary working-source layer that lets the Authoring Studio consume
/// PDF / Images / OCR text / plain text through one common interface:
///
///   Working Source → Page → Paragraph → Authoring Studio
///
/// Working Sources are **temporary and never Canon**: only page / chapter / book
/// / edition references survive (D-057). No automatic extraction, no AI — the
/// adapter only supplies temporary text to the reviewer. Pure Dart; depends only
/// on the workspace `ExtractionSource`. No engine/runtime/ontology/workspace
/// redesign.
library;

export 'working_page.dart';
export 'working_source_adapters.dart';
export 'working_source_base.dart';
export 'working_source_folder.dart';
