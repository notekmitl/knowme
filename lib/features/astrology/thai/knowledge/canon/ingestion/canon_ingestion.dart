/// Mahabhut Ingestion Toolchain V1 — barrel export.
///
/// One import for the whole ingestion toolchain: parse → extract → validate →
/// approve → diff → QA → metrics. Pure Dart; no Flutter, engine, runtime,
/// mirror, fusion or narrative dependency.
library;

export 'canon_approval_workflow.dart';
export 'canon_candidate.dart';
export 'canon_candidate_validator.dart';
export 'canon_consistency_checker.dart';
export 'canon_coverage_analysis.dart';
export 'canon_diff_engine.dart';
export 'canon_extraction_engine.dart';
export 'canon_extraction_metrics.dart';
export 'canon_qa_tools.dart';
export 'canon_review_assistant.dart';
export 'canon_source_document.dart';
