# Final cross-runtime gate blocker

Status: **BLOCKED**.

All four runs executed 300/300 cases: 225 Known and 75 Unknown. Each run produced 300 unique reports and 300 unique narratives; Unknown omission passed 75/75. VM run 1 equals VM run 2 and Chrome run 1 equals Chrome run 2 with zero nondeterminism.

Exact VM-versus-Chrome delta:

| Field group | Mismatches |
|---|---:|
| Profile signature | 0 |
| Structured signature | 0 |
| Period-score signature | 0 |
| Report snapshot/hash | 1 (`S008`) |
| Canonical text | 0 |
| Narrative-only | 1 (`S008`) |
| Unknown omission | 0 |
| Copy-normalization impact | 0 |

For S008, the raw serialized field `reportSnapshot.profile.siderealAscendantDeg` is `102.39560244592322` in Dart VM and `102.39560244592323` in compiled JavaScript/Chrome: a one-ULP upstream floating-point/runtime difference. This changes the report snapshot SHA-256 (`da3bbf8e...` vs `70aeabe6...`) and report hash (`b9bf5646...` vs `858bf9d6...`). `ThaiBetaNarrativeContext` intentionally consumes the report-hash prefix as a fallback seed, so the difference propagates to narrative-only SHA-256 (`bf775363...` vs `793cbf09...`).

The canonical five fixtures remain exact across runtimes and against frozen accepted R7.1 (5/5); live Web/PDF/repeat parity is 5/5. This does not waive the required per-profile 300-case gate.

No expected output, canonical text, golden, test coverage, or post-hoc text replacement was changed to hide S008. Per policy, broader final regressions, full analyzer comparison and production Web release rebuild were not claimed as fresh final reruns after this mandatory gate failed. Prior logs remain historical evidence only. PR #95 must remain Draft; no merge, deploy or Firebase change is allowed.
