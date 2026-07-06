# Thai Internal Evidence Mapping Refresh

**Phase:** Internal Evidence Mapping Refresh  
**Date:** July 2026  
**Prerequisite commits:** `654133c` (Taksa Rotation Mapping Freeze), `5da1faa` (Khumsap Runtime Mapping)  
**Validation artifact:** `tool/output/thai_internal_evidence_qa_summary.json`

---

## Why this refresh

After Taksa rotation mapping (Monday + Tuesday) and Khumsap internal runtime mapping (`mahabhuta_khumsap`), the internal evidence stack needed a deterministic re-audit across the existing 9-fixture harness. This refresh recalculates mapping coverage, badge counts, trace summaries, and QA aggregates — **no engine, Canon, or public output changes**.

---

## Post-refresh Canon state

| Metric | Value |
|--------|------:|
| Canon atomic units | **834** |
| Mahabhut positions mapped | **7 / 7** |
| Taksa roles mapped | **8 / 8** |
| Period status mapped | **2 / 2** |
| Planets mapped | **8 / 9** (`planet.ketu` unmapped) |

---

## Mapping coverage table

| Domain | Coverage | Notes |
|--------|----------|-------|
| Mahabhut positions | **7 / 7** | Khumsap via internal `mahabhuta_khumsap` |
| Khumsap internal key | **Mapped** | `mahabhutPosition.khumsap` ↔ `mahabhuta_khumsap` |
| `mahabhuta_thaya` | **OUT_OF_CANON_SCOPE** | Not equivalent to Khumsap |
| Taksa roles | **8 / 8** | Internal metadata keys |
| Taksa rotation weekdays | **Monday (2), Tuesday (3)** | Source-backed only |
| Sunday | **Partial review** | `TAKSA_ROTATION_PARTIAL_SOURCE_REVIEW_REQUIRED` |
| Wed daytime / Wed night·Rahu | **NOT_IN_SOURCE** | Separate cases, not merged |
| Thu–Sat | **NOT_IN_SOURCE** | Not inferred |
| Remedies | **87 units / fixture** | Internal/hidden only |
| Lookup tables | **56 units** | Reference-only |
| Archetype charts (ontology) | **7 entities** | Canon vocabulary |
| Rotation index (ontology) | **7 entities** | Canon vocabulary |

---

## Evidence attachment summary (9 fixtures)

| Metric | Aggregate |
|--------|----------:|
| Total attachments | **276** |
| Total evidence refs | **5,494** |
| Out-of-canon-scope signals | **99** |
| Trace-only candidates | **9** |
| Unmapped Canon candidates | **`planet.ketu` only** |

Khumsap no longer appears in unmapped Canon candidates.

---

## Badge summary (9 fixtures)

| Badge | Count |
|-------|------:|
| `CANON_SUPPORTED` | 177 |
| `RUNTIME_METADATA_SUPPORTED` | 65 |
| `CANON_DERIVED_INTERNAL` | 10 |
| `OUT_OF_CANON_SCOPE` | 99 |
| `BLOCKED_AMBIGUOUS` | 36 |
| `BLOCKED_SOURCE_CONFLICT` | 12 |
| `INTERNAL_ONLY` | 24 |
| `PARTIAL_CANON_SUPPORT` | 9 |
| `REMEDY_HIDDEN` | 9 |
| `NO_CANON_EVIDENCE` | 0 |

| QA check | Result |
|----------|--------|
| Badge mismatches | **0** |
| Provenance gaps | **0** |
| Weak → CANON_SUPPORTED promotion | **0** |

---

## Taksa refresh summary

| Metric | Aggregate (9 fixtures) |
|--------|------------------------|
| Taksa evidence attached | **24** (Mon/Tue fixtures: `qa_sample`, `harness_b`, `harness_d`) |
| Taksa evidence trace-only | **921** |
| Supported weekdays | Monday, Tuesday |
| Sunday (`harness_g`) | Partial — 0 rotation attachments |
| Wed (`harness_e`) | `TAKSA_ROTATION_NOT_IN_SOURCE` |
| Sat / Fri / Thu / Sun (non-partial) | No inferred assignments |

Per-fixture Taksa/Khumsap breakdown is in `thai_internal_evidence_qa_summary.json` under `fixtures[].taksaKhumsap`.

---

## Khumsap refresh summary

| Metric | Value |
|--------|-------|
| Khumsap mapped | **true** (all 9 fixtures) |
| Internal runtime key | `mahabhuta_khumsap` |
| Khumsap Canon candidates | **43 units / fixture** |
| Khumsap evidence attached (placement-derived) | **112 aggregate** |
| Attached via `mahabhuta_thaya` | **0** (forbidden) |
| In unmapped candidates | **Removed** |

Khumsap attachments are from legitimate Mahabhut placement / life-period evidence paths — not from collapsing `mahabhuta_thaya`.

---

## Unmapped / out-of-scope summary

| Item | Status |
|------|--------|
| `planet.ketu` | Unmapped Canon candidate (engine silent) |
| `mahabhutPosition.khumsap` | **Mapped** — no longer unmapped |
| `mahabhuta_thaya` | **OUT_OF_CANON_SCOPE** on every fixture |
| Myanmar seven / Lagna sign | OUT_OF_CANON_SCOPE (unchanged) |

---

## Remedy safety summary

| Check | Result |
|-------|--------|
| Remedy attachments on report | **0** |
| Remedy `userFacingAllowed` rows | **0** |
| Skipped remedy count | **87 per fixture** (783 aggregate) |
| Remedy procedure in public copy | **None** |

---

## Remaining blockers (explicit, not hidden)

| Blocker | Count (aggregate) |
|---------|-------------------:|
| Ambiguous archetype+planet placement | **18** period anchors |
| Source-conflict period anchors | **3** |
| Unique conflicted pair | **1** (`archetypeChart.nakwichakan:planet.jupiter`) |
| Life periods without runtime status | **21** |
| Sunday Taksa rotation | Human review required (partial source) |

---

## Public isolation proof

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint()` unchanged before/after enrichment
- No review panel / badge imports on `thai_beta_report_page.dart` or `thai_mirror_result_page.dart`
- Consumer timeline copy has no `ดวงขึ้น` / `ดวงตก` labels
- All evidence `userFacingAllowed = false`
- `flutter test test/validation/thai/` → **667 / 667 pass**

---

## Validation

- `test/validation/thai/thai_internal_evidence_mapping_refresh_test.dart`
- `test/validation/thai/thai_internal_evidence_qa_pass_test.dart` (writes refreshed summary JSON)
- Existing Taksa / Khumsap mapping tests unchanged and green

---

## Recommended next phase

**Thai Canon Integration Freeze**

All seven Mahabhut positions, eight Taksa roles, and partial Taksa rotation (Mon+Tue) are now internally mapped and QA-refreshed. The next safe step is to freeze the integrated internal evidence baseline before any public disclosure or prediction integration.

---

## Related

- [`THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md`](THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md)
- [`THAI_TAKSA_ROTATION_MAPPING_FREEZE.md`](THAI_TAKSA_ROTATION_MAPPING_FREEZE.md)
- [`THAI_KHUMSAP_RUNTIME_MAPPING.md`](THAI_KHUMSAP_RUNTIME_MAPPING.md)
- [`THAI_INTERNAL_EVIDENCE_QA_PASS.md`](THAI_INTERNAL_EVIDENCE_QA_PASS.md)
