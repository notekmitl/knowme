# Thai Astrology Knowledge Foundation V1

> A **traceable evidence layer** over the frozen Thai engine. Every rule the
> engine relies on should have a knowledge record describing what it is, where
> it comes from, and how confident we are. V1 covers the **Planet Relationship**
> domain only.

Status: **CURRENT** · Architecture / knowledge only (no engine change, no deploy).
Decision Log **D-043**.

> **Evolved by [Knowledge Importer V2](THAI_KNOWLEDGE_IMPORTER_V2.md) (D-044):**
> the records described here are no longer built in Dart — they are now loaded
> from JSON (`knowledge/planet_relationships/`) by
> `PlanetRelationshipKnowledgeImporter`, and records gained `status` plus richer
> source fields. The V1 concepts (one traceable record per directed pair, no
> invented references, no engine change) are unchanged.

---

## Goal

Build a Thai Astrology Knowledge Base so that every rule used by the engine is
backed by an evidence record. This milestone **does not modify the engine** — the
`PlanetRelationshipMatrix` and `PlanetRelationshipEngine` remain frozen. It builds
the foundation that future engine decisions can rely on, and it surfaces the
honest provenance state of today's rules.

Non-goals for V1:

- No change to `PlanetRelationshipMatrix`, `PlanetRelationshipEngine`,
  Prediction, Timeline, Runtime or Consumer.
- No invented references. Undocumented rules are recorded as `Unknown`,
  `verified = false`.
- No deploy.

---

## Knowledge domains

The knowledge base is planned to cover six domains. V1 implements only the first.

| # | Domain | Status |
|---|--------|--------|
| 1 | **Planet Relationship** | **V1 — implemented** |
| 2 | Planet Element | Deferred |
| 3 | Planet Dignity | Deferred |
| 4 | Weekday Lords | Deferred |
| 5 | Life Period Ring | Deferred |
| 6 | Lagna Rules | Deferred |

---

## Package

```
lib/features/astrology/thai/knowledge/
└── planet_relationship_knowledge.dart
```

The package **imports** the frozen `PlanetRelationshipMatrix` (read-only) and
exposes:

| Type | Role |
|------|------|
| `PlanetRelationshipKnowledge` | Holder: all records + `recordFor(from, to)` + `coverage()`. |
| `PlanetRelationshipRecord` | One directed pair: `from`, `to`, `currentMatrixValue`, evidence + flattened accessors. |
| `PlanetRelationshipSource` | Source: `school`, `name`, `reference`, `page`. |
| `PlanetRelationshipSchool` | Enum: `thaiTraditional`, `vedic`, `knowmeCustom`, `unknown`. |
| `PlanetRelationshipEvidence` | `source` + `confidence` + `verified` + `notes`. |
| `PlanetRelationshipConfidence` | Enum: `high`, `medium`, `low`, `none`. |
| `PlanetRelationshipCoverageReport` | Friend / Enemy / Neutral / Verified / Unknown / Coverage %. |

### Record fields (per the V1 spec)

From planet · To planet · Current Matrix Value · Source School · Source Name ·
Reference · Page · Confidence · Verified · Notes.

---

## Design guarantees

- **Read-only over the frozen engine.** Each record's `currentMatrixValue` is
  read from `PlanetRelationshipMatrix.relation(from, to)` at build time, so the
  knowledge base **can never drift** from the engine's actual values.
- **No drift, no duplication of the rules.** The matrix stays the single source
  of the *values*; the knowledge base adds *provenance* on top.
- **No invented references.** Every V1 record uses
  `PlanetRelationshipEvidence.unverified` → source `Unknown`, confidence `none`,
  `verified = false`. A real Thai/Vedic source is attached later by adding an
  entry to the `_evidenceByPair` override map — which enriches the record only
  and never changes engine behaviour.
- **Self-pairs excluded.** The matrix returns `friend` for `from == to` via an
  identity guard; that is an engine rule, not an inter-planet relationship, so it
  is not given a record. The base covers the **8 × 7 = 56** directed pairs.

---

## Knowledge Coverage Report (V1)

Generated from the live frozen matrix via `PlanetRelationshipKnowledge.coverage()`:

| Metric | Value |
|--------|-------|
| Total relationships | 56 |
| Friend | 22 |
| Enemy | 16 |
| Neutral | 18 |
| Verified | 0 |
| Unknown | 56 |
| **Record coverage** | **100%** (every matrix relationship has a record) |
| **Verified coverage** | **0%** (no documented source yet) |

The 100% / 0% split is the point of V1: the matrix is **fully recorded** but
**entirely unsourced**. Closing the verified-coverage gap is future work, one
documented source at a time, with no engine change required.

---

## Validation

`test/validation/thai/thai_planet_relationship_knowledge_test.dart` proves:

1. Exactly one record per directed inter-planet pair (56), no duplicates.
2. Every frozen-matrix relationship has a record whose `currentMatrixValue`
   equals `PlanetRelationshipMatrix.relation(from, to)` (no drift).
3. Self-pairs have no record (identity guard).
4. The honest V1 state: every record `verified = false`, source `Unknown`,
   confidence `none`.
5. The coverage report matches the matrix: 22 / 16 / 18 friend / enemy / neutral,
   0 verified, 56 unknown.

---

## Future versions

- **V2+:** attach real, documented Thai/Vedic sources to relationship records
  (raising verified coverage), then implement the remaining domains (Element,
  Dignity, Weekday Lords, Life Period Ring, Lagna Rules) under the same
  read-only, no-drift, no-invented-references contract.

---

## Related documents

- [`DECISION_LOG.md`](DECISION_LOG.md) — **D-043** (this milestone), D-009 (V8 matrix).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — where the knowledge layer sits.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — package placement.
- [`ROADMAP.md`](ROADMAP.md) — knowledge-foundation track.
