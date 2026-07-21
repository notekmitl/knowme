# Thai Astrology Matrix Review V9

> Review the **frozen matrix using real evidence** (the V8 consensus over V7
> sources, plus V3/V4 user research) and produce a **proposal**. This is a
> *knowledge decision, not a code decision*: **no code changes, no engine
> changes, no deploy** — only a recommendation per relationship.

Status: **CURRENT** · Proposal only · No engine/matrix change · **No deploy**.
Decision Log **D-051**.

---

## Engine

`lib/features/astrology/thai/knowledge/review/matrix_review_engine.dart`

`MatrixReviewEngine.review({knowledge, consensus, sources, research}) →
MatrixReviewReport`. Pure; takes already-loaded inputs.

**It changes no code and touches no engine.** The "current matrix" value is read
from the **V2 knowledge mirror** (`PlanetRelationshipKnowledge`), which reflects
the frozen matrix for display only — the engine `PlanetRelationshipMatrix` is
never imported, read at runtime, or written.

---

## Per-relationship review row

For every directed relationship the proposal records:

- **Current Matrix** — the frozen value (`friend`/`neutral`/`enemy`).
- **Consensus** — the V8 entry (relation, classification, confidence, votes).
- **Supporting Sources** — sources asserting the current value.
- **Conflicting Sources** — sources asserting a different value.
- **User Research** — V3/V4 research record ids touching the pair.
- **Recommendation** — Keep / Review / Replace, with a rationale.

### Recommendation logic

| Situation | Recommendation |
|-----------|----------------|
| Uncovered, or confidence none/low | **Keep** (insufficient evidence) |
| Consensus relation == current matrix | **Keep** (evidence agrees) |
| Differs, but split/disputed or only medium confidence | **Review** (needs a human) |
| Differs, high confidence **and** consensus/majority | **Replace** (strong & clear) |

---

## Engine impact estimate

Counts of Keep / Review / Replace, and the subsystems that consume
planet-relationship values — **timeline, prediction, decision, compatibility,
conversation**. Only **Replace** rows would change engine output; **Review** rows
need a human decision first. If nothing is proposed for replacement, the engine
output is unaffected.

---

## Current proposal (baseline)

With no real sources collected yet, every directed relationship is `uncovered`,
so the proposal is:

```
Thai Astrology — Matrix Review (proposal, no code change)
Relationships reviewed : 56
Keep / Review / Replace: 56 / 0 / 0
Engine impact estimate
  Keep    : 56
  Review  : 0
  Replace : 0
  → No relationship changes proposed; engine output unaffected.
```

As real sources are added (V7) and consensus accrues (V8), this proposal will
surface Review/Replace candidates for human decision. **Acting on them is a
separate, future, explicitly-approved step — never automatic.**

---

## Tests

`test/validation/thai/thai_source_consensus_review_test.dart` — baseline (all 56
Keep, no impact), strong-clear disagreement → Replace with supporting/conflicting
sources tracked, weak disagreement → Keep, and the decoupling guard.

---

## Related documents

- [`THAI_SOURCE_COLLECTION_V7.md`](THAI_SOURCE_COLLECTION_V7.md) · [`THAI_CONSENSUS_ENGINE_V8.md`](THAI_CONSENSUS_ENGINE_V8.md) · [`DECISION_LOG.md`](DECISION_LOG.md) (D-051) · [`ARCHITECTURE.md`](ARCHITECTURE.md).
