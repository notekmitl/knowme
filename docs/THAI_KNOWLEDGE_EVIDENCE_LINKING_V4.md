# Thai Astrology Knowledge Evidence Linking V4

> Connect research evidence to knowledge records. A relationship/research record
> no longer owns citations directly — it references **Evidence IDs**. One
> evidence record can back many research records, and one research record can
> reference many evidence records.

Status: **CURRENT** · Architecture / knowledge only (no engine change, no deploy).
Decision Log **D-046**. Builds on Research Infrastructure **V3** (D-045).

---

## Goal

Remove duplicated bibliographic data from research records and make sources
**first-class, citable, de-duplicated entities** that research links to by id.

Non-goals: no engine/matrix change, no deploy, no invented references.

---

## Architecture

```
knowledge/evidence/
├── evidence.schema.json     # JSON-Schema contract for evidence records
└── evidence.template.json   # blank shape for one citable source

lib/features/astrology/thai/knowledge/evidence/
├── evidence_record.dart            # EvidenceRecord + EvidenceReviewStatus
└── knowledge_evidence_engine.dart  # load / find / coverage / orphans / validation
```

`knowledge/evidence/` is a registered Flutter asset. The research schema/template
were updated to the new model (no source fields; `evidenceIds[]`).

---

## EvidenceRecord

`id` · `sourceType` · `school` · `author` · `book` · `edition` · `publisher` ·
`year` · `page` · `language` · `quote` · `summary` · `url` · `license` ·
`reviewStatus` · `reviewer` · `createdAt` · `updatedAt` · `notes`.

**Review status:** `draft` · `reviewed` · `verified` · `disputed` · `deprecated`.

## KnowledgeResearchRecord (modified)

The bibliographic source fields (`school`, `author`, `book`, `edition`,
`publisher`, `year`, `page`, `language`, `quote`) were **removed** and replaced
with `evidenceIds: List<String>`. It keeps `id`, `topic`, `entity`,
`interpretation`, `relationship[]`, `confidence`, `reviewedBy`, `status`,
`notes`.

```
ResearchRecord ──evidenceIds──▶ EvidenceRecord
   (many)                          (many)
```

---

## KnowledgeEvidenceEngine

| Function | Returns |
|----------|---------|
| `loadEvidence(json)` | `List<EvidenceRecord>` (malformed skipped) |
| `load(evidenceJson, researchJson)` / `loadFromAssets()` | a linked engine |
| `findEvidence(id)` | `EvidenceRecord?` |
| `findResearch(evidenceId)` | research records referencing it |
| `findRelationships(evidenceId)` | distinct relationships backed by it |
| `findOrphans()` | evidence referenced by no research |
| `coverage()` | `EvidenceCoverageReport` |
| `validate()` | `EvidenceValidationResult` |
| `groupEvidenceBySchool/ByAuthor/BySource()` | grouping for the workspace |

### Validation

| Detect | Code | Severity |
|--------|------|----------|
| Duplicate evidence ids | `duplicate_evidence` | error |
| Research → missing evidence | `broken_link` | error |
| Research with no evidence | `missing_evidence` | warning |
| Unused (orphan) evidence | `unused_evidence` | warning |
| Circular reference | `circular_reference` | error |

The reference graph (research → evidence) is bipartite and acyclic by
construction, so `circular_reference` does not fire for valid data; the check
exists defensively and is implemented as a real DFS cycle detector.

---

## Evidence Coverage Report

`Evidence count` · `Referenced evidence` · `Orphan evidence` ·
`Relationships supported` · `Research records supported`.

**Baseline (no evidence/research collected yet):**

```
Knowledge Evidence — Coverage Report
Evidence count            : 0
Referenced evidence       : 0
Orphan evidence           : 0
Relationships supported   : 0
Research records supported: 0
```

---

## Validation tests

- `test/validation/thai/thai_knowledge_evidence_linking_test.dart` — load,
  `findEvidence`/`findResearch`/`findRelationships`/`findOrphans`, coverage, and
  each validation class (duplicate, broken link, missing, unused), plus the
  templates linking cleanly and a decoupling guard (no engine/matrix/runtime/
  prediction imports).
- `test/validation/thai/thai_knowledge_research_test.dart` — updated to the
  evidence-linked research model.

---

## Related documents

- [`THAI_KNOWLEDGE_RESEARCH_V3.md`](THAI_KNOWLEDGE_RESEARCH_V3.md) — research layer.
- [`THAI_KNOWLEDGE_IMPORTER_V2.md`](THAI_KNOWLEDGE_IMPORTER_V2.md) · [`THAI_KNOWLEDGE_FOUNDATION_V1.md`](THAI_KNOWLEDGE_FOUNDATION_V1.md).
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-046 (this), D-045, D-044, D-043.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) · [`ROADMAP.md`](ROADMAP.md).
