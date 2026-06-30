# KnowMe Canon Platform — Production Mode (Platform Freeze Ratified)

> **Effective immediately:** the Canon Platform is **COMPLETE**. This milestone
> ratifies the transition from **Platform Development** to **Knowledge
> Production**. No new platform layers, infrastructure or framework abstractions
> may be introduced unless a real inconsistency is proven or Canon knowledge
> cannot be represented by the existing model.

Status: **CURRENT** · Decision Log **D-065** (Knowledge Rule clarified by
**D-066**) · Platform **FROZEN** · Production mode active · Engine frozen · No
deploy unless requested.

> **Knowledge Rule clarification (D-066):** **Extraction is allowed; generation
> is forbidden.** AI may perform *deterministic information extraction FROM* the
> Canon source text; it may never invent, infer beyond the text, interpret,
> summarize, or import external knowledge. See the **Knowledge rule** section.

Supersedes the *scope* of D-056 (Canon Platform Freeze V1) for future work
classification — the architecture named there is now the **only supported
production workflow**, extended through D-064.

---

## Official Canon pipeline (the only supported production workflow)

```
Book
  ↓
OCR
  ↓
Working Source
  ↓
AI-assisted Atomic Knowledge Extraction   (extract FROM the page; never generate)
  ↓
Human Review
  ↓
Ontology Resolution
  ↓
Workspace Validation
  ↓
Review
  ↓
Canon Import
  ↓
Canon Database
  ↓
Rule Engine
  ↓
Reasoning
  ↓
Narrative
```

| Stage | Module | Role |
| --- | --- | --- |
| Working Source | `canon/working_source/` (D-064) | Temporary PDF/Image/OCR/TXT intake; **never Canon**; only book/edition/chapter/page survive |
| AI-assisted Atomic Knowledge Extraction | `canon/authoring/` (D-062) + `canon/atomic/` (D-058) | Deterministically extract the atomic facts **stated on the page** into draft Atomic Knowledge Units (one fact per unit). **Extraction only — never generation** (D-066) |
| Human Review | reviewer + `OntologyAssist` | Human confirms each draft unit is faithful to the page; resolves unknowns; nothing auto-created |
| Ontology Resolution | `canon/ontology/` (D-059) | Controlled vocabulary; alias resolution; never auto-create |
| Workspace Validation | `canon/workspace/` (D-060) | **Only supported ingestion path**; diff + completeness + review gate |
| Review | `ReviewReport` (workspace) | Human decision surface; conflicts left unresolved — never force agreement |
| Canon Import | workspace session → DB | Approved knowledge only |
| Canon Database | `canon/database/` | Persistent Canon store + index seam |
| Rule Engine → Reasoning → Narrative | frozen engine surfaces | Consume Canon-Approved knowledge downstream |

QA regression: `canon/golden/` (D-063) verifies the pipeline without touching
production knowledge.

---

## Future work — exactly four categories

All future Canon work must fall into **one** of these:

1. **Knowledge Production** — populate Canon from the official source (`หลักมหาภูต`
   and future books) through the pipeline above. **Primary success metric:**
   Knowledge Coverage increase.
2. **Ontology Expansion** — only when genuinely required by Canon extraction
   (new entity discovered in the book). Human review decides; never auto-created
   during authoring.
3. **Bug Fixes** — implementation inconsistencies only; must preserve Canon
   compatibility and frozen-layer behaviour.
4. **Performance** — without changing behaviour.

**Nothing else.** No new platform features, layers, schemas, workflows or
architecture experiments.

---

## Platform change policy

A new platform change is permitted **only** when:

- a **real implementation inconsistency** is proven (e.g. D-057 reference-only
  provenance), **or**
- **Canon knowledge cannot be represented** by the existing Atomic Knowledge
  model.

If neither condition exists, **do not extend the platform.**

Platform stability has higher priority than architectural elegance.

---

## Knowledge rule (non-negotiable) — Extraction allowed · Generation forbidden

The Canon policy does **not** forbid AI from extracting knowledge. It forbids AI
from *creating* knowledge. The single distinction (clarified D-066):

> **Extraction is allowed. Generation is forbidden.**
>
> An Atomic Knowledge Unit must be **extracted FROM the Canon source text** —
> every unit traces to a specific page. A unit must **never be invented,
> inferred, generalised or imagined.**

**Allowed (deterministic extraction from the source):**

- AI-assisted reading of the Working Source page text to identify the atomic
  facts **stated on that page** (entity → relation → object + condition / effect
  / strength / confidence).
- Resolving the surface terms found on the page to the Canonical Ontology.
- Restructuring a sentence into atomic triples **without adding meaning** (the
  same fact, decomposed — not paraphrased into new claims).

**Forbidden (generation / going beyond the text):**

- **Hallucination** — facts not present on the page.
- **Inference beyond the text** — conclusions the source does not state.
- **Interpretation** — reading meaning into the text.
- **Summarization** — compressing or paraphrasing prose into new wording.
- **External knowledge** — anything from memory, the internet or other books.

**Process invariants (unchanged):**

- Knowledge enters **only** through: Working Source → AI-assisted Atomic
  Knowledge Extraction → Human Review → Workspace Validation → Canon Import.
- Every extracted unit keeps **reference-only provenance** (book / edition /
  chapter / page); Working Source prose is **temporary** and is never promoted
  (D-057 / D-064).
- **Human Review is mandatory** before Workspace validation/import — the human
  confirms each extracted unit is faithful to the page (extraction, not
  generation). Conflicts are left unresolved, never forced.
- If a stated fact cannot be represented by the Atomic model, or an entity is
  missing from the ontology, produce a **gap report** (below) — never invent.

---

## Gap reports (instead of platform redesign)

When extraction cannot proceed without changing the frozen model, produce a
**documented gap** — not new framework code:

| Gap type | When | Action |
| --- | --- | --- |
| **Ontology Gap Report** | repeated Missing Ontology entities during extraction | collect entities; human decides whether to add to ontology |
| **Knowledge Modeling Gap Report** | a Canon statement cannot be represented as an Atomic Knowledge Unit | page + statement + why + suggested future modeling; human review decides |

See `THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_1.md` for the sprint-1 gap pattern.

---

## Deliverables going forward

The expected output of every future milestone is:

- **new verified Canon knowledge** (coverage increases deterministically), **or**
- **documented gaps** (ontology / modeling / source absence).

**Not** new framework code. Milestones are evaluated primarily by **Knowledge
Coverage increase**, not lines of code or number of new platform modules.

---

## Frozen surfaces (do not modify)

Atomic Knowledge · Ontology · Knowledge Graph · Workspace · Authoring Studio ·
Golden Dataset · Working Source (adapter only — no redesign) · Rule Engine ·
Prediction · Timeline · Decision · Runtime · Mirror · Conversation · Fusion ·
`PlanetRelationshipMatrix` · Swiss Ephemeris · calculation engine.

No runtime redesign. No engine redesign. No ontology redesign unless extraction
requires it. No workspace redesign. No deploy unless requested.

---

## Related documents

- `THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1.md` (D-056) — original freeze audit
- `THAI_CANON_WORKING_SOURCE_ADAPTER_V1.md` (D-064) — intake
- `THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md` (D-062) — authoring
- `THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md` (D-060) — ingestion gate
- `THAI_CANON_KNOWLEDGE_PRODUCTION_V1.md` (D-061) — production tracker
- `THAI_CANON_GOLDEN_DATASET_V1.md` (D-063) — regression suite
- `THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md` — operational runbook
- `THAI_MAHABHUT_CONTENT_ENGINEERING_V1.md` — reviewer workflow
