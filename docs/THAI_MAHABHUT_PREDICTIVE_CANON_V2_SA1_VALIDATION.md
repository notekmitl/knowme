# Thai Mahabhut Predictive Canon V2 — SA1 Validation

Date: 2026-08-30

Status: **VALIDATION PASS FOR PARTIAL DESIGN CORPUS**

Command:

```powershell
python tool/validate_mahabhut_predictive_rules_v2.py --source-root MAHABHUT_SOURCE_ROOT
```

## Corpus and trace results

| Gate | Result |
|---|---:|
| proposed rules | 12 |
| schema-valid rules | 12/12 |
| page trace | 12/12 |
| short evidence | 12/12 |
| unsourced event rule | 0 |
| generalized example | 0 |
| arbitrary threshold | 0 |
| arbitrary fixed confidence | 0 |
| unsupported event | 0 |
| unsupported timing | 0 |
| Canon/supporting-tier inversion | 0 |
| hidden conflict | 0 |
| hardcoded Owner fixture branch | 0 |
| Known→Unknown leakage | 0 |
| reader-visible duplicate | 0 |
| past reflection/question | 0 |
| psychology leakage | 0 |
| stale active source status | 0 |

Source PDF SHA-256 matches the reconciled manifest. Live Canon count is 834
atomic units + 20 note sentinels = 854 raw array elements, plus 29 reference
cells. Production foundation delta is 0.

## Timing and fixture results

- birthday segmentation: 300/300 pass, deterministic errors 0, 246 distinct
  segment signatures;
- this is a determinism/variety audit, not an accuracy validation;
- focused Canon manifest tests: 42/42 pass;
- fixture separation: 4/4 pass;
- 00:03 → Aquarius 9°24′ / Saturday;
- 00:35 → Aquarius 19°19′ / Saturday;
- Unknown → no noon, ascendant, houses or Thai-day assertion;
- `monthlyTimelineAvailable=false` remains unchanged.

## Delta and suite decision

- runtime application Dart delta: 0;
- production/frozen Canon delta: 0;
- `product-acceptance/` delta: 0;
- test delta: two stale manifest expectation/description lines only;
- tooling/data/docs delta: proposed schema, corpus, validator and evidence;
- Full Flutter suite is not rerun because no runtime Dart behavior changed;
- analyzer is run because a Dart test file changed, even though runtime delta is
  zero.

Passing validation does not close the 2537→2539 edition mapping or the
remaining 48 narrative contexts / 45 OCR blockers. It validates the partial
corpus as represented; it does not claim predictive accuracy or runtime
readiness.
