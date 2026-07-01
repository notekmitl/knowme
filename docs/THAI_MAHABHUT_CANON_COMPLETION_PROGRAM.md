# Mahabhut Canon Completion Program

> **Objective:** **Complete Mahabhut Canon** — process every representable knowledge
> domain in `หลักมหาภูต` (ส. หยกฟ้า) until the book is fully extracted or blocked
> only by genuine gaps or unrecoverable OCR.
>
> **Supersedes:** Foundation-only Production Charter (Volume 1 scope limit and
> production pause). Volume 1 baseline remains the starting dataset — see
> [`THAI_CANON_PRODUCTION_VOLUME_1_CLOSURE.md`](THAI_CANON_PRODUCTION_VOLUME_1_CLOSURE.md).

Status: **CURRENT (active program)** · Decision **D-073** · Platform frozen (D-065) ·
Knowledge Rule unchanged (D-066) · Dataset:
[`foundation_v1.knowme.json`](../knowledge/canon/production/foundation_v1.knowme.json)
(357 units at program start)

---

## 1 · Program objective

| Before (cancelled) | Now |
|---|---|
| Foundation-only charter | **Complete Mahabhut Canon** |
| Stop after each Production Batch | **Continue until complete** |
| Defer Taksa, life-period, remedies, lookup tables | **Process every representable domain** in phase order |
| Volume 1 pause after Batch 9 | **Production resumed** under this program |

**Final deliverable:** **Mahabhut Canon Complete** — all representable Canon
knowledge extracted, audited, and frozen (Phase I).

**Success metrics** (replace batch-only unit counting where reporting):

| Metric | Meaning |
|---|---|
| **Representable Canon Knowledge** | Atomic facts explicitly stated in the Canon, expressible with current model + ontology (after any approved expansion/modeling fix). |
| **Extracted Canon Knowledge** | Atomic facts recorded in the production dataset and validated. |
| **Completion ratio** | `Extracted ÷ Representable` — reported at phase boundaries and in Phase H. |

At program start: **357 / 362 = 98.6%** within the former Volume 1 representable
pool. The representable pool **expands** as phases C–G open new domains.

---

## 2 · Rules (unchanged)

| Rule | Policy |
|---|---|
| No hallucination | Facts must be stated on a specific page (D-066). |
| No external knowledge | No memory, internet, or inference beyond the text. |
| No interpretation | Verbatim extraction → atomic triples only. |
| Deterministic extraction | Same source → same units; reproducible validation. |
| Human review mandatory | Workspace review gate before Canon import (D-060). |
| Reference-only provenance | No stored prose (D-057). |
| Source-internal conflicts | Recorded faithfully; resolved downstream (D-071). |

**Platform constraints (unchanged):**

- Use the **existing** platform — Book → OCR → Working Source → extraction →
  Human Review → Workspace → Import.
- **Do not** redesign Platform, Runtime, or Canon architecture.
- **Ontology Expansion** — allowed **only** when genuinely required for Canon
  representation (D-065 cat. 2, D-067 criterion).
- **Knowledge Modeling changes** — allowed **only** when a **true Modeling Gap**
  is proven (documented gap report → human decision → minimal fix).

---

## 3 · Stop conditions (only these)

Production **continues** across batches and phases. **Stop only** for:

| Stop condition | Required output |
|---|---|
| **Genuine Ontology Gap** | Ontology Gap Report — vocabulary the Canon requires but ontology lacks; no auto-creation. |
| **Genuine Knowledge Modeling Gap** | Modeling Gap Report — Canon states fact but atomic model cannot represent it; propose minimal fix. |
| **Unrecoverable OCR** | OCR Block Report — page/line identified; manual recovery or source re-acquisition attempted before permanent block. |

**Not** stop conditions: batch boundaries, phase transitions, metric reporting,
source-internal contradictions, multi-evidence duplicates.

---

## 4 · Phase order

```text
Volume 1 baseline (357 units) — COMPLETE
        ↓
Phase C — Taksa
        ↓
Phase D — Life Period
        ↓
Phase E — Prediction Rules
        ↓
Phase F — Remedies
        ↓
Phase G — Lookup Tables
        ↓
Phase H — Final Audit
        ↓
Phase I — Mahabhut Canon Freeze
```

Phases are **sequential**. Within a phase, production runs **continuously** until
that domain's representable knowledge is processed or a genuine stop condition is
hit.

---

## 5 · Phase specifications

### Volume 1 baseline (starting point)

**Status:** Closed baseline — not re-opened as a phase.

| Delivered | Units (approx.) | Pages |
|---|---|---|
| General significations | 16 | p16, p28–29, p83, p220 |
| Natal archetype placements | 40 | 7 charts, natal sections |
| Planet library attributes | 301 | pp.30–37 |

**Carryover into program** (close during continuous production, not a separate phase):

| Item | Blocker | Target phase |
|---|---|---|
| Venus scalars p35 (color/taste/metal) | OCR | Early — before or during Phase C |
| Saturn gender p36 | OCR | Early |
| ดวงมนุษย์เจ้าสำราญ Sun seat p149 | Source forensics | Early |
| Commodity lists pp.30–36 | Ontology (`commodity`) | Resolve ontology when proven required |
| Physique `รูปพรรณสัณฐาน` | Modeling policy | Resolve when proven required |
| Planet symbols p37 | Ontology (`symbol`) | Resolve when proven required |
| p29 unparsed domain lines | Domain alias / compound policy | Early or Phase E |
| pp.17–18 ดวงขึ้น/ดวงตก | Modeling | Phase D or E |

---

### Phase C — Taksa

**Status:** **CLOSED** — see [`THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_C.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_C.md).

**Canon scope:** ทักษา dignity-role vocabulary and chart-scoped role assignments.

| Source (approx.) | Content |
|---|---|
| pp.39–41 | มหาทักษา rotation, role meanings (`หมายถึง…`), role→planet mappings |
| Life-period headers | Per-chart ทักษา role assignments (บริวาร/อายุ/เดช/ศรี/มูละ/อุตสาหะ) |

**Known prerequisites (from Sprint 2B):**

- **Ontology Gap:** ทักษา role entities (`บริวาร`, `อายุ`, `เดช`, `ศรี`, `มูละ`,
  `อุตสาหะ`, …) — expand **only** if required for representation.
- **Modeling:** `AtomicContext.type = taksa_chart` (D-068) exists; role-assignment
  relation pattern must be proven before bulk extraction.

**Phase C complete when:** all representable Taksa facts in the book are extracted
or blocked by a documented gap/OCR report.

---

### Phase D — Life Period

**Canon scope:** Per-archetype life-period readings — planet placements, dignity,
and stated effects scoped to life-period context.

| Source (approx.) | Content |
|---|---|
| pp.52–75 | ดวงกำพร้า life-period |
| pp.89–111 | ดวงนักภาษา life-period |
| pp.121–147 | ดวงนักบริหาร life-period |
| pp.157–179 | ดวงมนุษย์เจ้าสำราญ life-period |
| pp.188–217 | ดวงเศรษฐี life-period |
| pp.226–253 | ดวงนักวิชาการ life-period |
| pp.263–292 | ดวงมหาเศรษฐี life-period |

**Known prerequisites:**

- `AtomicContext.type = life_period` (D-068) reserved; life-period token vocabulary
  may require ontology expansion.
- Depends on Phase C Taksa vocabulary for role-scoped readings.

**Phase D complete when:** all seven archetype life-period sections are processed
for representable atomic facts.

---

### Phase E — Prediction Rules

**Canon scope:** Explicit weak/strong position rules and prediction criteria stated
in the Canon (not interpretive narrative).

| Source (approx.) | Content |
|---|---|
| pp.40–41 | Position-strength prediction rules |
| pp.17–18 | ดวงขึ้น / ดวงตก position-classification (if representable) |
| Per-chart sections | Stated prediction criteria where atomic (not narrative gloss) |

**Known prerequisites:**

- May require **rule** or **condition** entity modeling if atomic triples are
  insufficient — prove Modeling Gap before change.

**Phase E complete when:** all stated prediction/classification rules are extracted
or gap-documented.

---

### Phase F — Remedies

**Canon scope:** แก้ดวง / สะเดาะเคราะห์ — remedy procedures and prescriptions.

| Source (approx.) | Content |
|---|---|
| pp.293–308 | Remedy chapters |

**Known prerequisites:**

- Remedy vocabulary and procedure modeling likely required — prove gap before
  ontology/modeling change.

**Phase F complete when:** all representable remedy facts extracted or
gap-documented.

---

### Phase G — Lookup Tables

**Canon scope:** Reference tables and lookup data stated as atomic facts.

| Source (approx.) | Content |
|---|---|
| pp.19–27 | Chart lookup tables |
| p18 | Dasha age tables (if representable as atomic facts) |

**Known prerequisites:**

- Tables may require table-row modeling or discrete atomic row units — prove
  Modeling Gap before bulk import.

**Phase G complete when:** all representable table facts extracted or
gap-documented.

---

### Phase H — Final Audit

**Reporting only** — no production unless audit finds missed representable facts.

Deliverables:

- Total **Representable** vs **Extracted** Canon Knowledge (full book)
- Completion ratio (book-wide)
- Coverage by knowledge domain, planet, position, archetype, context, source page
- Deferred / OCR / Unknown / Ontology Gap / Modeling Gap inventory (final)
- Conflict and multi-evidence register

---

### Phase I — Mahabhut Canon Freeze

**Deliverable:** **Mahabhut Canon Complete**

- Production dataset frozen at final unit count
- `foundation_v1.knowme.json` (or successor complete dataset) marked **COMPLETE**
- Platform remains frozen; Canon content tier locked for Mahabhut
- Phase I doc records final metrics and freeze decision (D-074 expected)

---

## 6 · Production workflow

```text
Read phase scope pages
  → Identify representable atomic facts
  → [If Ontology Gap] → Gap Report → approved expansion → resume
  → [If Modeling Gap] → Gap Report → approved minimal fix → resume
  → [If OCR block] → OCR Report → recovery attempt → resume or document
  → Extract units (deterministic)
  → Human Review (mandatory)
  → Workspace validation → Import
  → Continue (do NOT stop for batch boundary)
  → Commit at meaningful milestone
```

**Meaningful milestones** (commit when reached):

- Ontology expansion approved and landed (ontology-only commit)
- Modeling fix approved and landed (minimal atomic/context commit)
- Phase completion (phase report + dataset + tests green)
- OCR recovery batch
- Final Audit (Phase H) and Freeze (Phase I)

Batch numbering may continue (Batch 10, 11, …) for traceability but **does not**
imply a production pause.

---

## 7 · Current state at program start

| Field | Value |
|---|---|
| Dataset | `foundation_v1.knowme.json` |
| Extracted units | **357** |
| Evidence pages | 42 of 308 |
| Validation gate | `thai_canon_production_sprint2_test.dart` |
| Next phase | **Phase C — Taksa** |
| Platform | Frozen (D-065) — bug fixes only |
| Policies | D-065–D-072 active; D-073 supersedes Foundation-only charter |

---

## 8 · Related documents

| Document | Role |
|---|---|
| [`THAI_CANON_PRODUCTION_VOLUME_1_CLOSURE.md`](THAI_CANON_PRODUCTION_VOLUME_1_CLOSURE.md) | Volume 1 baseline (historical starting point) |
| [`THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`](THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md) | Platform freeze + Knowledge Rule |
| [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md) | Original Taksa modeling gap analysis |
| [`DECISION_LOG.md`](DECISION_LOG.md) | D-073 program authorization |
