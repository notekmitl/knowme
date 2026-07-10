# Thai Astrology Consensus Engine V8

> Measure **agreement between sources** (V7). For every directed relationship,
> count friend / enemy / neutral votes, classify the outcome, and estimate a
> confidence from the number of sources. **No engine changes. Does NOT modify
> the `PlanetRelationshipMatrix`.**

Status: **CURRENT** · Knowledge only · **No deploy**.
Decision Log **D-050**. Reads V7 sources; feeds Matrix Review (V9).

---

## Engine

`lib/features/astrology/thai/knowledge/consensus/knowledge_consensus_engine.dart`

- `entryFor(from, to) → ConsensusEntry` — vote counts + classification + confidence.
- `entries()` — every directed pair (56).
- `report() → ConsensusReport`.

Pure: reads only `SourceRecord` assertions. **Never reads or writes the matrix.**

---

## Vote counting & classification

For a pair, count `friend` / `enemy` / `neutral` across all source assertions and
the number of distinct contributing sources.

| Classification | Meaning |
|----------------|---------|
| `uncovered` | no source asserts the pair |
| `consensus` | unanimous (a single relation asserted) |
| `majority` | unique winner with a strict majority (> 50%) |
| `split` | tie for the top relation (no unique winner) |
| `disputed` | unique winner but only a plurality (≤ 50%) |

## Confidence (driven by number of sources)

| Sources | Base confidence |
|---------|-----------------|
| 0 | none |
| 1–2 | low |
| 3–7 | medium |
| 8+ | high |

Downgraded one level when the pair is `split` or `disputed` (floored at `low`).

---

## Example (from the brief)

```
venus → saturn
  friend  : 4 sources
  enemy   : 2 sources
  neutral : 1 source
  → consensus  : friend
    classification: majority   (4/7 > 50%)
    confidence    : medium     (7 sources)
```

This exact case is asserted in the tests.

---

## Consensus Report

Per-pair entries + a summary: `Relationships` · `Covered` · `Consensus` ·
`Majority` · `Split` · `Disputed` · `Uncovered`.

**Baseline (no sources):** 56 relationships, all `uncovered`, 0 covered.

---

## Tests

`test/validation/thai/thai_source_consensus_review_test.dart` — the spec example
(majority/medium), unanimous→consensus, tie→split with confidence downgrade,
the universe summary, and the decoupling guard (no engine/matrix import).

---

## Related documents

- [`THAI_SOURCE_COLLECTION_V7.md`](THAI_SOURCE_COLLECTION_V7.md) · [`THAI_MATRIX_REVIEW_V9.md`](THAI_MATRIX_REVIEW_V9.md) · [`DECISION_LOG.md`](DECISION_LOG.md) (D-050).
