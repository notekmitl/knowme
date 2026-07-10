# Thai Astrology Source Collection V7

> Begin collecting **real** astrology sources. The output is **knowledge, not
> software**: one JSON file per source, each carrying relationship assertions
> that keep the original **page** and **quote** and point back to exactly one
> source.

Status: **CURRENT** · Knowledge only · No engine/matrix change · **No deploy**.
Decision Log **D-049**. Feeds the Consensus Engine (V8) and Matrix Review (V9).

---

## Architecture

```
knowledge/sources/
├── sources.schema.json     # one-file-per-source contract
├── sources.template.json   # blank source to copy
└── sources.index.json      # list of real source files the engine loads

lib/features/astrology/thai/knowledge/sources/
├── source_record.dart            # SourceRecord + SourceAssertion (plain strings)
└── knowledge_source_engine.dart  # load / validate / coverage
```

One JSON **per source** — e.g. `thai_classical_x.json`, `thai_modern_y.json`,
`vedic_source_a.json`. Add the filename to `sources.index.json`;
`KnowledgeSourceEngine.loadFromAssets()` loads every listed file. Registered as
a Flutter asset directory.

---

## A source

`id` · `title` · `author` · `edition` · `publisher` · `year` · `language` ·
`school` · `isbn` · `url` · `license` · `notes`, plus **assertions**.

### An assertion

`from` → `to` → `relation` (`friend`/`neutral`/`enemy`) → `page` → `quote`
(+ optional `note`). Example:

```
venus → saturn → friend → page 128 → "…original quote…"
```

**Never summarize without keeping the original quote.** Every assertion points
back to its one source (the file it lives in).

---

## Validation (`validate()`)

| Detect | Code | Severity |
|--------|------|----------|
| Same source repeats `from,to,relation` | `duplicate_assertion` | warning |
| Same source asserts a pair two ways | `conflicting_assertion` | error |
| Assertion has no page | `missing_page` | warning |
| Assertion has no quote | `missing_quote` | warning |
| Unknown planet/relation (untraceable) | `broken_reference` | error |
| Same source id in two files | `duplicate_source` | error |

Cross-source disagreement is **not** an error here — that is the Consensus
Engine's job (V8).

---

## Source Coverage Report

`Books` · `Schools` · `Authors` · `Assertions` · `Relationships covered` ·
`Relationships missing` (of the 8×7 = 56 directed-pair universe) + coverage %.

**Baseline (no real sources yet):**

```
Thai Astrology — Source Coverage Report
Books                  : 0
Schools                : 0
Authors                : 0
Assertions             : 0
Relationships covered  : 0 / 56
Relationships missing  : 56
Coverage               : 0.0%
```

---

## Boundary / tests

Pure knowledge layer — planets/relations are plain strings; **no engine or
matrix dependency** (asserted by test). Adding sources never changes the matrix;
sources are evidence, reviewed by V8/V9.
`test/validation/thai/thai_source_consensus_review_test.dart` covers parsing,
every validation class, the coverage report, and the template/index assets.

---

## Related documents

- [`THAI_CONSENSUS_ENGINE_V8.md`](THAI_CONSENSUS_ENGINE_V8.md) · [`THAI_MATRIX_REVIEW_V9.md`](THAI_MATRIX_REVIEW_V9.md).
- [`THAI_KNOWLEDGE_ACQUISITION_V6.md`](THAI_KNOWLEDGE_ACQUISITION_V6.md) · [`DECISION_LOG.md`](DECISION_LOG.md) (D-049) · [`ARCHITECTURE.md`](ARCHITECTURE.md) · [`ROADMAP.md`](ROADMAP.md).
