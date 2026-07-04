# Thai Canon Evidence Mapping Precision Pass

> **Scope:** Mapping precision + classification quality only — no engine, copy, Canon data, or public UI changes.
>
> **Prerequisites:** Alignment QA `9645d86` · Review Panel · Report Evidence Upgrade

Status: **COMPLETE**

---

## 1 · What changed

| Change | Before | After |
|---|---|---|
| Myanmar / Lagna signals | `UNMAPPED_SIGNAL` (mapping failure) | `OUT_OF_CANON_SCOPE` |
| `mahabhuta_thaya` | `UNMAPPED_SIGNAL` | `OUT_OF_CANON_SCOPE` (no inferred khumsap map) |
| Bulk prediction rules | Section attachment (`RELATED_BUT_WEAK`) | Trace-only candidate |
| Planet attribute-only refs | Could attach to sections | Trace-only (owns-only attachments) |
| Lookup tables | Count implicit | Explicit skip count (55 units) |
| Trace model | Single unmapped list | Split: out-of-scope / in-scope / trace-only |

New code: `ThaiCanonEvidenceSignalScope` — deterministic scope rules without Canon mutation.

---

## 2 · Signals now OUT_OF_CANON_SCOPE

Not mapping failures — valid Thai report output outside frozen Mahabhut Canon:

| Signal family | Example keys | Reason |
|---|---|---|
| Myanmar seven | `myanmar_seven_1` … `_7` | Not in Mahabhut Canon vocabulary |
| Lagna sign | `lagna_cancer`, `lagna_libra`, … | Not in Mahabhut Canon vocabulary |
| Runtime thaya | `mahabhuta_thaya`, `profile:mahabhuta_position:mahabhuta_thaya` | See §3 |

**Count (9 fixtures):** 99 `OUT_OF_CANON_SCOPE` records (was 99 `UNMAPPED_SIGNAL`).

---

## 3 · mahabhuta_thaya decision

**Not mapped.**

| Runtime | Canon |
|---|---|
| `mahabhuta_thaya` (ทายะ) — Myanmar-adapted content key | `mahabhutPosition.khumsap` (ขุมทรัพย์) — distinct Canon entity |

Frozen Canon lists seven named positions; six map deterministically to runtime keys (`thongchai`, `adhibodi`, `marana`, `puti`, `rachiya`, `pyadhi` ↔ `phangkha`). **`thaya` and `khumsap` are not proven 1:1** — equivalence is not inferred (no name-similarity mapping).

Classification: **`OUT_OF_CANON_SCOPE`** with explicit reason in audit records.

---

## 4 · Weak attachment changes

| Attachment type | Change |
|---|---|
| **Prediction rules** | Removed from `attachments`; moved to `traceOnlyEvidenceCandidates` (1 per fixture) |
| **Planet attribute-only** | Suppressed from sections; if only `attribute.*` refs exist → trace-only |
| **Planet owns** | Still attaches; classified `STRONG_MATCH` when subject matches lagna lord |

**RELATED_BUT_WEAK section attachments:** 0 (down from 9 — all were bulk prediction rules).

Trace `RELATED_BUT_WEAK` records: 9 (prediction trace-only classifications).

---

## 5 · Updated coverage numbers (9 fixtures)

| Metric | Before precision pass | After |
|---|---:|---:|
| STRONG_MATCH | 177 | 177 |
| RELATED_BUT_WEAK (attachments) | 9 | 0 |
| RELATED_BUT_WEAK (trace records) | — | 9 |
| UNMAPPED_SIGNAL | 99 | **0** |
| OUT_OF_CANON_SCOPE | — | **99** |
| Trace-only candidates | — | **9** |
| In-scope unmapped | — | **0** |
| Attachments (qa_sample) | 30 | 29 |
| Skipped lookup tables | implicit | 55 × 9 fixtures |
| Thai validation tests | 338 | **351** |

Public `userFacingFingerprint` unchanged.

---

## 6 · Remaining true mapping gaps

| Gap | Status |
|---|---|
| `mahabhutPosition.khumsap` | Canon entity; no runtime content key |
| `planet.ketu` | Canon entity; no LifePlanet runtime key |
| `taksaRole.*` | Canon present; no Taksa runtime keys |
| `periodStatus.*` | Canon present; no rise/fall runtime keys |
| Remedies (87 units) | Skipped by safety policy |
| Lookup tables (55 units) | Skipped — reference only |

These are **not** treated as report-signal mapping failures when the report signal itself is out of Canon scope.

---

## 7 · Audit report split

Alignment QA report now sections:

1. **Out of Canon scope** — Myanmar, Lagna, thaya
2. **True in-scope unmapped** — currently empty across fixtures
3. **Skipped by safety policy** — remedies + lookup tables
4. **Skipped due to missing runtime key** — Taksa + periodStatus
5. **Trace-only evidence candidates** — prediction bulk + attribute-only

---

## 8 · Recommended next phase

**Period Status Mapping**

Prediction-rule evidence is now correctly trace-only. The next deterministic gap is `periodStatus.*` runtime keys so period rise/fall Canon can attach to structural signals without broad prediction prose.

---

## 9 · Related documents

| Document | Role |
|---|---|
| [`THAI_CANON_EVIDENCE_ALIGNMENT_QA.md`](THAI_CANON_EVIDENCE_ALIGNMENT_QA.md) | Prior alignment audit |
| [`THAI_CANON_EVIDENCE_MAPPING_LAYER.md`](THAI_CANON_EVIDENCE_MAPPING_LAYER.md) | Ontology runtime map |
