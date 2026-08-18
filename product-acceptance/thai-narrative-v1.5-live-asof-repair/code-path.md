# Exact code path

Line references are from the repair branch before the evidence commit.

1. `thai_beta_input_page.dart:69` captures `_startedAt` once when the form state initializes. It is used for session duration only.
2. `thai_beta_input_page.dart:100` captures `submittedAt` once after validation, at the actual submit action.
3. `thai_beta_input_page.dart:128-131` invokes the analysis executor with both values and converts submit time to Bangkok civil `asOf`.
4. `thai_beta_analysis.dart:114-116` resolves one `readingAt`; success and every failure path store it as `ThaiBetaAnalysis.asOf`.
5. The runner passes `readingAt` to `ThaiMirrorPipeline.generate` and `ThaiMirrorConsumerPresenter.present`.
6. `thai_beta_narrative_context.dart:29` uses `analysis.asOf`, not `analysis.startedAt`, as the narrative reference date.
7. The report page renders the already computed analysis. `ThaiBetaReportExportDocument.fromAnalysis` constructs one canonical export document from that analysis.
8. `thai_beta_report_export_button.dart:31` retains that document; its download action calls `ThaiBetaReportPdfExporter.buildBytes(document)` at line 58. It does not call the runner or a clock.

Therefore the production path is:

`form init startedAt → one submit instant → Bangkok civil asOf → runner readingAt → pipeline → presenter/narrative context → one analysis → Web view/export document → PDF from the same document`

The persisted research record continues to use its existing server `submittedAt` and session-duration fields. No persistence schema was changed.
