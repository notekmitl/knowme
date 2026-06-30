# Thai Astrology Canon — Knowledge Production Sprint 2A (Ontology Expansion + First Batch)

> **Outcome:** The Sprint 2 Ontology Gap is **RESOLVED** by a vocabulary-only
> **Ontology Expansion** (D-067): the book's **Mahabhut Named Positions** are now
> first-class ontology entities. Using the **unchanged** production pipeline, the
> **first real Canon knowledge** was produced — 7 page-cited atomic units from
> pages 50/150/220 — validated through the real platform. **Canon production
> coverage increased from 0** (Planet Library now covers Jupiter + Mars; Planet →
> Domain covers Jupiter). No meanings/interpretations were invented; extraction
> only (D-066).

Status: **CURRENT** · D-067 (Ontology Expansion) · Ontology-only platform change ·
Engine/Runtime/Workspace/Authoring/Atomic/Canon-DB **unchanged** · No deploy.

---

## 1 · Ontology Expansion (D-067) — vocabulary only

Per D-065 category 2 (Ontology Expansion, permitted only when Canon knowledge
cannot be represented) and the Sprint 2A brief, **`CanonOntology` was the only
thing extended.**

- **New category:** `OntologyCategory.mahabhutPosition` (appended; every existing
  category keeps its `wire` identifier; `other` stays the fallback).
- **New entities (7) — created because they are *required for Canon
  representation*** (the book expresses planetary placement through these named
  positions, so its statements cannot be represented without them). OCR frequency
  of `เรือน…` tokens is shown below only as **supporting evidence for
  prioritization — it is never the criterion for creating an entity** (revised in
  Sprint 2B):

| id | `canonicalName` (romanisation, *not* a translation) | aliases (from the text) | corpus freq (priority evidence only) |
| --- | --- | --- | --- |
| `mahabhutPosition.marana` | Marana | `มรณะ`, `เรือนมรณะ` | 74 |
| `mahabhutPosition.phangkha` | Phangkha | `ภังคะ`, `เรือนภังคะ` | 71 |
| `mahabhutPosition.khumsap` | Khumsap | `ขุมทรัพย์`, `เรือนขุมทรัพย์` | 58 |
| `mahabhutPosition.thongchai` | Thongchai | `ธงชัย`, `เรือนธงชัย` | 55 |
| `mahabhutPosition.athibodi` | Athibodi | `อธิบดี`, `เรือนอธิบดี` | 51 |
| `mahabhutPosition.racha` | Racha | `ราชา`, `เรือนราชา` | 50 |
| `mahabhutPosition.puti` | Puti | `ปูติ`, `เรือนปูติ` | 48 |

**What was NOT added (rules 3–5 of the brief):** no meanings, no interpretations,
no relationships, no strength polarity, no bhāva-number mapping, no external Thai
astrology terminology. Only identifiers, aliases and the category. The *meaning*
of each position remains Canon knowledge produced from the book under review.

**What was NOT touched:** Runtime, Workspace, Rule Engine, Authoring, Canon
Database, Atomic Knowledge, `PlanetRelationshipMatrix`. The atomic model already
represents a position via its existing `objectKind: other` escape hatch + the
ontology id, so **no atomic change was required**.

---

## 2 · Ontology validation

`CanonOntologyData.standard().validate()` is clean with the new entities. Tests
(`thai_canon_ontology_test.dart`, group *Mahabhut Named Positions*) assert:

- all 7 positions resolve from **both** surface forms (`เรือนธงชัย` and `ธงชัย`);
- exactly 7 positions, all with a valid id prefix;
- no alias collisions; no parents/descriptions/relationships introduced;
- existing identifiers still resolve (`ดาวพฤหัส`→`planet.jupiter`, `เรือนที่ 5`→
  `house.5`, `การศึกษา`→`domain.learning`).

Full canon suite: **174 tests green**; `flutter analyze` clean.

---

## 3 · First production batch (unchanged pipeline)

Produced **from** the source pages read this sprint (extraction only, D-066), each
unit a single fact with reference-only page provenance (D-057):

| id | fact | page | basis (stated by the page) |
| --- | --- | --- | --- |
| `…p220.jupiter_owns_learning` | `jupiter --owns--> domain.learning` | 220 | `ดาวพฤหัส…ดาวแห่งการเรียน,การศึกษา` |
| `…p220.jupiter_owns_career` | `jupiter --owns--> domain.career` | 220 | `ดาวพฤหัส…ดาวแห่งหน้าที่การงาน` |
| `…p220.jupiter_in_thongchai` | `jupiter --located_in--> thongchai` (strength high) | 220 | `…สถิตเรือนธงชัย … เข้มแข็ง` |
| `…p220.jupiter_in_khumsap` | `jupiter --located_in--> khumsap` (strength high) | 220 | `…เรือนขุมทรัพย์ … เข้มแข็ง` |
| `…p220.mars_in_athibodi` | `mars --located_in--> athibodi` | 220 | `…พฤหัส…และอังคาร…เรือนธงชัยและอธิบดีตามลำดับ` |
| `…p150.jupiter_in_puti` | `jupiter --located_in--> puti` (strength low) | 150 | `…สถิตเรือนปูติ … กำลังอ่อน` |
| `…p50.jupiter_in_athibodi` | `jupiter --located_in--> athibodi` | 50 | `…สถิตเรือนอธิบดี` |

`เข้มแข็ง → strength.high`, `อ่อน → strength.low` are direct lexical readings, not
interpretation. The batch is recorded in
[`knowledge/canon/production/foundation_v1.knowme.json`](../knowledge/canon/production/foundation_v1.knowme.json)
and validated through the **real** platform by
`test/validation/thai/thai_canon_production_sprint2_test.dart`:

- every subject/object resolves to a canonical ontology entity;
- every unit passes `AtomicExtractionRules.validateAll` (atomic + traceable);
- `KnowledgeProductionReport.build` rises from **0 → 7 units**; Planet Library
  `subjectsCovered = 2/9` (Jupiter, Mars); Planet → Domain `produced = 2`
  (Jupiter → learning, career); deterministic.

---

## 4 · Status of continued production

The pipeline is **unblocked and working**; representable pages now flow end-to-end.
Faithful extraction of all 308 OCR pages is **incremental, reviewed work** done in
batches (each page read carefully; OCR-corrupted pages, see Sprint 2 §4, are
skipped for re-OCR — never guessed). This sprint delivered the **first** batch and
the proof that coverage increases deterministically. No new Ontology Gap or
Knowledge Modeling Gap was encountered for the pages processed; the next batches
continue through the same unchanged pipeline.

> **Watch item (not a blocker):** the book is organised as archetype example-charts
> (`ดวง…`). Units are cited per page exactly as stated, so they remain faithful and
> traceable. If a later page asserts something the atomic model cannot express
> without interpretation, that is a **Knowledge Modeling Gap** → stop and report
> (per D-065), not redesign.

---

## 5 · Compliance

- **Extraction, not generation (D-066).** Only facts stated on a page were
  recorded; no hallucination, inference, interpretation, summarization or external
  knowledge.
- **Ontology vocabulary only (D-067).** No meaning/relationship encoded; no
  Runtime/Workspace/Authoring/Atomic/Canon-DB/engine change; existing ids
  preserved; no deploy.
- **Reference-only provenance (D-057);** pages never merged; no copyrighted prose
  stored.
- **Validated before claiming:** 174 canon tests green, analyze clean, coverage
  report deterministic.

---

## 6 · Related documents

- [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2.md) — the Ontology Gap this resolves.
- [`THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`](THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md) — D-065/D-066 pipeline + rules.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-067.
- Canon Ontology V3 (`canon/ontology/`), Atomic Knowledge V2 (`canon/atomic/`), Knowledge Production V1 (`canon/production/`).
