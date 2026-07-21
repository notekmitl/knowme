# Thai Astrology Knowledge Importer V2

> Move astrology knowledge **out of source code**. The Planet Relationship
> knowledge is now **data-driven**: JSON files validated and loaded by an
> importer into `PlanetRelationshipKnowledge`. No hardcoded records, no engine
> change.

Status: **CURRENT** · Architecture / knowledge only (no engine change, no deploy).
Decision Log **D-044**. Builds on Knowledge Foundation **V1** (D-043).

---

## Goal

Make the knowledge base data-driven so future engine decisions can rest on
editable, reviewable evidence rather than constants in `.dart` files. V2 builds
the **import pipeline** for the Planet Relationship domain.

Non-goals: no change to `PlanetRelationshipMatrix`, `PlanetRelationshipEngine`,
Prediction, Timeline, Runtime or Consumer. No invented references. No deploy.

---

## Architecture

```
knowledge/planet_relationships/
├── planet_relationships.schema.json     # JSON-Schema contract for the data
├── planet_relationships.knowme.json     # the canonical data (56 records)
└── planet_relationships.template.json   # blank shape for adding a sourced record

lib/features/astrology/thai/knowledge/
├── planet_relationship_knowledge.dart            # in-memory model + coverage (owns no data)
└── planet_relationship_knowledge_importer.dart   # JSON → PlanetRelationshipKnowledge + validation
```

The data directory `knowledge/planet_relationships/` is registered as a Flutter
asset (`pubspec.yaml`) so the app can load it at runtime via
`PlanetRelationshipKnowledgeImporter.loadFromAsset()`. Tests read the file
directly from disk.

---

## Record fields

Each relationship record supports:

`from` · `to` · `relation` · `school` · `source` · `author` · `edition` ·
`publisher` · `year` · `reference` · `page` · `quote` · `confidence` ·
`status` · `verified` · `notes`.

| Enum | Values |
|------|--------|
| `relation` | `friend` · `neutral` · `enemy` |
| `school` | `thaiTraditional` · `vedic` · `knowmeCustom` · `unknown` |
| `confidence` | `none` · `low` · `medium` · `high` |
| `status` | `unknown` · `candidate` · `verified` · `disputed` · `deprecated` |

**No invented references:** where a source is undocumented, `source`/`reference`
are `Unknown`, the optional fields are `null`, `school = unknown`,
`confidence = none`, `status = unknown`, `verified = false`.

---

## Importer

`PlanetRelationshipKnowledgeImporter`:

- `importJson(String)` / `importMap(Map)` → `PlanetRelationshipImportResult`
  (`knowledge`, `issues`, `coverage`, `ok`, `toReportLines()`).
- `loadFromAsset({AssetBundle? bundle})` → loads the canonical asset.

### Validation

| Check | Code | Severity |
|-------|------|----------|
| Shape / types / valid JSON | `schema` | error |
| Missing required field | `missing_field` | error |
| Unknown enum value (planet/relation/school/confidence/status) | `unknown_enum` | error |
| Duplicate `(from,to)` | `duplicate` | error |
| Self-pair or invalid planet | `broken_reference` | error |
| Relation disagrees with the frozen matrix | `matrix_mismatch` | warning |
| A directed pair is absent | `missing_coverage` | warning |

`matrix_mismatch` is a **warning** (not an error): the knowledge layer must
never silently diverge from the frozen engine, but the JSON is allowed to be
edited and reviewed before the matrix would (separately) be reconsidered.

---

## Knowledge Import Report (canonical data, V2)

Produced by `PlanetRelationshipImportResult.toReportLines()` on
`planet_relationships.knowme.json`:

```
Planet Relationship Knowledge — Import Report
Status            : OK
Records imported  : 56
Errors            : 0
Warnings          : 0

Planet Relationship Knowledge — Coverage Report
Total relationships : 56
Friend              : 22
Enemy               : 16
Neutral             : 18
Unknown (status)    : 56
Candidate           : 0
Verified            : 0
Disputed            : 0
Deprecated          : 0
Coverage %          : 0.0%
```

The canonical data imports cleanly (no errors, no matrix mismatches), fully
covers the 56 directed inter-planet pairs, and honestly reports **0% verified
coverage** — every relation is seeded from the frozen matrix and awaits a
documented source.

---

## Validation tests

`test/validation/thai/thai_planet_relationship_knowledge_test.dart`:

1. Canonical data imports with **no errors and no warnings**.
2. Covers exactly the 56 directed pairs (no duplicates, no self-pairs).
3. Every imported relation equals `PlanetRelationshipMatrix.relation(from, to)`.
4. Honest seeded state: every record `unknown` status, `unverified`,
   `Unknown` source.
5. Coverage report matches the matrix (22 / 16 / 18).
6. Importer flags missing fields, unknown enums, duplicates, self-pairs,
   matrix mismatches, missing coverage, and bad JSON.

---

## Adding a documented source (workflow)

1. Copy a record shape from `planet_relationships.template.json`.
2. Fill `source` / `author` / `edition` / `publisher` / `year` / `reference` /
   `page` / `quote` from a real reference. Keep `relation` equal to the frozen
   matrix value (the importer warns otherwise).
3. Set `status: candidate`; raise to `verified` (with `verified: true` and a
   non-`none` `confidence`) only after checking the source.
4. Run the validation test — it re-imports the canonical data and reports
   updated coverage. No engine or app change is required.

---

## Related documents

- [`THAI_KNOWLEDGE_FOUNDATION_V1.md`](THAI_KNOWLEDGE_FOUNDATION_V1.md) — V1 model + audit.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-044 (this), D-043 (V1), D-009 (V8 matrix).
- [`ARCHITECTURE.md`](ARCHITECTURE.md) · [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) · [`ROADMAP.md`](ROADMAP.md).
