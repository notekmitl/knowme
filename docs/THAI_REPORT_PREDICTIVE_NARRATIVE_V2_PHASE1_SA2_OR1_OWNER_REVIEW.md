# PR112 Phase 1 SA2 OR1 Owner Review Guide

Status: **CANDIDATE 0009 PENDING OWNER CONTENT RE-REVIEW — DRAFT — NOT IMPLEMENTED**

This package repairs the semantic evidence model rejected in SA2 OR1. It does
not change application runtime, tests, generated product artifacts, Firebase,
Production or `product-acceptance/`.

## What changed

- The former “392 source-backed predictive atoms” claim is withdrawn. The 392
  records are `SOURCE_PLACEMENT_FACT` records: eight life-period placements for
  each of 49 archetype × Thai-day contexts.
- Source-direct predictions, general-rule applications and Owner-authorized
  product interpretations are separate arrays and separate claim types.
- OCR keyword hits are discovery aids only and never event evidence.
- The validator now calculates every counter from the corpus and reader map.
  Six mutations prove that unsupported event/timing, wrong domain, missing
  owner, Known-to-Unknown leakage, repetition and advice leakage are rejected.
- Candidate 0008 now fails. Candidate 0009 removes forced four-domain filler,
  uses one to three strong claims per prediction section and keeps one separate
  advice section plus one disclaimer.

## Review order

1. Read `ROOT_CAUSE.md`, `CORPUS_RECLASSIFICATION.md` and
   `CLAIM_TYPE_CONTRACT.md`.
2. Confirm `CANDIDATE_0008_REJECTION_AUDIT.md` explains why Candidate 0008 can
   no longer pass.
3. Review `CANDIDATE_0009_KNOWN.md` and `CANDIDATE_0009_UNKNOWN.md` as content
   candidates only.
4. Trace each reader sentence through `CANDIDATE_0009_CLAIM_EVIDENCE_MAP.md`
   and `candidate_0009_reader_claims.json`.
5. Inspect `VALIDATION.md`, `VALIDATION.json` and `NEGATIVE_CONTROLS.json`.

## Fixture and safety boundaries

Known uses male, 6 June 1982, 00:03, Chiang Mai, Aquarius 9°24′, Thai
astrological Saturday and `asOf=2026-08-29 Asia/Bangkok`. The next period is
Mercury / Mula / Athibodi, age 63–79. Unknown remains fail-closed: no noon
substitution, ascendant, houses, Thai astrological day or Known prediction.

Candidate 0009 is not runtime implementation and is not Owner-accepted by this
package. No merge, deployment or Firebase/Production change is authorized.
