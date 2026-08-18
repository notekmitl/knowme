# Fresh post-merge pre-deploy gate

Source `642069f0f298bc8a1f86b795f043e02e914aa97d` was checked out in a clean isolated LF-preserving worktree. No pre-repair result is counted here.

- mandatory `test/validation/thai_beta/live_asof`: 36 passed / 0 failed;
- line-ending exact-text helper contract: included and passing;
- frozen canonical Web/PDF: 5/5 exact;
- live Web/PDF: 5/5 exact; repeat deterministic 5/5;
- copy semantic audit: 300/300, exact textual/semantic/reader-visible/omission/addition/prediction-to-advice mismatch 0;
- Unknown fail-closed mismatch 0; Web/PDF mismatch 0;
- VM run 1/2 and real Chrome run 1/2: 300 profiles each; nondeterminism and every canonical/profile/structured/score/report/narrative/Unknown/copy mismatch 0;
- S008 raw VM/Chrome differs by one ULP as disclosed; canonical units, displayed degree, report and text mismatch 0;
- scoped analyzer: no issues;
- accepted evidence: 332/332, 480,630,900 bytes, missing 0, mismatch 0;
- R7.1: 10,709,328 bytes / 80 entries / internal checksums 79/79 / immutable 63/63 / historical modified paths 0;
- Owner Known Aquarius 19°19′; regression 00:03 Aquarius 9°24′; traceability 170/170.

Result: PASS. Production was still V1.4 version `10af10c6d960d590` and rollback Preview retained the same version immediately before the one-time release build.
