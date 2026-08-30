# Mahabhut 2537 Predictive Claim Type Contract

Status: **PROPOSED EVIDENCE CONTRACT — NOT RUNTIME**

## A. SOURCE_PLACEMENT_FACT

Permitted fields: exact context, planet, Taksa role, Mahabhut house, age
boundary, rise/fall classification, and proven Kalakini exception. A
placement fact cannot own a reader prediction directly.

## B. SOURCE_DIRECT_PREDICTION

Required fields: `claimId`, exact `contextId`, source edition, page, inspected
page-image flag, paragraph/section boundary, short excerpt, age/period binding,
domain, subject, movement/outcome, timing granularity, allowed conclusion and
prohibited escalation. Keyword discovery alone cannot create this type.

## C. SOURCE_GENERAL_RULE_APPLICATION

Required fields: exact placement record, all source-rule references, all
conditions proven, exact context/period/domain and bounded outcome. It must be
described as an application of a general rule, never as a context quotation.

## D. OWNER_AUTHORIZED_PRODUCT_INTERPRETATION

This type may combine Tier-0 facts, a proven placement, a proven general-rule
application, source-direct claims and traceable supporting evidence. It must
carry the internal label
`INTERNAL_PRODUCT_INTERPRETATION_NOT_SOURCE_QUOTE`.

It may state only a broad direction such as work moving forward, money
becoming easier, burden increasing, support weakening, or foundation building
moving well. It may not create a job title, person type absent from evidence,
amount, month/date, disease/diagnosis, marriage/separation, job transfer,
large windfall, numeric threshold or invented confidence.

## Reader ownership

- Every reader prediction sentence has one `readerClaimId`.
- Every `readerClaimId` maps to exactly one semantic owner.
- An owner must have compatible context, period and domain.
- Advice has a separate `ADVICE` owner and may appear only in the advice
  section.
- Omission and disclaimer sentences have `OMISSION` or `DISCLOSURE` owners;
  they are not prediction claims.
- Repeated normalized meaning across reader sections is an error unless the
  period binding is materially different and the wording communicates that
  difference.

## Evidence-page rule

`pageImagesReviewed` means only the listed image was actually opened. A claim
from a continuation page must list that page itself. A context opening table
cannot stand in for a narrative paragraph on another page.
