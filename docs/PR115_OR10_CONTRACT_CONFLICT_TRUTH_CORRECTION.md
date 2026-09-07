# PR115 OR10 contract conflict truth correction

Date: 2026-09-07  
Status: **OWNER CONTRACT CORRECTED — RUNTIME IMPLEMENTATION AUTHORIZED — NOT PRODUCT ACCEPTANCE**

## Conflict proved in OR10

The Known 00:03 and 00:35 fixtures resolve to the same predictive signature:

- context: `mahabhut2537.rem0.saturday`
- current age: `44`
- period selector: `mahabhut2537.rem0.saturday.venus.42_62`
- typed materials: `12/12`, byte-equivalent after deterministic serialization
- raw forecast SHA-256: `292AEA14829A29935A0B877E8A536A6557DAB43ACD68BAE535E091B7D7CD7669`

The former requirement that 00:03 emit Candidate 0011 while 00:35 emit Candidate 0023 was therefore contradictory with a deterministic signature-based generator. The only differing inputs were the birth minute and computed ascendant degree, both of which were prohibited as predictive-copy selectors.

## Owner correction

Candidate 0023 is the active runtime content target for this predictive signature. Every Known input with the same signature must emit the same predictive section IDs, order and text. The report identity and provenance remain calculated from the actual input, so 00:03 continues to show `00:03` and Aquarius `9°24′`, while 00:35 continues to show `00:35` and Aquarius `19°19′`.

Candidate 0011 remains the immutable historical Owner-accepted content oracle at reader-block SHA-256 `6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E`. Removing it as the active 00:03 production runtime oracle does not revoke or rewrite that historical acceptance.

Candidate 0023 remains exact at full-reader-copy SHA-256 `FDA1DA8917CD5ADCA4650AECF87414DCFCDEE7F13019DF0794ECF76DFD91E7F2` for the pinned 00:35 evidence fixture.

## Safety boundary

Production predictive copy must not branch on birth date, birth hour/minute, province, gender, ascendant degree or pinned `asOf`. It must select reusable semantic-owner components from context, resolved life period and typed evidence materials. Missing evidence is omitted fail-closed. Unknown-time reports remain outside this Known-time predictive path.

This correction authorizes implementation and testing only. It is not Owner Product Acceptance, merge authorization or deployment authorization.
