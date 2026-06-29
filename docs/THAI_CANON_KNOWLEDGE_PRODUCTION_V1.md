# KnowMe Canon Platform — Knowledge Production V1

> The Canon Platform **Foundation is COMPLETE** (D-052 … D-060). This milestone
> shifts from *building the platform* to *producing Canon knowledge*. No new
> platform infrastructure was added except a Canon-compatible inconsistency fix
> and the structural ontology the V1 scope requires.

Status: **CURRENT** · Decision Log **D-061** · Content production · Engine frozen
· No deploy · No UI.

Modules: `lib/features/astrology/thai/knowledge/canon/production/` (content-tier
report), plus ontology expansion in `canon/ontology/`.

---

## Honest production state (the headline)

**No Canon facts were produced**, because the canonical source text
`หลักมหาภูต (ส. หยกฟ้า)` is **not present in the repository** (only the empty drop
folder `knowledge/canon/sources/mahabhut/README.md` exists). The Canon rules —
restated in the V1 prompt — are absolute:

> "No speculative astrology. If a fact cannot be supported from the Canon book,
> do not invent it. Leave it Unknown." · "ห้ามสร้างข้อมูลจากความจำ / ห้ามเดา /
> ห้ามใช้อินเทอร์เน็ต."

Therefore planet/house meanings, keywords, domains and elements were **left
Unknown**. Fabricating them from memory or the internet would be the single
biggest violation of the project's core principle, so it was not done.

What V1 *does* deliver is everything that can be produced **without** inventing
astrology: the structural vocabulary the six domains need, the deterministic
production pipeline + report that turns Canon-sourced units into a measurable
knowledge base, full validation, and a one-step unblock.

## What was delivered

### 1 · Ontology expansion (structural vocabulary only)

- Seeded the **12 houses** (`house.1` … `house.12`) — a structural enumeration
  like the existing 9 grahas / 12 signs. House *meanings* are NOT encoded (they
  are Canon knowledge from the book).
- Added vocabulary categories `meaning`, `role`, `keyword` to `OntologyCategory`
  so the V1 entity ids (`meaning.*`, `role.*`, `keyword.*`) have a home. No
  specific meaning/role/keyword entities were seeded (content-dependent).

### 2 · Canon-compatible inconsistency fix

`AtomicEntityKind` lacked `element`, `keyword` and `role`, yet the V1 scope needs
Planet→Element / Planet→Keywords (and `role.teacher`). Added those kinds to the
atomic vocabulary (additive, Canon-compatible) so units can be typed precisely.

### 3 · Knowledge Production tracker — `canon_knowledge_production.dart`

`KnowledgeProductionReport.build(importedUnits, ontology)` is a deterministic,
content-tier aggregator over the frozen atomic + ontology + completeness layers.
It tracks the **six V1 domains** (Planet Library, House Library, Planet→Natural
Meaning, Planet→Keywords, Planet→Domain, Planet→Element) and reports, per domain:
produced / verified / subjects-covered / coverage / status
(`unknown`/`partial`/`complete`), plus all-atomic, provenance completeness, the
`CanonCompletenessReport`, and the ontology scaffolding (planets=9, houses=12). It
creates no knowledge of its own. With the current empty import, **every domain is
Unknown** — the truthful state.

### 4 · The (empty) knowledge dataset

`knowledge/canon/production/foundation_v1.knowme.json` declares the six domains
with `status: unknown` and empty unit lists, documenting the reference-only
provenance policy and the source-absent reason. It is the drop target for
produced knowledge; it is not loaded at runtime.

## How the deliverable reports read today

All generated from the current (empty) production run — deterministic:

| Report | Current value |
| --- | --- |
| Canon Completeness Report | 0 units; every domain 0% (Planet Relationships 0/72; Evidence 0%) |
| Knowledge Production Report | 6 domains all `unknown`; produced 0; scaffolding planets=9, houses=12 |
| Coverage Report | knowledge-domain coverage 0% across all V1 domains |
| Import Report | 0 units imported (no session has reached `Imported`) |
| Review Report | n/a — no session has units to review |

## The one-step unblock

1. Drop chapter transcriptions into `knowledge/canon/sources/mahabhut/`
   (see that folder's README and `THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md`).
2. For each page, run the **Knowledge Extraction Workspace** (`canon/workspace/`):
   Extraction Session → Validation → Diff → Review → Canon Import. Each fact
   becomes one Atomic Knowledge Unit; subjects/objects/relations must resolve
   through the Canonical Ontology (add missing ontology entries *first*).
3. `KnowledgeProductionReport` then shows coverage rising deterministically.

No bypass: knowledge enters only through the workspace, with provenance by
reference and no stored prose.

## Validation (tests)

`test/validation/thai/thai_canon_production_test.dart` (11 tests): the real
knowledge base is empty (source absent → all-Unknown but valid); and with
fixtures (not Canon content) — every imported fact is atomic, every entity
resolves in the ontology, every relationship is registered, no duplicated
knowledge, provenance present for every fact, completeness increases
deterministically, correct domain classification; the 12 houses are seeded and
the ontology stays valid; new categories available; and decoupling (no engine/
runtime/matrix/mirror/fusion/narrative/flutter imports). Full canon suite (120
tests) green; `flutter analyze` clean.

## Constraints honoured

- No runtime/engine/matrix changes, no UI, no deploy, **no speculative
  astrology**. Unsupported facts left Unknown.
- No new platform infrastructure beyond the structural ontology + the Canon-
  compatible `AtomicEntityKind` fix + a content-tier report aggregator.
- Provenance reference-only (D-057); no copyrighted paragraphs or prose stored.
