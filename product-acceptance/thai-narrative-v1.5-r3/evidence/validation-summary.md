# R3 validation summary

- Focused command: `flutter test test/validation/thai_beta/narrative test/validation/thai_beta/core_reading test/validation/thai_beta/thai_beta_report_export_test.dart test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart --reporter compact --file-reporter expanded:<R3>/evidence/test-focused-raw.log`
- Final result: exit 0; 264 passed; 0 failed. Raw UTF-8 output is `test-focused-raw.log`; it has no BOM and ends with `All tests passed!`.
- Synthetic: 300 cases (225 Known / 75 Unknown), 300 unique full reports, deterministic sample stable, 20 real PDF parity cases passed.
- Scoped analyzer: exit 0, `No issues found!` for R3 narrative/core/export implementation and focused tests.
- Full suite: not rerun and not claimed for R3.
- Artifact generation test: exit 0; five canonical Web/PDF pairs produced.
- Machine-readable narrative metrics: `r3-audit-metrics.json`.
- Visual QA: 30/30 pages inspected from final PDFs; see `geometry-visual-qa.md`.
