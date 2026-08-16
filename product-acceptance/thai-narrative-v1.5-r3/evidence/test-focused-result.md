# Focused test result

- Command: `flutter test test/validation/thai_beta/narrative test/validation/thai_beta/core_reading test/validation/thai_beta/thai_beta_report_export_test.dart test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart --reporter compact --file-reporter expanded:<R3>/evidence/test-focused-raw.log`
- Exit code: `0`
- Passed: `264`
- Failed: `0`
- Raw log: `test-focused-raw.log` (58,659 bytes, UTF-8, no BOM, zero failure markers)

Final raw tail:

```text
00:14 +261: 30 stratified cases are deterministic across three runs
00:17 +262: 60-case deep narrative sample has ownership and no within-report collapse
00:17 +263: 20 representative cases produce real PDFs with Web semantic parity
00:18 +264: All tests passed!
```

The raw file retains full absolute test paths and the complete synthetic JSON result; the shortened tail above is an index, not a replacement log.
