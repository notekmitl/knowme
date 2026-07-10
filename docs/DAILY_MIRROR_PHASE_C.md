# KnowMe Phase C — Daily Mirror Experience

**Status:** CURRENT (implementation record · Home emotional entry)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** Home V4 ([`HOME_V4.md`](HOME_V4.md)), P3 Global Mirror Experience
([`GLOBAL_MIRROR_EXPERIENCE_P3.md`](GLOBAL_MIRROR_EXPERIENCE_P3.md)), Phase A
Product Validation ([`PRODUCT_VALIDATION.md`](PRODUCT_VALIDATION.md)).

---

## 1. Goal

Transform Home into a **Daily Mirror** — a calm daily read on life rather than a
tour of engine stages. Hard constraints (honoured): **no new Runtime, no new
Provider, no AI**, and no redesign of the Runtime or the Mirror Experience.

The user experiences **life guidance, not engine outputs**. Prediction,
Decision and Timeline are hidden as concepts.

```
Today  ·  (clarity)
  ├─ Today's opening     ← an opportunity
  ├─ Go gently with      ← a caution
  ├─ Worth your focus    ← a focus
  ├─ One small step      ← a single suggested action
  ├─ What this is based on   (expandable: why · evidence · more details)
  ├─ Something on your mind? → conversation
  └─ See the fuller reflection → full journey (secondary)
```

---

## 2. What shipped

### `MirrorDaily` + `MirrorExperienceService.daily()`

`lib/features/mirror_experience/mirror_view_models.dart`,
`lib/features/mirror_experience/mirror_experience_service.dart`

`daily()` **composes the existing fusion reads** (`currentLife` / `prediction` /
`decision`) into today's read — there is **no new capability, no new reasoning,
no AI**. It derives:

- **Opportunity** — the strongest forward-looking life area (falls back to a
  strong current area, then to "an open day").
- **Caution** — the most tender current/forward area (falls back to "nothing
  pressing").
- **Focus** — the decision's focus area, phrased with its gentle lean.
- **One small step** — a single concrete action derived from the focus + lean.
- **Evidence areas + clarity** — the distinct underlying areas and the overall
  read clarity, for the expandable "what this is based on".

The composer is deterministic and unit-tested; all copy lives in `MirrorCopy`
and obeys **explain life, not astrology** (no planet/engine/system words, and no
"prediction/decision/timeline" concept words either).

### `DailyMirrorSection`

`lib/features/mirror_experience/ui/daily_mirror_section.dart`

The new Home emotional entry. It reuses existing P3 widgets — `MirrorCardShell`,
`MirrorWhyTile` (the expandable evidence), `MirrorClarityPill`,
`MirrorQuestionCard` and `MirrorConversationEntry` — and consumes the
**`FusionRuntime` only** via `MirrorExperienceService`. It renders Today's three
messages, the suggested step (with a gentle "I'll do this" acknowledgement), the
evidence tile, and a single conversation entry that opens an inline
`MirrorConversationEntry`. The full guided `MirrorHome` journey remains reachable
through a **secondary** "See the fuller reflection" link.

### Home wiring

`lib/features/home_cohesion/presentation/home_screen_v3.dart`

`HomeScreenV3` now renders `DailyMirrorSection` (in place of the Phase B
`MirrorHomeSection`) when `mirrorBirthDate != null`; otherwise the legacy
`HomeHeroSection` is preserved for incomplete profiles. `HomePage` is unchanged
from Home V4 — it still derives the birth date from its already-loaded bundle.
The Phase B `MirrorHomeSection` is removed as dead code.

---

## 3. Telemetry

Phase C adds three signals to the Phase A tracker (additive — recorder, engine
and dashboard are otherwise unchanged):

| Requirement | Event |
|-------------|-------|
| Daily Mirror open | `dailyMirrorOpened` (fired on section mount) |
| Action click | `dailyActionClicked` (suggested step tapped) |
| Conversation start | `dailyConversationStarted` (entry tapped) |
| Evidence expand | `evidenceExpanded('dailyMirror')` (reused) |

To keep the Phase A funnel (Home → Current Life → Prediction → Decision →
Conversation → Reflection) coherent now that Home shows everything at once, the
section also fires the internal stage events on open (`homeViewed`,
`insightViewed`, `predictionViewed`, `decisionViewed`) and `askMoreViewed` when
the conversation opens. These are internal stage names only — they never surface
in the UI.

---

## 4. Boundaries

- **Reasoning:** `FusionRuntime` only; no provider/Thai types on the surface.
- **No new engine/provider/capability/AI** — `daily()` reuses existing reads.
- **Frozen:** Runtime stack, P3 cards/journey, `/mirror-experience` route, and
  the AuthGate → ProfileGate → HomePage boot flow.
- **Additive:** view model + service method + copy + one widget + a one-line
  Home swap + three telemetry events.

---

## 5. Tests

- `test/validation/daily_mirror_phase_c/daily_mirror_test.dart` — `daily()`
  shape (three labelled messages, action, clarity, bounded evidence),
  explain-life-not-astrology copy (incl. no prediction/decision/timeline words),
  determinism, and the action-click / conversation-start telemetry.
- `test/validation/home_v4/home_v4_mirror_entry_test.dart` — Home shows the
  Daily Mirror when a birth date is present (legacy hero otherwise), records
  `dailyMirrorOpened`, and opens an inline conversation from the entry.

Existing suites still pass: `test/home_screen_v3_test.dart`,
`test/validation/mirror_experience_p3/`,
`test/validation/product_validation_phase_a/`.

---

## 6. Future work

- A persistent "today" cache so the read is stable across a day / sessions.
- Localized Thai copy and richer per-provider phrasing.
- Additional providers fusing into the same Daily Mirror once registered.

See [`DECISION_LOG.md`](DECISION_LOG.md) **D-033**,
[`ARCHITECTURE.md`](ARCHITECTURE.md) (Daily Mirror section), and
[`ROADMAP.md`](ROADMAP.md).
