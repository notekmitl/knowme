# Four failed cases

| Failed assertion | Accepted fixture | Raw first difference | After line-ending canonicalization |
|---|---|---:|---|
| `thai_beta_live_oracle_parity_test.dart` — frozen/live five | `owner-known-0035` Web/PDF | offset 22: `CR` (13) vs `LF` (10) | exact |
| `thai_beta_live_asof_diagnostic_test.dart` — Clock A/B/C | `owner-known-0035` Web/PDF | offset 22: `CR` (13) vs `LF` (10) | exact |
| `thai_beta_copy_normalization_scope_test.dart` — canonical/fail-closed/Web-PDF/S008 | `owner-unknown` Web | offset 22: `CR` (13) vs `LF` (10) | exact |
| `thai_beta_copy_semantic_safety_test.dart` — deterministic R7.1 canonical | `owner-unknown` Web | offset 22: `CR` (13) vs `LF` (10) | exact |

The matcher’s human-readable message numbers the first difference as offset 23. The byte probe uses zero-based offset 22. No non-line-ending difference remains.
