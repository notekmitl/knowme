# Thai Report Reader Voice Contract V3

Revision: **1 — meaning-density and reader-perceived-repetition repair**

Status: **CONTENT CONTRACT PROPOSAL — PENDING OWNER COPY AND EDITORIAL-INTERPRETATION REVIEW — NOT IMPLEMENTED**

## Purpose

Reader Voice V3 separates evidence authority from prose length. Evidence limits what a report may mean; it does not require the reader copy to mirror a short source span or collapse each section into one sentence. The desired voice is natural, warm, direct Thai using “คุณ”, as if an astrologer were explaining the chart to its owner.

Candidate 0023 remains immutable historical engineering evidence, but its exact SHA and exact wording are not a target for V3. Candidate 0011 may guide cadence, continuity and detail level only. No event, fact, cause, timing or prediction may be imported from Candidate 0011 without current evidence. Candidate 0024 is retained as an Owner-rejected historical proposal with the decision `OWNER-REJECTED — MEANING-DENSITY AND READER-PERCEIVED REPETITION`.

## Meaning-density model

Sentence count is descriptive, not a sufficiency gate. The audit records each of these separately:

- `sentence_count`: reader-visible sentences and standalone factual lines.
- `distinct_meaning_units`: separately useful meanings carried by those sentences.
- `LIVED_MEANING`: a practical explanation that makes a core prediction observable without merely translating it.
- `READER_PERCEIVED_DUPLICATE`: a later sentence with the same semantic owner and lived meaning as an earlier sentence at the same level, even when surface words differ.
- `UNSUPPORTED_CLAIM`: a new event, causal link, timing, certainty, domain outcome or other meaning outside current authority.

More sentences do not imply more detail. A section may use one strong sentence when no second meaning is authorized. Deterministic semantic-owner fixtures—not a similarity percentage—decide the negative controls, and every rejection must carry a human-readable reason.

## Sentence functions

Every reader sentence or factual line has exactly one primary function:

- `CORE_PREDICTION`: states an evidence-bound prediction.
- `LIVED_MEANING`: makes an authorized prediction understandable in everyday terms without changing it.
- `CONTEXTUAL_TRANSITION`: joins periods or sections without claiming a new cause.
- `INTENTIONAL_SUMMARY`: previews detail owned by named lower-level destinations.
- `ADVICE`: suggests an action in the advice section.
- `DISCLOSURE`: states limits, scope or interpretive boundaries.
- `METHODOLOGY`: states input, calculation basis or provenance.

If a new sentence has no meaning/function distinct from the preceding one, it is `READER_PERCEIVED_DUPLICATE` and must be removed.

## Owner editorial interpretation layer

`OWNER_EDITORIAL_INTERPRETATION_PENDING` is an evidence class for a proposed lived explanation that goes beyond strict logical equivalence without creating a calculated result or event. It must:

- keep the same domain, period and certainty as its supporting core prediction;
- add no event, causal astrology link, person, amount or outcome;
- be listed verbatim in the Owner review with the supporting core and explanatory purpose;
- remain visibly `PENDING` until the Owner accepts or rejects it.

Validator success confirms only that the proposal obeys these declared boundaries. It never converts a pending editorial interpretation into accepted content.

## Sentence classes

- `SOURCE_FACT`: a profile/calculation fact or source-bound claim stated inside its documented domain, period and certainty.
- `INTERPRETIVE_PARAPHRASE`: a fuller explanation of the same evidence meaning. It may make the meaning easier to observe or understand, but may not add an event, cause, person, timing, amount or outcome.
- `INTENTIONAL_SUMMARY_TO_DETAIL`: a high-level preview that names one or more later details. The summary and destination must have different wording and different reading functions.
- `ADVICE`: an action suggestion in a visibly separate advice section. It may relate to the predictions but is never itself presented as a predicted outcome.
- `METHODOLOGY`: provenance, calculation basis, content separation or limitation. It does not belong inside prediction prose.
- `BLOCKED`: a tempting but unsupported meaning that must stay out of reader copy.

## Narrative structure

The overview has two paragraphs and 5–7 sentences. The first tells the life sequence from childhood through ages 11–29 and 30–41; the second locates the reader in the current 42–62 period and previews current themes. It must work as a useful map before the reader reaches details.

Past age sections use 2–3 sentences when evidence provides distinct material. Each section states both the character of that period and how it differs from the previous one. Simultaneous learning and career facts must not be rewritten as a causal education-to-career claim.

The current-age introduction expresses the period-level effect of easier action, communication and decision-making without splitting one meaning across several sentences to satisfy a count. Domain details remain in the work, finance, relationship, health and support sections.

Each current domain starts with its evidence-bound core prediction. A second sentence is allowed only when it supplies a distinct lived meaning, a separately authorized condition, or a disclosed `OWNER_EDITORIAL_INTERPRETATION_PENDING`. Padding, same-owner paraphrase and sentence-count filler are forbidden. If a second substantive meaning cannot be supported or proposed within the editorial layer, one strong sentence is preferable to repetition.

The rolling 12-month section has a distinct function from the current section. Current owns the present state; rolling 12 months owns change or continuation inside dates calculated from the actual `asOf`. Each sentence must add a different meaning or an explicit boundary; repeating work-scope and income claims to reach a sentence count is prohibited. Monthly predictions, favorable/caution months and hardcoded example dates are prohibited.

Advice and limitations remain separate. Advice must be practical and connected to preceding topics. Belief and health limitations must remain visible.

## Allowed explanation

- Combine multiple authorized facts into one flowing paragraph.
- Broaden a specific phrase without changing its meaning or certainty.
- Add one explanatory sentence when it is a consequence already contained in the same evidence meaning.
- Use connective context to show chronology without claiming causation.
- Preview lower-level evidence in the overview and expand it later through named `INTENTIONAL_SUMMARY_TO_DETAIL` links.

## Prohibited expansion

- New events, people, employers, diagnoses, amounts, dates or monthly timing.
- A new causal link, including education causing career results or supporters causing work/financial outcomes.
- A certainty change or a conditional filler used to manufacture detail.
- Advice or personality written as a prediction.
- Repeating the same meaning at the same level, copying one template across domains, or restating a full paragraph in a closing summary.
- Reader-facing system terms such as evidence, selector, material, authority, fingerprint, resolver or claim ID.

## Main-chart facts-only rule

The `โครงสร้างดวงหลัก` block contains only:

- วันทางโหราศาสตร์
- ลัคนา
- เจ้าเรือนลัคนา
- เรือนการงานและเจ้าเรือน
- เรือนการเงินและเจ้าเรือน
- เรือนความสัมพันธ์และเจ้าเรือน
- เรือนสุขภาวะและเจ้าเรือน

No personality, prediction, method explanation or “ใช้ประกอบการอ่าน...” tail may follow those values. Provenance explanations belong in the source/method section.

## Signature and fail-closed boundaries

Known 00:03 and 00:35 with the same predictive signature and `asOf` must receive an identical predictive body. Their calculated identity facts remain different: Aquarius 9°24′ and Aquarius 19°19′. Names, fixture IDs, birth minutes, ascendant degrees and province labels may not select predictive prose.

Unknown birth time must remain fail-closed. It must not receive Known ascendant, houses, time-dependent claims or Known-only infographic content. Candidate 0025 does not authorize any Unknown copy or runtime change.

## Acceptance sequence

Candidate 0025 is a content proposal only. Candidate 0024 is rejected and must not be implemented. Engineering validation may check boundaries, mappings and negative controls, but it cannot declare the prose good or accepted. No exact SHA/golden, runtime implementation, visual artifact regeneration, merge or deployment is allowed until Owner has read and accepted the full candidate and separately decided every pending editorial interpretation.
