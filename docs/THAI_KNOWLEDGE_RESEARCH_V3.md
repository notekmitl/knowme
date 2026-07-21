# Thai Astrology Knowledge Research Infrastructure V3

> Prepare the platform for **real astrology research** — not software research,
> *knowledge* research. A place to collect primary-source evidence (books,
> authors, schools, quotes) that grounds the engine's rules, completely
> independent of the engine and the matrix.

Status: **CURRENT** · Architecture / knowledge only (no engine change, no deploy).
Decision Log **D-045**. Builds on Knowledge Importer **V2** (D-044).

> **Evolved by [Evidence Linking V4](THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md) (D-046):**
> research records no longer embed bibliographic fields — those moved to
> `EvidenceRecord` and a research record now references them via `evidenceIds[]`.
> The relationship/status/conflict concepts below are unchanged.

---

## Goal

Stand up the infrastructure to gather and audit scholarly references for Thai/
Vedic astrology — independent of any engine value — so that, over time, each
relationship the engine uses can be backed by documented sources.

This milestone delivers the **schema, template, model and research engine**. It
ships **no research data yet** (collecting real references is the ongoing work it
enables).

---

## Hard boundary — knowledge layer only

The research layer has **no dependency on the engine or `PlanetRelationshipMatrix`**:

- Planets and relations are recorded as **plain strings**, not engine enums.
- The source files import neither `core/life_period/*` nor
  `planet_relationship_matrix` nor `life_planet` (enforced by a test).
- The "relationship universe" (56 directed pairs) is sized from a layer-local
  planet-key list (`kKnowledgeResearchPlanets`), not from the matrix.

This keeps research collection and auditing fully decoupled: a researcher can
record what a source *says* without any engine value influencing it, which is
exactly what makes later cross-checking meaningful.

---

## Architecture

```
knowledge/research/
├── research.schema.json     # JSON-Schema contract for research records
└── research.template.json   # blank shape for documenting one source

lib/features/astrology/thai/knowledge/research/
├── knowledge_research_record.dart   # model + enums (self-contained)
└── knowledge_research_engine.dart   # load / group / evidence / conflicts / coverage
```

`knowledge/research/` is registered as a Flutter asset; a future
`research.knowme.json` can be loaded via
`KnowledgeResearchEngine.loadFromAsset()`.

---

## Research record

| Field | Notes |
|-------|-------|
| `id` | stable unique id (e.g. `RR-0001`) |
| `topic` | e.g. `planet_relationship` |
| `entity` | subject (e.g. `Saturn–Venus`) |
| `school` | tradition (free string: `thaiTraditional`, `vedic`, …) |
| `author`, `book`, `edition`, `publisher`, `year`, `page` | bibliographic source |
| `language` | `th` / `en` / `sa` / … |
| `quote` | short verbatim quote |
| `interpretation` | what the source says, in the researcher's words |
| `relationship` | **array** — one record may support **multiple** relationships (`{from,to,relation}`) |
| `confidence` | `none` · `low` · `medium` · `high` |
| `reviewedBy` | reviewer |
| `status` | `draft` · `candidate` · `reviewed` · `verified` · `disputed` · `rejected` |
| `notes` | free text |

**No invented references:** if a real source cannot be cited, no record is
created. Status is promoted only as the citation is checked.

---

## KnowledgeResearchEngine

| Function | Returns |
|----------|---------|
| `load(json)` / `loadFromAsset()` | an engine over the parsed corpus (malformed/invalid records are skipped, never thrown) |
| `groupBySource()` | `Map<book+edition, records>` |
| `groupBySchool()` | `Map<school, records>` |
| `findSupportingEvidence(from, to, {relation})` | records supporting a directed relationship |
| `findConflicts()` | directed pairs where records disagree on the relation (`ResearchConflict`) |
| `coverage()` | `ResearchCoverageReport` |

---

## Research Coverage Report

`ResearchCoverageReport.toReportLines()` reports: Books · Authors · Schools ·
Verified sources · Pending sources · Relationships supported · Relationships
without evidence (+ coverage %).

**Baseline (no research collected yet):**

```
Knowledge Research — Coverage Report
Total records                 : 0
Books                         : 0
Authors                       : 0
Schools                       : 0
Verified sources              : 0
Pending sources               : 0
Relationships supported       : 0 / 56
Relationships without evidence: 56
Relationship coverage         : 0.0%
```

This is the honest starting point: the infrastructure is ready and **all 56
directed relationships currently have no documented evidence**. Each verified
research record raises supported coverage.

---

## Validation tests

`test/validation/thai/thai_knowledge_research_test.dart`:

1. Loads records, including one record supporting **multiple** relationships.
2. Malformed JSON / missing required fields are skipped (never throws).
3. `groupBySource` / `groupBySchool` group correctly.
4. `findSupportingEvidence` matches by pair (and optional relation).
5. `findConflicts` detects a pair asserted as both `friend` and `enemy`.
6. `coverage` counts books/authors/schools/sources and computes
   supported vs. without-evidence against the 56-pair universe.
7. **Decoupling guard:** the research source files import neither the engine
   core, the matrix, nor `LifePlanet`.

---

## Workflow

1. Copy a record from `research.template.json` and fill it from a real source.
2. Add it to a research file (e.g. `research.knowme.json`); one record can list
   several `relationship` entries.
3. Promote `status` draft → candidate → reviewed → verified as the citation is
   checked; use `disputed` when sources conflict, `rejected` when a claim fails.
4. Run `coverage()` / `findConflicts()` to track progress and disagreements.

A later milestone can cross-reference this corpus against the frozen matrix /
Knowledge Importer V2 to propose verified updates — but that cross-reference is
deliberately **not** part of this layer.

---

## Related documents

- [`THAI_KNOWLEDGE_IMPORTER_V2.md`](THAI_KNOWLEDGE_IMPORTER_V2.md) — data-driven knowledge records.
- [`THAI_KNOWLEDGE_FOUNDATION_V1.md`](THAI_KNOWLEDGE_FOUNDATION_V1.md) — knowledge foundation + audit.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-045 (this), D-044, D-043.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) · [`ROADMAP.md`](ROADMAP.md).
