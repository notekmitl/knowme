# Thai Report Reader Voice Contract V3

Status: **CONTENT CONTRACT PROPOSAL — PENDING OWNER COPY REVIEW — NOT IMPLEMENTED**

## Purpose

Reader Voice V3 separates evidence authority from prose length. Evidence limits what a report may mean; it does not require the reader copy to mirror a short source span or collapse each section into one sentence. The desired voice is natural, warm, direct Thai using “คุณ”, as if an astrologer were explaining the chart to its owner.

Candidate 0023 remains immutable historical engineering evidence, but its exact SHA and exact wording are not a target for V3. Candidate 0011 may guide cadence, continuity and detail level only. No event, fact, cause, timing or prediction may be imported from Candidate 0011 without current evidence.

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

The current-age introduction uses 2–3 sentences to explain the period-level effect of easier action, communication and decision-making. Domain details remain in the work, finance, relationship, health and support sections.

Each current domain should use 2–4 sentences only when evidence supports different functions: main condition, observable expression, evidence-bound caution, or evidence-bound continuation. An explanatory paraphrase may unpack the same authorized meaning, but padding or same-level repetition is forbidden. If two substantive sentences cannot be supported, the audit must record `AUTHORITY_GAP` instead of inventing content.

The rolling 12-month section uses 3–5 sentences and has a distinct function from the current section. Current owns the present state; rolling 12 months owns change or continuation inside dates calculated from the actual `asOf`. The current work and finance paragraphs must not simply be pasted together. Monthly predictions, favorable/caution months and hardcoded example dates are prohibited.

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

Unknown birth time must remain fail-closed. It must not receive Known ascendant, houses, time-dependent claims or Known-only infographic content. Candidate 0024 does not authorize any Unknown copy or runtime change.

## Acceptance sequence

Candidate 0024 is a content proposal only. Engineering validation may check boundaries, mappings and negative controls, but it cannot declare the prose good or accepted. No exact SHA/golden, runtime implementation, visual artifact regeneration, merge or deployment is allowed until Owner has read and accepted the full candidate.
