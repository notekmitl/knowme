# PR112 SA2 OR1 — Semantic Evidence Root Cause

Status: **OWNER REJECT CONFIRMED — SA2 COUNTS AND VALIDATOR REQUIRED CORRECTION**

## What SA2 actually proved

SA2 proved 49 context placement mappings and 392 life-period placement
records. A placement record contains the planet, Taksa role, Mahabhut house,
age boundary, rise/fall status and proven exception. It is a
`SOURCE_PLACEMENT_FACT`; it is not automatically a prediction sentence.

## Defect chain

1. `tool/build_mahabhut_2537_sa2_corpus.py` assigned every period a domain
   from `ROLE_DOMAIN` and movement from rise/fall.
2. The builder then emitted one `predictiveAtom` for every placement, causing
   392 placement facts to be described as 392 source-backed predictions.
3. Each context recorded only its opening table in `pageImagesReviewed`.
   Continuation pages used by narrative statements were not represented as
   inspected evidence for an individual claim.
4. `domainEventCoverage` searched OCR text for keywords. A hit was not bound
   to a sentence, paragraph, planet, period or age boundary.
5. The keyword hit was nevertheless presented as direct/broad event coverage.
6. `tool/validate_mahabhut_2537_sa2.py` assigned
   `unsupported_event_count=0`, `unsupported_timing_count=0`, and
   `arbitrary_threshold_count=0` as constants instead of deriving them from
   reader claims and evidence owners.
7. Candidate 0008 could therefore add cross-domain wording and advice while
   still passing the validator.
8. Requiring work, finance, relationship and health in every period amplified
   the defect: missing evidence became filler, prediction became advice, and
   the same broad meaning appeared in multiple sections.

## Correction

- Keep v1 and Candidate 0008 as immutable rejection history.
- Reclassify the 392 records as `SOURCE_PLACEMENT_FACT`.
- Store OCR keyword matches only as `DISCOVERY_KEYWORD_HIT` with
  `eventEvidence=false` and `periodBound=false`.
- Admit a `SOURCE_DIRECT_PREDICTION` only after the page image, paragraph
  boundary, context, period, age and domain are explicit.
- Keep general-rule applications and Owner-authorized product
  interpretations separately labeled.
- Validate every reader prediction through one `readerClaimId` and one
  semantic owner.
- Remove the four-domain-per-period requirement.

This correction changes design evidence and validation only. It does not
change application runtime, production Canon, report generation, Firebase,
Production or `product-acceptance/`.
