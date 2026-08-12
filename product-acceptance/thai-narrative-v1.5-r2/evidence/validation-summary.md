# R2 validation summary

- Exact focused command: `flutter test test/validation/thai_beta/narrative test/validation/thai_beta/core_reading test/validation/thai_beta/thai_beta_report_export_test.dart test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart --reporter compact`
- Result: exit 0; 261 passed; 0 failed.
- Synthetic audit: 300 cases; 300 distinct full reports; no within-report claim collapse. This is supporting evidence only, not the interpretive-distinctness conclusion.
- Full suite final run: 2,850 passed / 53 failed. Failures include existing repository baselines outside the focused R2 gate (sidereal fixtures, human coverage, app/widget wiring) and older Life Map policy tests sensitive to the new cautious wording. This package does not claim full-suite success.
- Analyzer: 299 pre-existing warnings/info; no R2 compile error. Analyzer exits 1 under the repository's existing lint backlog.
- PDF parity: all five generated Web/PDF canonical text pairs are byte-identical.
- Visual QA: 30/30 rendered pages inspected; no blank/footer-only page, clipping, overlap, out-of-bounds text, or incorrect footer numbering observed.
