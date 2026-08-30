# Thai Report Predictive Narrative V2 — Implementation Plan

สถานะ: **PLAN ONLY — NO IMPLEMENTATION IN PHASE 1**

OR1 gate: Owner ยอมรับ root cause แต่ปฏิเสธ Candidate 0003 Phase 2A ห้ามเริ่มจาก Candidate 0003 หรือ 0004 จน Owner ตัดสินตัวเลือก A/B/C ใน Owner Decisions และอนุมัติ event/timing rules ที่เกี่ยวข้อง

## Phase 2A — Freeze contract and tests

1. Owner reviews Golden as style target, Candidate 0003 audit, Candidate 0004 content target, Matrix, Gap Report, Narrative Contract, Capability Map, Evidence Contract, Timing Contract and Owner Decisions
2. Convert accepted contract clauses into failing structure and copy-role tests without changing expected astrology output
3. Add fixture separation gates for 00:03, 00:35 and Unknown
4. Add a coverage gate requiring every candidate prediction to resolve to a real evidence key or life-period fact
5. Add forbidden default phrase and question-form gates scoped to Prediction body

Exit: Owner selects product scope, accepts content architecture/test contract, and explicitly approves or rejects proposed astrology rules This Phase 1 OR1 Draft PR does not satisfy that acceptance by itself

## Phase 2B — Narrative architecture

1. Introduce one chronological narrative document plan before any surface projection
2. Assign one owner to each semantic claim: past, current, 12 months, next period, summary or methodology
3. Compose Prediction and Advice as separate typed fields
4. Replace reflection-question past blocks with evidence-bounded past statements
5. Move personality-heavy core content out of the main predictive flow while retaining required chart traceability in source detail
6. Remove duplicate current and next-life claims at the plan level rather than with final-string replacements

Exit: structured document passes chronology, ownership, role and dedupe tests

## Phase 2C — Evidence-capability decisions

### Past events

Do not implement G04 and G06–G09 until Owner approves a past-event evidence contract. The contract must define calculation source, event family, time range, strength, domain, traceability and Unknown behavior

### Within-year timing

Do not implement Golden early, middle or late buckets until a deterministic timing engine exposes bucket boundaries and evidence atoms. Annual Taksa and a single 12-month band are insufficient. Keep `monthlyTimelineAvailable=false`

Do not split the annual band into equal calendar thirds and do not create a fixture-specific timing branch

### Relationship status and specific event sources

Do not write partner-status branches, encounter channels, old-client returns, expense categories or invitation events unless the corresponding input or calculation is explicit and traceable

### Prohibited psychology

Do not migrate G05 or G10 into the astrology report. If needed, route that concern to a separately accepted psychological-report contract

## Phase 2D — Surface projection

1. Web reads the chronological document directly
2. Dedicated PDF and browser print reuse the same section list and role fields
3. Infographic projects only accepted 12-month summary fields and the same rolling date range
4. Unknown filters time-dependent atoms before composition, not after prose generation
5. One disclaimer and one source section are shared across surfaces

Exit: semantic parity passes with no unsupported addition, omission or certainty escalation

## Phase 2E — Validation

- Focused narrative contract tests
- Canonical 00:03 and 00:35 regressions
- Unknown fail-closed tests
- Past evidence coverage and negative tests
- 300-profile semantic, omission, addition, prediction/advice and traceability audit
- Full required Flutter suite and analyzer
- Web desktop/mobile, four infographic surfaces, Dedicated PDF and browser-print generation
- Every-page raster review for blank, clipping, overlap and overflow
- PreCommit, PostCommit and GitHub state checks

## Phase 2F — Owner review and release separation

Implementation opens as a separate Draft PR with fresh artifacts Owner acceptance, merge decision and Production deployment remain three separate decisions No Phase 1 evidence grants approval for implementation, merge or deploy

Candidate 0003 remains rejected Candidate 0004 is design evidence only and cannot seed expected-output tests until every mapped atom is approved and derivable

## Change boundary for the next PR

Expected code touchpoints may include the report-level narrative plan, past composer, export document planning and surface projections Tests must prove that engine, Canon, astrology calculations, asOf, Known/Unknown availability and product-acceptance artifacts remain unchanged unless Owner separately authorizes a new calculation contract
