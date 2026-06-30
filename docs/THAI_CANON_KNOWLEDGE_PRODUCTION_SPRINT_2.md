# Thai Astrology Canon — Knowledge Production Sprint 2 (Status: RESOLVED — see Sprint 2A)

> **✅ RESOLVED (D-067):** The Ontology Gap below was closed by a vocabulary-only
> Ontology Expansion (the seven Mahabhut Named Positions are now ontology
> entities), after which the first real Canon batch was produced through the
> unchanged pipeline. See
> [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2A.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2A.md).
> The report below is retained as the original gap analysis.

> **Outcome:** Real production was attempted through the **existing, unchanged
> pipeline** (D-065 / D-066). The OCR working source (308 pages) is now available
> and loads correctly. Production is **blocked by a genuine Ontology Gap**: the
> book's central knowledge structure is built on a system of **named Thai
> positions** (`เรือนธงชัย`, `เรือนอธิบดี`, `เรือนขุมทรัพย์`, …) that the current
> Canon Ontology cannot represent. Per the production rule, the correct output is
> this **Ontology Gap Report**, not invented knowledge and not a platform
> redesign. **Canon coverage is unchanged (0 units) by design** — no facts were
> fabricated, inferred, or mapped using external knowledge.

Status: **CURRENT** · Knowledge production only · Engine + platform **frozen**
(D-065) · Knowledge Rule = *extraction allowed, generation forbidden* (D-066) ·
No code/runtime/engine/ontology change · No deploy.

Supersedes the *blocker* of `THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_1.md` (missing
source text): the source is now present; a **different** blocker (ontology
coverage) is now the gate.

---

## 1 · This sprint used only the existing platform

No new infrastructure, runtime, engine, Canon architecture, or ontology
architecture was introduced. The intended production pipeline was exercised as-is:

```
Working Source (D-064)  →  Authoring / Atomic (D-058/D-062)  →  Ontology (D-059)
  →  Workspace Validation (D-060)  →  Review  →  Canon Import  →  Canon DB
```

- **Working Source.** The OCR drop `page_001.txt … page_308.txt` loads through the
  existing `WorkingSourceFolder.loadTxt` (D-064 folder intake): **one file = one
  page, page number from filename, numeric order, verbatim** (UTF-8/EOL normalise
  only). Smoke-verified previously at **308 pages → refs 1…308** (commit
  `db0e3c5`). This sprint re-read representative pages (1, 50, 150, 220, …) for
  extraction.
- **Atomic model / Ontology / Workspace.** Inspected as the import path; see the
  gap below for why import cannot proceed faithfully yet.

---

## 2 · What the book actually asserts (the recurring structure)

`หลักมหาภูต` (ส. หยกฟ้า, `sourceId: mahabhut`, tier1_canon) is organised as a
series of chart archetypes (`ดวง…`). On almost every page the unit of knowledge
is the same shape:

> **planet** occupies a **named position** → the position fixes the planet's
> **strength** (`เข้มแข็ง` / `อ่อน`) → this **produces a life-domain effect**
> (education, career, family, …).

Faithful, verbatim-grounded examples (reference-only, page provenance):

| Page | Stated by the book (paraphrase of the *structure*, not a quote) |
| --- | --- |
| 220 | `ดาวพฤหัส(๕)` in **`เรือนธงชัย`** → Jupiter `เข้มแข็ง` → strong educational foundation; also `ดาวพฤหัส(๕)`+`ดาวอังคาร(๓)` in **`เรือนธงชัย`/`อธิบดี`** → very diligent |
| 220 | `ดาวพฤหัส(๕)` in **`เรือนขุมทรัพย์`** → stable, secure employment |
| 150 | `ดาวพฤหัส(๕)` in **`เรือนปูติ`** → Jupiter `กำลังอ่อน` → weak/erratic education |
| 50  | `ดาวพฤหัส(๕)` in **`เรือนอธิบดี`** → meets good, capable friends/teachers/supporters |

The number in parentheses is the book's planet index (`(๕)` = Jupiter, `(๓)` =
Mars), consistent with the standard Thai planet numbering.

---

## 3 · Blocker — Ontology Gap (primary, hard stop)

**The named positions are the book's core vocabulary, and they are not in the
ontology.** A corpus scan of the OCR (deterministic, terms only) surfaces a
recurring set of named `เรือน` positions, e.g.:

`เรือนธงชัย` · `เรือนอธิบดี` · `เรือนขุมทรัพย์` · `เรือนราชา` · `เรือนปูติ` ·
`เรือนมรณะ` · `เรือนภังคะ` · … (appearing across pages throughout the book —
e.g. 40, 50, 63, 65, 68, 93, 96, 102, 109, 126, 129, 136, 140, 145, 158, 167,
176, 188, 194, 196, 197, 203, 205, 206, 208, 212, 219, 220, 232, 241, 245, 248,
268, 272, 279, 281, 285, 286, 288, 291, …).

The current `CanonOntologyData` (D-059) seeds only:

- **planets** (9) — Jupiter/Mars/… are present and resolve cleanly;
- **houses 1–12** — *positional* only, aliases `ภพที่ N` / `เรือนที่ N`;
- **elements** (4) and **domains** (9: career, finance, learning, family, …).

The named positions are **not** the numbered bhāva (`ธงชัย`, `อธิบดี`,
`ขุมทรัพย์`, `ราชา`, `ภังคะ` have no number in the book and are not among the
twelve `ภพที่ N`), and they are **not** elements or domains. They are a distinct
**planetary-position / dignity class** specific to this canon.

Why this is a hard stop (not timidity):

- Representing them requires **new ontology entities** the platform does not have.
  Per D-059/D-065, ontology entities are **never auto-created during authoring** —
  a human decides.
- Guessing what each named position *means*, or mapping it onto `house.1…12` or a
  strength value, would require **external Thai-astrology knowledge** and
  **inference beyond the text** — both explicitly forbidden by the Knowledge Rule
  (D-066) and by this sprint's brief.
- Without these entities, the `subject → relation → object [+ condition]` of
  essentially every page cannot be expressed (the `object`/`condition` *is* a
  named position).

Per the brief: *"If the ontology is missing a required concept, produce an
Ontology Gap Report instead of inventing one."* This document is that report.

---

## 4 · Blocker — Source quality (secondary, per-page)

OCR fidelity is **inconsistent across pages**. Many pages (e.g. 150, 220) are
largely readable; others (e.g. 50) are heavily corrupted with broken glyphs and
noise lines (`P|`, `จ`, `ญู ญิ a ญูล …`, `สวน สีง สีง สืม`). On corrupted pages,
recovering the intended Thai would require **filling OCR mistakes from memory** —
explicitly forbidden. Those pages are **not** extractable faithfully and must be
re-OCR'd or human-transcribed before they enter production. This gap is
independent of, and secondary to, the ontology gap.

---

## 5 · What *is* ontology-clean today (and why it is deferred, not imported)

A thin subset is expressible with current entities — the book's planet→domain
**significator** claims, e.g. `ดาวพฤหัส ดาวแห่งการเรียน,การศึกษา` →
`jupiter --governs--> domain.learning` (p.220); `ดาวแห่งหน้าที่การงาน` →
`jupiter --governs--> domain.career` (p.220).

These are **deliberately not imported this sprint** because:

- In the book they are asserted **inside the named-position framework** (the
  significator is stated as part of "planet in position → effect"). Importing them
  stripped of that context would **misrepresent how the canon asserts them** and
  inflate coverage with a handful of generic, context-free claims.
- They should be produced **together** with the position system once the ontology
  can represent it, so each unit is faithful and reviewable against its page.

No partial/token import was made. Coverage stays honest at **0**.

---

## 6 · Recommended next step (human decision — Ontology Expansion)

This is the **only** unblock that respects the freeze. **Ontology Expansion is an
allowed, human-decided work category** (D-059 / D-065 category 2: *"only when
genuinely required by Canon extraction; human review decides; never auto-created
during authoring"*). The required decision:

1. **Confirm the entity class.** Add the book's named planetary-position system as
   first-class ontology entities (a new `OntologyCategory`, e.g. *position* /
   *dignity*, with the canonical set: `ธงชัย`, `อธิบดี`, `ขุมทรัพย์`, `ราชา`,
   `ปูติ`, `มรณะ`, `ภังคะ`, … as enumerated from the book — **not** from external
   sources). The *meaning* of each position stays Canon knowledge extracted from
   the book; the ontology holds only the controlled identifier + Thai aliases.
2. **Re-OCR / transcribe** the corrupted pages (§4) so every page is faithfully
   readable.
3. **Resume production** through the unchanged pipeline (§1). With the positions
   representable, each page yields atomic units `planet --located_in-->
   position [+ strength] --produces--> domain-effect`, every unit page-cited and
   reviewable.

This is an **ontology vocabulary** decision (which controlled identifiers exist),
**not** a platform redesign and **not** new knowledge — exactly the D-059/D-065
expansion path.

---

## 7 · Compliance

- **No invention / inference / interpretation / summarization / external
  knowledge.** Only the structure stated by the pages was recorded; blocked
  concepts were reported, not guessed.
- **No code, runtime, engine, Canon, or ontology change** this sprint. The
  ontology expansion in §6 is left for explicit human approval.
- **Pages never merged**; provenance is reference-only (page numbers); no
  copyrighted paragraphs stored.
- **Coverage unchanged (0 units)** — reported honestly, as a documented gap is a
  valid sprint deliverable (D-065).

---

## 8 · Related documents

- [`THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`](THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md)
  — D-065 production mode, D-066 Knowledge Rule, gap-report mechanism.
- [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_1.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_1.md)
  — the prior (missing-source) blocker, now resolved.
- [`THAI_CANON_WORKING_SOURCE_ADAPTER_V1.md`](THAI_CANON_WORKING_SOURCE_ADAPTER_V1.md)
  — D-064 working source + folder intake.
- [`THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md`](THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md),
  Canon Ontology V3 (`canon/ontology/`), Atomic Knowledge V2 (`canon/atomic/`).
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-059 (ontology), D-065/D-066.
