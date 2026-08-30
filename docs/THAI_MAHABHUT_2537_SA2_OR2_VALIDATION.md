# PR112 SA2 OR2 Candidate 0010 Validation

Status: **STRUCTURAL PASS — PENDING OWNER CONTENT REVIEW**

## Candidate and claim coverage

- Candidate 0010 Known reader claims: 26
- Known prediction paragraphs: 24
- Known non-prediction claims: one advice and one disclaimer
- Candidate 0010 Unknown reader claims: one omission and one disclaimer
- Chronology order errors: 0
- Candidate 0009: rejected with 7 prediction paragraphs and depth shortfall 11

## Structural results

All 27 calculated error counters are 0. This covers schema, evidence/rule
ownership, inspected pages, product labels, context/period/domain matching,
reader/map coverage, unsupported exact event/timing markers, duplicate semantic
owners/meaning, advice conversion/leakage, methodology, psychology, defensive
language and Known-to-Unknown leakage.

The original six negative controls pass 6/6: unsupported promotion/October,
wrong-domain owner, missing evidence owner, Known copy in Unknown, repeated
meaning/owner and advice inserted into prediction are all detected.

Fixture separation remains intact: 00:03 resolves Aquarius 9°24′ / Saturday,
00:35 resolves Aquarius 19°19′ / Saturday, and Unknown has zero time-dependent
fields and no noon substitution. The context/period selection coverage audit
passes 300/300 profiles across 49 contexts and 160 context-period signatures.
It is not a prediction-accuracy or content-quality audit.

Focused Canon/source Flutter tests pass 44/44. `git diff --check` is required at
the final gate. Full Flutter suite and analyzer are not rerun because runtime
application and Dart test deltas are zero.

## Interpretation boundary

Validator PASS proves structure, trace, domain, period, unsupported exact
timing/event markers and duplication markers only. It does not prove predictive
accuracy, truth in the reader's life, language quality or Owner content
acceptance.
