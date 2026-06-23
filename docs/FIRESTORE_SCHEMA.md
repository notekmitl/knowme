# KnowMe Firestore Schema

**Purpose:** Firestore semantics for developers and AI agents.  
**Canonical entry:** [`HANDOFF.md`](HANDOFF.md) §7 links here for full detail.  
**Last updated:** June 2026

---

## Mental Model

Every user document tree has two **families** under `users/{uid}/`:

| Family | Role | Mental model |
|--------|------|--------------|
| `tests/*` | Session / progress | Transient working memory — can change often |
| `results/*` | Deterministic snapshot | Stable interpretation layer — source of truth for insights |

**Critical rule:** Fusion, mirror loaders, confidence, and summary systems read **`results/*`**, never `tests/*`.

```
For UX progress     → tests/*
For insights/result → results/*
```

**Bad:** Fusion reads `tests/answered`  
**Good:** Fusion reads `results/scoredQuestionCount`

---

## Profile & Astrology Paths

| Path | Content | Notes |
|------|---------|-------|
| `users/{uid}/profile/main` | Birth profile (name, date, time, place, coords, timezone) | ProfileGate source of truth |
| `users/{uid}/astrology/western_natal` | Western natal chart | Generated on profile setup / birth-critical edit |
| `users/{uid}/astrology/chinese_bazi` | BaZi chart | **UI source of truth** — do not read `results/chinese_bazi` |
| `users/{uid}/funnel_telemetry/*` | Funnel Recovery V2 events | `home_view`, `mbti_start`, `mbti_complete`, etc. |

---

## `tests/*` — Session Documents

**Purpose:** Progress, answers, resume state, continue state, completion state.

**Typical fields:** `answered`, `answers`, `completed`, `total`, `index`

**Examples:**

- `users/{uid}/tests/mbti_mini`
- `users/{uid}/tests/mbti_cognitive`

**Used for:** catalog progress, timeline UI, continue/resume — **not** for fusion confidence.

---

## `results/*` — Result Documents

**Purpose:** Persistent deterministic snapshots used by result pages, fusion, confidence, summaries.

**Typical fields:** `type`, `dimensions`, `scores`, `topFunctions`, `scoredQuestionCount`, `scoringVersion`, `testId`

**Examples:**

- `users/{uid}/results/mbti_mini`
- `users/{uid}/results/mbti_cognitive`
- `users/{uid}/results/eq_*`
- `users/{uid}/results/big_five*`

**Used by:** `PersonalityLensLoader`, Fusion lens loader, narrative pipeline, result pages.

---

## Legacy Compatibility (Critical — Do Not Remove)

Older MBTI result documents may have `scoredQuestionCount: null` (field added after initial launch).

**Behavior (implemented):**

1. If `scoredQuestionCount == null`, infer from dimension score mass.
2. Example: `dimensionMass = 480` → infer `80`.
3. Auto-backfill Firestore on read.

This is **production compatibility logic**, not debug code. Never remove without a migration plan.

**Confidence rule:** Result confidence depends on `results.scoredQuestionCount`, **not** `tests.answered`.

---

## MBTI Summary — No Persistence

`mbti_summary` does **not** write Firestore. It is a derived interpretation layer only — no session, no scoring persistence.

See [`MBTI_ARCHITECTURE.md`](MBTI_ARCHITECTURE.md).

---

## Quick Reference

```
tests/*   = current progress (working state)
results/* = trusted interpretation (insight source)
```

When debugging "why doesn't fusion see my MBTI?": check `results/mbti_mini` exists and is complete — not `tests/mbti_mini` alone.
