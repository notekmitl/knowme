# Thai Astrology V10 — Prediction Intelligence Foundation

**Status:** CURRENT (implementation record · engine layer)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V9 Life Timeline Intelligence
([`THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`](THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md),
[`DECISION_LOG.md`](DECISION_LOG.md) D-019)

---

## 1. Goal

V9 taught the Thai engine to *interpret* a life-period timeline: planet
relationships, per-period intelligence, current-age analysis and a future-period
preview — all as deterministic **evidence**.

V10 adds the **Prediction Intelligence Foundation**: a deterministic reasoning
layer that, given V9 intelligence, produces structured **predictions** for the
seven life areas across three time horizons.

It is, explicitly:

- **NOT AI** — no LLM, no generation, fully deterministic.
- **NOT Transit** — no ephemeris/transit math; it reasons only over the V9
  life-period model.
- **Evidence only** — no Thai copy, no user-facing text, no presenter, no UI,
  no Firestore, no routing.

V10 adds **no new runtime path and modifies no frozen engine**. It is additive
on the reusable core, consistent with D-007/D-009/D-019 and the freeze registry
in [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md).

---

## 2. Architecture (engine-first, reusable)

All logic lives in a new reusable core package
`lib/features/astrology/thai/core/prediction/`. It depends **only** on the V9
core (`core/life_period/`) and is free of Flutter, `BuildContext`, copy and
persistence — so it can be reused unchanged by **Future Prediction, Transit,
Compatibility and AI Conversation**.

```
PredictionIntelligenceEngine.fromBirthDate(birthDate, lagnaLord?, asOf?)
  → LifeTimelineIntelligenceEngine.fromBirthDate(...)   (V9 — reused, untouched)
  → PredictionContext.fromIntelligence(intelligence)
  → PredictionWindows.forIntelligence(...)              (current / next 12mo / next period)
  → for each available window × each category:
        _governingPeriod → base/natal/tier/timing → PredictionScore
        evidence + opportunities + risks + 3 reasons
  = PredictionIntelligence {
        context, windows[3], predictions[ category × available window ]
    }
```

The engine never re-derives anything V9 already computed (period relationships,
natal harmony, strength tiers, transition quality, future opportunities/
challenges). It *composes* that evidence into category/window predictions.

---

## 3. Types

| Type | Role |
|------|------|
| `PredictionCategory` | Career, Finance, Relationship, Health, Learning, Personal Growth, Family. Mapped onto V9 `LifeDomain`s via documented weights — the engine never re-scores domains. |
| `PredictionWindow` (+ `PredictionWindowKind`) | A computed age span: `current` (active period chapter), `next12Months` (one-year slice), `nextLifePeriod` (the upcoming period). Carries `startAge`/`endAge`/`spanYears`/`spansTransition`/`available`. |
| `PredictionContext` | Read-only adapter over the V9 `LifeTimelineIntelligence` bundle (forwarding only; adds no derived state). Exposes a deterministic `seed` from natal anchors. |
| `PredictionScore` | `strength` (how active/favourable, 0–100) + `confidence` (how well-supported, 0–100) + `weighted`/`band`. |
| `PredictionEvidence` (+ `PredictionEvidenceSource`) | A typed, signed signal atom (category affinity, natal harmony, period strength, timing, transition, neighbour bond, future opportunity/challenge). |
| `PredictionOpportunity` / `PredictionRisk` | Structured supportive / caution `LifeDomain` tags with a 0–100 magnitude and a source. |
| `PredictionReason` (+ `PredictionReasonKind`, `PredictionReasonCode`) | A *why* code on one of three axes — timing, planet, life period — with the signed magnitude it contributed. **Codes, never prose.** |
| `Prediction` | One category × one window: `score`, `evidence[]`, `opportunities[]`, `risks[]`, and the three required reasons. |
| `PredictionIntelligence` | The full result: `context`, `windows[3]`, `predictions[]`, plus `forWindow` / `forCategory` / `predictionFor` / `ranked` accessors. |

### 3.1 Category → domain mapping

| Category | Domains (weight) |
|----------|------------------|
| Career | career 0.7 · opportunity 0.3 |
| Finance | money 0.8 · career 0.2 |
| Relationship | love 0.85 · health 0.15 |
| Health | health 0.8 · love 0.2 |
| Learning | growth 0.6 · opportunity 0.4 |
| Personal Growth | growth 0.7 · health 0.3 |
| Family | love 0.6 · health 0.4 |

---

## 4. Scoring (deterministic)

For each category × window, the engine selects the **governing period** (current
period for `current`/`next12Months`; the next period for `nextLifePeriod`, and
for `next12Months` when the current period ends within the year):

**Strength** = clamp(`base` + `natal` + `tier` + `timing`, 0..100)

- `base` — weighted V9 affinity of the governing ruler over the category domains.
- `natal` — `natalHarmonyScore` (clamped ±6) × 3 → ±18.
- `tier` — period strength tier (dominant +5 · strong +3 · moderate 0 · brief +1).
- `timing` — window/stage/transition (e.g. current peak +4, transition slice −3,
  smooth next transition +3, turbulent −4).

**Confidence** = clamp(`proximityBase` + adjustments, 0..100)

- `proximityBase` — **dominant** driver with 16-point gaps: current 80 ·
  next-12-months 64 · next-life-period 48.
- adjustments (bounded, ±~6) — lagna known +6, strength tier −2..+4,
  natal corroboration 0..4, rough next-period transition −3/−6.
- Because the gaps (16) exceed the maximum adjustment swing, confidence is
  **monotonic by horizon**: nearer windows are always ≥ farther windows.

Opportunities/risks are taken from the governing ruler's intrinsic affinity (and
the V9 future preview for the far window), deduped by domain, ranked by
magnitude, capped at three. `pressure` is never an opportunity.

---

## 5. Tests

`test/validation/thai_mirror_v10_prediction/prediction_intelligence_test.dart`
(23 tests) covers the four required areas:

- **Window calculation** — fixed order/availability, span bounds, alignment with
  the V9 future preview, final-period unavailability.
- **Determinism** — identical inputs → identical predictions; `fromBirthDate` ≡
  `fromIntelligence`; seed depends only on natal anchors.
- **Evidence integrity** — scores in 0..100; evidence non-empty with the core
  signals present; opportunities/risks bounded, deduped, ranked; `pressure`
  excluded from opportunities; planet reason carries ruler + bond.
- **Prediction stability** — confidence monotonic (current ≥ next-12-months ≥
  next-life-period); lagna never lowers confidence; strength monotonic in base
  affinity within a window; `ranked` sorted by weighted score; graceful
  final-period degradation.

---

## 6. Boundaries & reuse

- **Frozen / untouched:** Thai Foundation Engine, Theme Engine, Life Period
  Engine, Timeline Intelligence Engine (V9), Consumer Presenter, Timeline UI.
- **No presentation layer** ships in V10 — nothing consumes the engine yet. A
  later feature will map `PredictionReasonCode`s → copy on the presentation side,
  preserving the copy boundary.
- **Reusable by:** Future Prediction, Transit, Compatibility, AI Conversation —
  all can feed a `PredictionContext` and read structured evidence.

---

## 7. File map

```
lib/features/astrology/thai/core/prediction/
  prediction_category.dart              # categories + domain weighting
  prediction_window.dart                # window kinds + span calculation
  prediction_score.dart                 # strength + confidence
  prediction_reason.dart                # reason kinds/codes (evidence only)
  prediction_evidence.dart              # evidence / opportunity / risk atoms
  prediction_context.dart               # read-only adapter over V9 intelligence
  prediction.dart                       # Prediction aggregate
  prediction_intelligence_engine.dart   # engine + PredictionIntelligence result

test/validation/thai_mirror_v10_prediction/
  prediction_intelligence_test.dart     # determinism / integrity / stability / windows
```

---

## Related documents

- [`THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`](THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md) — the V9 layer this builds on.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-020 (this layer), D-019 (V9), D-009 (Life Period Engine).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — conceptual model.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry (Prediction Foundation entry).
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — project context.
