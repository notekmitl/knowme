# Thai Astrology Documentation Audit — Canon V1 (Task 1)

> Read-only audit of **all** Thai-astrology documentation and knowledge data in
> the repo, performed before designing the Canonical Knowledge Architecture.
> Output: where Rules / Concepts / Formulas / Meanings / Interpretations /
> Exceptions / Conflicts live today, and where the new Canon layer plugs in.
> **No engine or document content was changed by the audit.**

Status: **CURRENT** · Companion to `THAI_ASTROLOGY_CANON_V1.md` · Decision **D-052**.

---

## Executive findings

1. **The knowledge platform (V1–V9) is architecture, not astrological prose.** It
   ships schemas, pipelines, admin tools and **empty corpora**. All 56 planet
   relationships are seeded from the **frozen engine matrix** with
   `source: "Unknown"`, `verified: false`. Evidence / research / sources files
   are empty.
2. **The richest astrological knowledge lives in calculation/validation docs**,
   not the knowledge layer: `THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md` (4-base
   formulas, boundaries, source hierarchy), implemented in
   `THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`, validated by
   `THAI_GOLDEN_CASE_EXPANSION_V1.md`, and interpretive scoring in
   `THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`.
3. **`หลักมหาภูต` / `ส. หยกฟ้า` does NOT yet appear anywhere** in docs, knowledge
   JSON, or code. Canon V1 therefore **registers it fresh** as the Tier-1
   canonical source; no prior provenance to migrate.
4. **A calculation source hierarchy already exists but was never bridged with the
   knowledge layer's `school` vocabulary.** Canon V1's Tier ladder unifies them.
5. **`bhava` (ภพ), weekday-lord, dignity, element, lagna sign meanings** are
   listed as *deferred* knowledge domains and are undocumented as sourced rules —
   future homes for Canon nodes.

---

## 1 · Document inventory (Thai astrology)

**Knowledge track (V1–V9)** — `THAI_KNOWLEDGE_FOUNDATION_V1` → `_IMPORTER_V2` →
`_RESEARCH_V3` → `_EVIDENCE_LINKING_V4` → `_WORKSPACE_V5` → `_ACQUISITION_V6` →
`THAI_SOURCE_COLLECTION_V7` → `THAI_CONSENSUS_ENGINE_V8` → `THAI_MATRIX_REVIEW_V9`.
*Architecture only; minimal domain prose.* (Note: knowledge **V9** =
`THAI_MATRIX_REVIEW_V9`; engine **V9** = `THAI_LIFE_TIMELINE_INTELLIGENCE_V9` —
distinct namespaces.)

**Calculation & validation** — `THAI_ASTROLOGY_DOMAIN_VALIDATION_V1`,
`THAI_FOUNDATION_ENGINE_V1_1_NOTES`, `THAI_GOLDEN_CASE_EXPANSION_V1`,
`THAI_LUNAR_CALENDAR_INFRASTRUCTURE_V1`, `THAI_LUNAR_DATASET_ACQUISITION_V1`,
`BIRTH_NORMALIZATION.md`.

**Engine reasoning stack** — `THAI_LIFE_TIMELINE_INTELLIGENCE_V9` (planet
bonds/elements/life-period), `…_PREDICTION_…_V10`, `…_DECISION_…_V11`,
`…_QUESTION_REASONING_…_V12`, `…_REASONING_RUNTIME_V13`, `…_SCENARIO_…_V14`,
`…_TRANSIT_…_V15`, `…_MIRROR_CONVERSATION_V16`.

**Product / mirror** — `THAI_MIRROR_SPECIFICATION_V1` (4 lenses: lagna,
lagnaLord, myanmarSeven, mahabhutaPosition), `THAI_MIRROR_UI_SPECIFICATION_V1`
(superseded), `THAI_RESEARCH.md`.

**Knowledge data assets** — `knowledge/planet_relationships/…knowme.json` (56
seeded, all Unknown/unverified); `evidence`, `research`, `sources` corpora all
**empty**.

---

## 2 · Where each knowledge type lives today

| Type | Location | Sourced? |
|------|----------|----------|
| **Formula** | `THAI_ASTROLOGY_DOMAIN_VALIDATION_V1` (4-base, weekday rotation, day boundary), `…_LIFE_TIMELINE_…_V9` (bond = `natural×2 + element`) | Cited to classical calc sources / KnowMe-composed |
| **Concept** | Element model (ไฟ/ดิน/ลม/น้ำ), 8-planet life cycle, Myanmar Seven, Mahabhuta positions | KnowMe-defined; partly cited |
| **Rule** | 56 planet relationships (friend/enemy/neutral) | **Unsourced** — engine seed only |
| **Meaning** | Lagna/lagna-lord/lens labels | Content layer, not docs |
| **Interpretation** | Period strength tiers, phase stages, transitions (`…_V9`) | KnowMe-composed over unsourced matrix |
| **Exception** | Intercalary เดือน 8 สองหน, sinsaehwang simplification, GC-02 col-5 (13 vs 12) | Documented as open/teaching notes |
| **Conflict** | See §4 | Mixed (resolved / deferred / unresolved) |

---

## 3 · Existing authority signals (pre-Canon)

| Mechanism | Doc | Rule |
|-----------|-----|------|
| **Calculation source hierarchy** | `THAI_ASTROLOGY_DOMAIN_VALIDATION_V1` §6.3 | พรหมชาติ > อ.สำราญ > หมอชิต lineage > มหาภูติ course > หลวงวิจิตร (context only) |
| **Lunar dataset tiers A–D** | `THAI_LUNAR_DATASET_ACQUISITION_V1` | Primary = เขษมบรรณกิจ; reject scrape / unlicensed / CNY boundary |
| **Within-source conflict** | `THAI_SOURCE_COLLECTION_V7` | Same source asserting a pair two ways = error |
| **Cross-source consensus** | `THAI_CONSENSUS_ENGINE_V8` | majority / split / disputed + confidence by source count |
| **Matrix-change proposals** | `THAI_MATRIX_REVIEW_V9` | Keep/Review/Replace; human-gated; never automatic |
| **Engine vs knowledge** | all knowledge docs | `PlanetRelationshipMatrix` frozen; knowledge mirrors it; `matrix_mismatch` = warning |

**Gap closed by Canon V1:** none of the above expresses a *single* authority
ladder where a designated **canonical interpretive book wins over supporting
texts**. The Tier ladder (Tier 0 engine → Tier 1 `หลักมหาภูต` → Tier 2 Thai
classical → Tier 3 research → Tier 4 internet) plus `CanonConflictResolver`
("Canon always wins") is that missing piece.

---

## 4 · Documented conflicts (state)

| Conflict | Status |
|----------|--------|
| Scalar mod-merge vs 4-row vertical sum | Resolved (V1.1 table standard) |
| 06:00 vs sunrise day boundary | Evolved → sunrise (D-036/D-042) |
| GC-02 column 5: arithmetic 13 vs พรหมชาติ 12 | Tests use 13 |
| เดือน 8 สองหน (intercalary) | **Open**, low confidence |
| Mahabhuta from 4-base vs กาลโยค layer | Deferred |
| **Planet relationship matrix values** | **Unresolved — no sources collected** |
| Row 4 (3–21) lookup semantics | Deferred to V1.1+ |
| School variants (4ฐาน/5ฐาน/9ฐาน) | Frozen 4ฐาน only for V1 |

These are exactly the subjects future Canon nodes (Tier 1, with evidence) are
meant to adjudicate — without ever editing the engine.

---

## 5 · Mapping to Canon V1

| Audit gap | Canon V1 home |
|-----------|---------------|
| Unsourced 56 relationships | `topic: planet_relationship` nodes; Canon `value` wins; supporting overruled |
| Deferred domains (element, dignity, weekday lord, bhava, lagna rules) | `topic:` namespaces in `canon.knowme.json` |
| `หลักมหาภูต` absent | Registered Tier-1 canonical source in `canon_sources.json` |
| Calc hierarchy not bridged with `school` | Unified by `KnowledgeTier` ladder |
| Whole-book extraction | `mahabhut.manifest.json` skeleton + `CanonBookManifest` (not extracted yet) |

**Nothing in this audit motivated an engine, runtime, mirror, fusion or matrix
change.** Canon V1 is purely additive on top of the V1–V9 knowledge platform.
