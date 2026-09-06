# OR5R authority gate — historical truth correction

Owner rejected the old 0/22 result as a valid final authority gate. This correction does not revoke the accepted 00:03 oracle or the Unknown containment / Dedicated PDF TECHNICAL PASS. Actual 00:35 content remains NOT OWNER-ACCEPTED.

## What the old tool actually did

Historical baseline: `8325e04275d7cb58447abbf9b5dd1ff12acda2d8`.

- `tool/or5r_authority_matrix.mjs:51` selects actual decisions by whole-paragraph equality with `c.exactAcceptedText` from the 22 Candidate0011 paragraphs.
- Line 68 hardcodes both per-entry support booleans to false.
- Line 78 hardcodes `sourceBoundSupported:0` and `ownerAuthorizedInterpretationSupported:0`.
- Line 84 hardcodes `status:'ACTUAL_INPUT_BOUND_AUTHORITY_NO_GO'`.

The old output establishes only that actual 00:35 did not emit the 22 exact Candidate0011 paragraphs. It cannot prove that the ten actual runtime claims have no authority. Compatible selectors/materials and different prose do not by themselves settle claim authority either way. Previous status text that used that 0/22 as a final authority verdict is superseded by this correction, not silently rewritten.

The old validator, its `.md` / `.json` results and the old Owner ZIP are preserved unchanged. Regression checks compare historical validator/results byte-for-byte with the baseline commit. The new validator writes to different paths.

## Two separate contracts

Candidate0011 / 00:03 is the exact golden: accepted wording, paragraph order, interpretation reference and accepted reader-block SHA-256 `6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E`. Golden equality is necessary there and is not extended to another fixture.

Actual male 1982-06-06, 00:35, Chiang Mai, asOf 2026-08-29 Asia/Bangkok is checked from fresh runtime output. Its own full text is hash-bound to its own decision, not to Candidate text. Context, period, typed materials, selector/domain/direction/timing, synthesis owner, conflict and certainty are separately inspected.

## Neutral V2 method and limits

`tool/or5r_actual_authority_v2.mjs` derives classifications/counts/status from entries and semantic slots. It has a real passing positive control: an already accepted Candidate paragraph with all resolved references **at its own 00:03 scope**, excluded from actual 00:35 totals. A separate source-field control exercises direct-source classification; it is a test-only fact, not a newly generated prediction.

For actual claims the matrix preserves emitted runtime references separately from explicit audit bridges to existing compatible Canon/source components. Those bridges are not new runtime citations, new Owner approval, or proof that generic prose follows from a band. Selector rows only authorize placement; historical OCR heuristic flags are not promoted to event authority. Typed materials alone do not authorize prose. General domain interpretation, causal details and strength/certainty still require review.

`OWNER_TEMPLATE_REVIEW_REQUIRED` means applicable components and generation provenance were resolved, but whole generalized wording was not accepted or proved source-direct. It does not count as supported. `UNSUPPORTED_MISSING_COMPONENT` identifies an unestablished binding in the inspected chain, not a metaphysical claim that no possible source exists. Quoted semantic-expansion annotations are AI/Machine judgements with evidence references; hashes validate binding, not semantic truth. Owner remains the content decision-maker.

The machine review does not add prose, omit runtime claims, repair defects or alter Canon. Semantic coverage uses actual past periods and requested slots, not a universal 22-paragraph target.

Scope: evidence/tool-only; no Dart/runtime/Flutter-test/Candidate/Canon/UI/PDF/containment/product-acceptance/Firebase/Production change. OPEN + DRAFT — NOT MERGED — NOT DEPLOYED.
