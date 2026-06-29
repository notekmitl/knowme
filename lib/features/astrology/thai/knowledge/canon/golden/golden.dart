/// Canon Golden Dataset V1 — barrel export.
///
/// The official **QA reference** for Canon development: deterministic synthetic
/// datasets with declared expected outcomes, a verifier that drives the *real*
/// Canon pipeline (Workspace validation → diff → review → import → completeness),
/// and deterministic reports. This is the Canon Platform regression suite.
///
/// QA only — no astrology engine consumes these datasets, and they contain no
/// copyrighted text and no invented facts. Pure Dart; no engine/runtime/matrix/
/// mirror/fusion dependency.
library;

export 'golden_dataset.dart';
export 'golden_datasets.dart';
export 'golden_report.dart';
export 'golden_verifier.dart';
