# Thai Astrology V9 — Life Timeline Intelligence

**Status:** CURRENT (implementation record · engine layer)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** V8 Life Period Engine ([`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) §4,
[`DECISION_LOG.md`](DECISION_LOG.md) D-009)

---

## 1. Goal

V8 shipped a life-period *sequence* (the traditional Thai 8-day planetary cycle)
and a presentation layer that scored and narrated each period. V9 makes the
**engine itself significantly more intelligent**: it now understands *how the
planets relate*, *how each period interacts with who the person is*, *why the
current period matters*, and *what the next period brings* — all as deterministic
**evidence**, with the copy boundary preserved.

V9 adds **no new runtime path and no engine rewrite**. It is additive on the
frozen Thai engine, consistent with D-007/D-009 and the Timeline Engine freeze
entry in [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md).

---

## 2. Architecture (engine-first)

All new logic lives in the reusable core module
`lib/features/astrology/thai/core/life_period/` and is **evidence only** — no
Flutter, no `BuildContext`, no narrative prose (short Thai *labels* only, matching
the V8 core convention). Presentation composes the prose.

```
LifeTimelineIntelligenceEngine.fromBirthDate(birthDate, lagnaLord?, asOf?)
  → LifePeriodEngine.fromBirthDate            (V8 period sequence — reused)
  → LifeNatalContext { birthRuler, lagnaLord }
  → for each period:  PeriodIntelligenceEngine.evaluate(...)
  → CurrentAgeAnalysisEngine.evaluate(...)
  → FuturePeriodPreviewEngine.evaluate(...)
  = LifeTimelineIntelligence {
        timeline, natal, periodIntelligence[], currentAge, futurePreview
    }
```

### 2.1 Planet Relationship Engine

| Concept | Where | Notes |
|---------|-------|-------|
| Friend / Enemy / Neutral | `planet_relationship_matrix.dart` (V8, reused) | Traditional natural-friendship table |
| Element relationship | `planet_element.dart` (V9) | Planet → Thai element (ไฟ/ดิน/ลม/น้ำ); supporting / neutral / conflicting |
| Support / Conflict (combined bond) | `planet_relationship_engine.dart` (V9) | `PlanetBond`: support · harmony · neutral · friction · conflict |

**Combined scoring.** `natural × 2 + element`, range −3..+3, mapped:
`≥2 → support · 1 → harmony · 0 → neutral · −1 → friction · ≤−2 → conflict`.
The V8 `PlanetRelationshipMatrix` is untouched; V9 wraps it additively, so the
existing composite scorer and narrative composer keep working unchanged.

**Element model** (symmetric, documented):
- ไฟ (fire): Sun, Mars · ดิน (earth): Mercury · ลม (air): Jupiter, Saturn, Rahu ·
  น้ำ (water): Moon, Venus
- supporting: same element, fire↔air, earth↔water
- conflicting: fire↔water, earth↔air
- everything else: neutral

### 2.2 Life Period Intelligence

`period_intelligence.dart` → `PeriodIntelligence` per period:
- **period ruler** + **element** + **strength tier** (`brief`/`moderate`/`strong`/`dominant`, from the period's year-length 6–21)
- **natal interaction** — period ruler vs **birth (weekday) ruler** and vs **lagna lord** (when birth time is known)
- **friend/enemy interaction** — period ruler vs the **previous** and **next** period rulers (transition quality)
- **natal harmony score** — net alignment of the period with the natal anchors
- **influences** — ranked influencing planets (for "dominant influences")

### 2.3 Current Age Analysis

`current_age_analysis.dart` → `CurrentAgeAnalysis`:
- **current period** + its `PeriodIntelligence`
- **phase stage** — `opening` / `peak` / `closing` (from period progress)
- **transition approaching** — closing stage with ≤3 years left
- **dominant influences** — the influences acting now (excludes the next-period planet)
- **why it matters** — structured `CurrentAgeFactor`s (long/brief period, aligned/tests nature, opening momentum, mid peak, transition approaching)

### 2.4 Future Period Preview

`future_period_preview.dart` → `FuturePeriodPreview`:
- **next period** + its `PeriodIntelligence` + **years until**
- **transition** — `smooth` / `gentleShift` / `markedShift` / `turbulent` (from current→next bond)
- **element shift** — from/to element + relation
- **opportunities** — the next planet's strongest intrinsic `LifeDomain`s
- **challenges** — the next planet's weakest domains (widened by one on a conflicting transition)

---

## 3. Presentation (copy boundary preserved)

The engine emits structure; the presentation layer emits prose.

- `presentation/timeline/period_intelligence_composer.dart` — turns
  `CurrentAgeAnalysis` / `FuturePeriodPreview` evidence into Thai consumer copy
  (tendency language — "มัก / มีแนวโน้ม / อาจ"; no fate/destiny/certainty),
  deterministic via the profile seed.
- `TimelinePresenter.build` now derives `LifeTimelineIntelligence` from the same
  V8 `LifeTimeline` evidence + lagna lord, and populates two **optional** new
  view-state blocks: `ThaiMirrorCurrentAnalysisState` and
  `ThaiMirrorFuturePreviewState`.
- `ThaiMirrorLifeTimelineSection` renders a "ทำไมช่วงนี้ถึงสำคัญ" analysis card
  and a "ช่วงต่อไปของคุณ" future-preview card inside the existing
  `thai_consumer_life_timeline` section (no new section key; same shared page).

No pipeline or result-contract change was required — presentation derives the
intelligence from existing evidence, keeping blast radius minimal.

---

## 4. Files

**Engine (evidence only)** — `lib/features/astrology/thai/core/life_period/`
- `planet_element.dart` · `planet_relationship_engine.dart` ·
  `life_natal_context.dart` · `period_intelligence.dart` ·
  `current_age_analysis.dart` · `future_period_preview.dart` ·
  `life_timeline_intelligence.dart`
- `life_planet.dart` — additive `LifeDomain` enum + `PlanetAffinity` ranking helper

**Presentation** — `lib/features/astrology/thai/mirror/presentation/timeline/`
- `period_intelligence_composer.dart` (new) · `timeline_presenter.dart` (wired) ·
  `thai_mirror_life_timeline_state.dart` (additive states)
- `ui/widgets/thai_mirror_life_timeline_section.dart` (renders the new cards)

**Tests** — `test/validation/thai_mirror_v9_intelligence/life_timeline_intelligence_test.dart`

---

## 5. Validation

- **Engine tests (14):** element symmetry, combined-bond scoring bounds (−3..+3),
  strength tiers, per-period intelligence alignment, lagna-absent path, current
  stage + transition flag, future preview transition/opportunities/challenges,
  final-period `none`, and aggregator **determinism** (identical inputs → identical
  output).
- **QA gates:** story-coverage CI (A–H) passes (Thai-only, no placeholders, no
  overflow); V8 narrative-diversity audit still passes (max 77.9% / avg 57.0%,
  0 identical pairs); screenshot baselines regenerated for the updated timeline.

Determinism is guaranteed: no `DateTime.now()` inside the engine (current age is
derived from the pinned `asOf` upstream), no randomness — only the profile seed
selects copy variants.

---

## 6. Reusability

`LifeTimelineIntelligence` is engine evidence with no presentation dependency, so
it is reusable by the FUTURE Prediction, Annual Prediction, Compatibility and
Fusion surfaces (see [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) §1/§4 FUTURE nodes)
without reopening the report contract.

---

## 7. Related documents

- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — Thai architecture + version ledger.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-009 (V8), D-019 (V9).
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — Timeline Engine freeze entry.
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — engine ownership + data flow.
- [`ASTROLOGY_QA_HARNESS_V1.md`](ASTROLOGY_QA_HARNESS_V1.md) — QA gates.
