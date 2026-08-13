# Thai Narrative V1.5 — root cause and product standard

Status: Draft; Owner Acceptance pending. V1.4 remains live in Production.

## Correctness gate

The rejected `knowme-thai-report (24).pdf` is 38,075 bytes, SHA-256
`6B8BCCBCD8FE18556A5C271225BD49ECB0665DEF76871D796CBEB1F7A9514589`,
and has seven pages. It represents `1982-06-06 00:03`, Chiang Mai provincial
capital (`18.7883, 98.9853`, `Asia/Bangkok`, UTC+7). The engine uses the Thai
astrological day Saturday `1982-06-05` and returns Aquarius `9°24′`. The earlier
accepted Aquarius `19°19′` result used `00:35`. The difference is legitimate
input variation; no astrology code or canonical fact was changed.

## Structural root cause

V1.4 assembled Core Reading, timeline, prediction windows and methodology as
independent narrative owners. Core repeated the lagna-lord strength/risk/action
in its opening, guidance and methodology. Prediction independently rendered all
four domains in all three horizons. Nearly every template also appended an
action. The export deduper only compared neighbouring/full paragraphs after
wording, so synonyms, repeated subphrases and the same domain conclusion under a
new time label survived.

The 300-profile audit checked exact normalised paragraphs inside Core Reading
and verified that complete reports differed across fixtures. The Python audit
mostly compared extracted lines with a character-similarity threshold. Neither
had a report-level canonical claim identity, cross-layer ownership, horizon
risk/action identity, distinctive-phrase counter or hedge-density gate.

## V1.5 architecture

- `ThaiBetaReportClaimLedger` owns canonical id, evidence, role, section,
  domain, horizon, expressed state and information-adding callback keys.
- Each forecast domain receives one deterministic primary horizon. The three
  windows first reserve their strongest unclaimed domain; the remaining domain
  goes to its strongest evidence window. Current describes active pressure,
  12-month copy a change/trigger, and the next phase direction/consequence.
- The opening synthesises lagna identity and lagna-lord mode into a tension,
  recognisable consequence and reason to continue.
- Each house domain contributes one chart-grounded synthesis, not a second
  generic instruction. Advice is prioritised in the ending.
- Methodology preserves traceability without repeating interpretive phrases.

## Audit calibration

The report audit checks exact sentences, the three rejected distinctive
phrases, pairwise high textual overlap and six hedge forms. Repeated technical
row scaffolding inside the compact appendix is reported but allowed as a
false-positive because it is labelled evidence, not a claim presented as new.
Canonical domain reuse and callback novelty are tested before wording, where
synonyms cannot evade the gate.

Do not merge or deploy until the owner has read the proposed PDFs and explicitly
accepted narrative quality.

## R3 correction after Owner rejection

`V1.5 R2 OWNER ACCEPTANCE REJECTED`. R2's fixed per-horizon/domain sentence table restored completeness but produced 60/84 exact-reused strong-claim instances (71.43%), or 36/66 (54.55%) after the explicitly justified 00:03 twin was removed. Matching evidence signatures were incorrectly treated as freshness exemptions.

R3 adds `ThaiBetaReportNarrativePlan`, which ranks typed forecast material across the whole report, selects at most two motifs, and generates one hook with a central tension, consequence and decision question. Forecast prose consumes that plan so current, 12-month and next-period copy answer different questions. Theme, risk boundary, evidence availability and life-period context—not random synonyms—create material variation.

Consumer prose must have zero rejected system-label hits, zero exact duplicate bodies within a report, zero callbacks without new-information delta and zero unsupported biography patterns. Past periods are reflective questions grounded in period/theme/domain metadata; they must not claim an event happened. Exact strong-claim reuse for materially different fixtures must be ≤25%, with the 00:03 pair documented explicitly and no domain-signature blanket exemption.
